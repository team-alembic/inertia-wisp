import gleam/dict
import gleam/http
import gleam/http/response
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleeunit
import inertia_wisp/internal/response_builder
import wisp/simulate

pub fn main() {
  gleeunit.main()
}

// Simple props type for testing
type SimpleProps {
  SimpleProps(message: String, count: Int)
}

fn encode_simple_props(props: SimpleProps) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("message", json.string(props.message)),
    #("count", json.int(props.count)),
  ])
}

// Test: Builder with props produces a response with correct component and props
pub fn builder_produces_response_with_props_test() {
  let req =
    simulate.request(http.Get, "/test")
    |> simulate.header("x-inertia", "true")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "TestComponent")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.response(200)

  // Response should be 200 OK
  assert response.status == 200

  // Response body should contain component name
  let body = simulate.read_body(response)
  assert body |> string.contains("TestComponent")

  // Response body should contain prop data
  assert body |> string.contains("Hello")
  assert body |> string.contains("42")
}

// Props type with optional field for lazy evaluation
type LazyProps {
  LazyProps(user: String, expensive_data: option.Option(String))
}

fn encode_lazy_props(props: LazyProps) -> dict.Dict(String, json.Json) {
  let base = dict.from_list([#("user", json.string(props.user))])

  case props.expensive_data {
    option.Some(data) -> dict.insert(base, "expensive_data", json.string(data))
    option.None -> base
  }
}

// Test: Lazy prop is evaluated and included in response
pub fn lazy_prop_is_evaluated_test() {
  let req =
    simulate.request(http.Get, "/test")
    |> simulate.header("x-inertia", "true")

  let initial_props = LazyProps(user: "Alice", expensive_data: option.None)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(initial_props, encode_lazy_props)
    |> response_builder.lazy("expensive_data", fn(props) {
      // Resolver receives current props and returns updated props
      Ok(LazyProps(..props, expensive_data: option.Some("computed-value")))
    })
    |> response_builder.response(200)

  // Response should contain the user prop
  let body = simulate.read_body(response)
  assert body |> string.contains("Alice")

  // Response should contain the evaluated lazy prop
  assert body |> string.contains("computed-value")
}

// Test: Optional prop is excluded from standard visits
pub fn optional_prop_excluded_from_standard_visit_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.optional("count")
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Message should be included (not marked as optional)
  assert body |> string.contains("Hello")

  // Count should NOT be included (marked as optional, not requested)
  assert !string.contains(body, "42")
}

// Test: Partial reload only includes requested fields
pub fn partial_reload_filters_to_requested_fields_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")
    |> simulate.header("x-inertia-partial-component", "Dashboard")
    |> simulate.header("x-inertia-partial-data", "message")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Message should be included (it was requested)
  assert body |> string.contains("Hello")

  // Count should NOT be included (not requested in partial reload)
  assert !string.contains(body, "42")
}

// Test: Always fields are included even in partial reloads
pub fn always_fields_included_in_partial_reload_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")
    |> simulate.header("x-inertia-partial-component", "Dashboard")
    |> simulate.header("x-inertia-partial-data", "message")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.always("count")
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Message should be included (it was requested)
  assert body |> string.contains("Hello")

  // Count should be included even though not requested (marked as always)
  assert body |> string.contains("42")
}

// Test: Deferred props generate metadata in response
pub fn deferred_props_generate_metadata_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let initial_props = LazyProps(user: "Alice", expensive_data: option.None)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(initial_props, encode_lazy_props)
    |> response_builder.defer("expensive_data", fn(props) {
      Ok(LazyProps(..props, expensive_data: option.Some("deferred-value")))
    })
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // User should be included (not deferred)
  assert body |> string.contains("Alice")

  // Expensive data should NOT be included (deferred)
  assert !string.contains(body, "deferred-value")

  // Response should contain deferredProps metadata
  assert body |> string.contains("deferredProps")
  assert body |> string.contains("expensive_data")
}

// Test: Merge props generate metadata with deep option
pub fn merge_props_generate_metadata_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.merge("message", match_on: option.None, deep: False)
    |> response_builder.merge("count", match_on: option.None, deep: True)
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Props should be included
  assert body |> string.contains("Hello")
  assert body |> string.contains("42")

  // Response should contain mergeProps metadata (shallow merge)
  assert body |> string.contains("mergeProps")
  assert body |> string.contains("message")

  // Response should contain deepMergeProps metadata (deep merge)
  assert body |> string.contains("deepMergeProps")
  assert body |> string.contains("count")
}

// Test: Merge props with match_on option generates matchPropsOn metadata
pub fn merge_props_with_match_on_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.merge(
      "message",
      match_on: option.Some(["id", "slug"]),
      deep: False,
    )
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Props should be included
  assert body |> string.contains("Hello")

  // Response should contain matchPropsOn metadata
  assert body |> string.contains("matchPropsOn")

  // Should contain the match keys in dot notation (message.id, message.slug)
  assert body |> string.contains("message.id")
  assert body |> string.contains("message.slug")
}

// Test: Redirect returns 303 status with Location header
pub fn redirect_returns_303_with_location_header_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.redirect("/home")

  // Should return 303 status
  assert response.status == 303

  // Should have Location header
  let assert Ok("/home") = response.get_header(response, "location")
}

// Test: Redirect with errors stores errors in cookie
pub fn redirect_with_errors_stores_in_cookie_test() {
  let req =
    simulate.request(http.Get, "/login")
    |> simulate.header("x-inertia", "true")

  let errors =
    dict.from_list([#("email", "Email is required"), #("password", "Too short")])

  let response =
    response_builder.response_builder(req, "Login")
    |> response_builder.errors(errors)
    |> response_builder.redirect("/login")

  // Should return 303 status
  assert response.status == 303

  // Should have set-cookie header with errors
  let assert Ok(cookie_header) = response.get_header(response, "set-cookie")
  assert cookie_header |> string.contains("inertia_errors")
}

// Test: Partial reload component matching - filters when component matches
pub fn partial_reload_component_match_filters_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")
    |> simulate.header("x-inertia-partial-component", "Dashboard")
    |> simulate.header("x-inertia-partial-data", "message")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Message should be included (requested)
  assert body |> string.contains("Hello")

  // Count should NOT be included (component matches, so filtering applies)
  assert !string.contains(body, "42")
}

// Test: Partial reload component mismatch - no filtering when component differs
pub fn partial_reload_component_mismatch_no_filter_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")
    |> simulate.header("x-inertia-partial-component", "OtherComponent")
    |> simulate.header("x-inertia-partial-data", "message")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Both props should be included (component mismatch = no filtering)
  assert body |> string.contains("Hello")
  assert body |> string.contains("42")
}

// Test: URL includes query parameters
pub fn url_includes_query_parameters_test() {
  let req =
    simulate.request(http.Get, "/users?page=2&sort=name")
    |> simulate.header("x-inertia", "true")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Users/Index")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // URL should include query parameters
  assert body |> string.contains("/users?page=2&sort=name")
}

// Test: URL without query parameters
pub fn url_without_query_parameters_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // URL should be just the path
  assert body |> string.contains("\"/dashboard\"")
}

// Test: Lazy prop resolver error handling
pub fn lazy_prop_error_handling_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let initial_props = LazyProps(user: "Alice", expensive_data: option.None)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(initial_props, encode_lazy_props)
    |> response_builder.lazy("expensive_data", fn(_props) {
      // Resolver returns an error
      Error(dict.from_list([#("expensive_data", "Failed to load data")]))
    })
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // User should still be included
  assert body |> string.contains("Alice")

  // When resolver fails, the prop remains as its initial value (None)
  // So expensive_data won't be in the response
  assert !string.contains(body, "expensive_data")
}

// Test: Deferred prop resolver error handling
pub fn deferred_prop_error_handling_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")
    |> simulate.header("x-inertia-partial-component", "Dashboard")
    |> simulate.header("x-inertia-partial-data", "expensive_data")

  let initial_props = LazyProps(user: "Alice", expensive_data: option.None)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(initial_props, encode_lazy_props)
    |> response_builder.defer("expensive_data", fn(_props) {
      // Resolver returns an error
      Error(
        dict.from_list([#("expensive_data", "Failed to load deferred data")]),
      )
    })
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // When deferred prop is explicitly requested but resolver fails,
  // the prop remains as its initial value (None) so won't be in response
  assert !string.contains(body, "expensive_data")
}

// Test: clear_history flag appears in response
pub fn clear_history_flag_in_response_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.clear_history()
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Should contain clearHistory: true
  assert body |> string.contains("\"clearHistory\":true")
}

// Test: encrypt_history flag appears in response
pub fn encrypt_history_flag_in_response_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.encrypt_history()
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Should contain encryptHistory: true
  assert body |> string.contains("\"encryptHistory\":true")
}

// Test: version string appears in response
pub fn version_string_in_response_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.version("abc123")
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Should contain version: "abc123"
  assert body |> string.contains("\"version\":\"abc123\"")
}

// Test: Partial reload with deferred props - evaluates when explicitly requested
pub fn partial_reload_evaluates_deferred_props_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")
    |> simulate.header("x-inertia-partial-component", "Dashboard")
    |> simulate.header("x-inertia-partial-data", "expensive_data")

  let initial_props = LazyProps(user: "Alice", expensive_data: option.None)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(initial_props, encode_lazy_props)
    |> response_builder.defer("expensive_data", fn(props) {
      Ok(LazyProps(..props, expensive_data: option.Some("deferred-computed")))
    })
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // User should NOT be included (not requested in partial reload)
  assert !string.contains(body, "Alice")

  // Expensive data SHOULD be included (explicitly requested, so deferred prop is evaluated)
  assert body |> string.contains("deferred-computed")

  // Should NOT include deferredProps metadata (since it was explicitly requested)
  assert !string.contains(body, "deferredProps")
}

// Test: Initial page load returns HTML response
pub fn initial_page_load_returns_html_test() {
  let req = simulate.request(http.Get, "/dashboard")
  // No x-inertia header = initial page load

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.response(200)

  // Should return 200 status
  assert response.status == 200

  // Should have HTML content-type
  let assert Ok(content_type) = response.get_header(response, "content-type")
  assert content_type |> string.contains("text/html")

  // Response body should be HTML with embedded JSON
  let body = simulate.read_body(response)
  assert body |> string.contains("<!DOCTYPE html>")
  assert body |> string.contains("<div id=\"app\"")
  assert body |> string.contains("data-page=")

  // Should include the component and props in embedded JSON
  assert body |> string.contains("Dashboard")
  assert body |> string.contains("Hello")
}

// Test: Initial page load with deferred props includes metadata
pub fn initial_page_load_with_deferred_props_test() {
  let req = simulate.request(http.Get, "/dashboard")
  // No x-inertia header = initial page load

  let initial_props = LazyProps(user: "Alice", expensive_data: option.None)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(initial_props, encode_lazy_props)
    |> response_builder.defer("expensive_data", fn(props) {
      Ok(LazyProps(..props, expensive_data: option.Some("deferred-value")))
    })
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Should be HTML response
  assert body |> string.contains("<!DOCTYPE html>")

  // User should be included in embedded JSON
  assert body |> string.contains("Alice")

  // Expensive data should NOT be evaluated (it's deferred)
  assert !string.contains(body, "deferred-value")

  // Should include deferredProps metadata in embedded JSON
  assert body |> string.contains("deferredProps")
  assert body |> string.contains("expensive_data")
}

// Test: Inertia request returns JSON (not HTML)
pub fn inertia_request_returns_json_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let props = SimpleProps(message: "Hello", count: 42)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(props, encode_simple_props)
    |> response_builder.response(200)

  // Should have JSON content-type
  let assert Ok(content_type) = response.get_header(response, "content-type")
  assert content_type |> string.contains("application/json")

  // Response body should be JSON (not HTML)
  let body = simulate.read_body(response)
  assert !string.contains(body, "<!DOCTYPE html>")
  assert !string.contains(body, "<div id=\"app\"")

  // Should have Inertia headers
  let assert Ok(inertia_header) = response.get_header(response, "x-inertia")
  assert inertia_header == "true"
}

// Test: Complete session error flow - redirect, store, retrieve, clear
pub fn session_error_flow_complete_test() {
  let validation_errors =
    dict.from_list([#("first_name", "is required"), #("email", "is invalid")])

  // Step 1: Redirect with errors stores them in cookie
  let req1 =
    simulate.request(http.Get, "/users/create")
    |> simulate.header("x-inertia", "true")

  let redirect_response =
    response_builder.response_builder(req1, "Users/Create")
    |> response_builder.errors(validation_errors)
    |> response_builder.redirect("/users/new")

  // Should be a redirect with cookie
  assert redirect_response.status == 303
  let assert Ok(cookie_header) =
    response.get_header(redirect_response, "set-cookie")
  assert cookie_header |> string.contains("inertia_errors=")

  // Step 2: Extract cookie value to simulate browser sending it back
  let cookie_value =
    string.replace(cookie_header, "inertia_errors=", "")
    |> string.split(";")
    |> list.first()
    |> result.unwrap("")

  let req2 =
    simulate.request(http.Get, "/users/new")
    |> simulate.header("x-inertia", "true")
    |> simulate.header("cookie", "inertia_errors=" <> cookie_value)

  // Step 3: Form display should automatically include errors from cookie
  let form_response =
    response_builder.response_builder(req2, "Users/Create")
    |> response_builder.props(
      SimpleProps(message: "Form", count: 1),
      encode_simple_props,
    )
    |> response_builder.response(200)

  let body = simulate.read_body(form_response)

  // Should include errors from cookie
  assert body |> string.contains("is required")
  assert body |> string.contains("is invalid")
  assert body |> string.contains("\"errors\"")

  // Should have set-cookie header that clears the cookie (Max-Age=0)
  let assert Ok(clear_cookie_header) =
    response.get_header(form_response, "set-cookie")
  assert clear_cookie_header |> string.contains("inertia_errors=")
  assert clear_cookie_header |> string.contains("Max-Age=0")
}

// Test: Cookie is cleared after consumption on non-redirect responses
pub fn cookie_cleared_after_consuming_errors_test() {
  // Step 1: Create redirect with errors to get signed cookie
  let req1 =
    simulate.request(http.Get, "/form")
    |> simulate.header("x-inertia", "true")

  let redirect_response =
    response_builder.response_builder(req1, "Form")
    |> response_builder.errors(dict.from_list([#("field", "error")]))
    |> response_builder.redirect("/form")

  let assert Ok(cookie_header) =
    response.get_header(redirect_response, "set-cookie")
  let cookie_value =
    string.replace(cookie_header, "inertia_errors=", "")
    |> string.split(";")
    |> list.first()
    |> result.unwrap("")

  // Step 2: Create request with cookie
  let req2 =
    simulate.request(http.Get, "/form")
    |> simulate.header("x-inertia", "true")
    |> simulate.header("cookie", "inertia_errors=" <> cookie_value)

  // Step 3: Regular 200 response should consume and clear cookie
  let response =
    response_builder.response_builder(req2, "Form")
    |> response_builder.props(
      SimpleProps(message: "Hi", count: 1),
      encode_simple_props,
    )
    |> response_builder.response(200)

  // Should have set-cookie header that clears the cookie
  let assert Ok(clear_cookie_header) =
    response.get_header(response, "set-cookie")
  assert clear_cookie_header |> string.contains("inertia_errors=")
  assert clear_cookie_header |> string.contains("Max-Age=0")
}

// Test: No cookie clearing when no cookie present
pub fn no_cookie_clearing_when_no_cookie_present_test() {
  let req =
    simulate.request(http.Get, "/form")
    |> simulate.header("x-inertia", "true")

  let response =
    response_builder.response_builder(req, "Form")
    |> response_builder.props(
      SimpleProps(message: "Hi", count: 1),
      encode_simple_props,
    )
    |> response_builder.response(200)

  // Should not have any set-cookie header
  let assert Error(_) = response.get_header(response, "set-cookie")
}

// Test: Errors in response include validation errors
pub fn errors_included_in_response_test() {
  let req =
    simulate.request(http.Get, "/form")
    |> simulate.header("x-inertia", "true")

  let validation_errors =
    dict.from_list([#("email", "is required"), #("password", "too short")])

  let response =
    response_builder.response_builder(req, "Form")
    |> response_builder.props(
      SimpleProps(message: "Hi", count: 1),
      encode_simple_props,
    )
    |> response_builder.errors(validation_errors)
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Should include errors in props
  assert body |> string.contains("\"errors\"")
  assert body |> string.contains("is required")
  assert body |> string.contains("too short")
}

// Test: Deferred props NOT re-advertised on partial reload (e.g., pagination)
pub fn deferred_props_not_readvertised_on_partial_reload_test() {
  // Simulate pagination request - partial reload for only "message" and "count"
  let req =
    simulate.request(http.Get, "/dashboard?page=2")
    |> simulate.header("x-inertia", "true")
    |> simulate.header("x-inertia-partial-component", "Dashboard")
    |> simulate.header("x-inertia-partial-data", "message,count")

  let initial_props = LazyProps(user: "Alice", expensive_data: option.None)

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(initial_props, encode_lazy_props)
    |> response_builder.lazy("user", fn(props) {
      Ok(LazyProps(..props, user: "Bob"))
    })
    |> response_builder.defer("expensive_data", fn(props) {
      Ok(LazyProps(..props, expensive_data: option.Some("deferred-value")))
    })
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // User should NOT be included (not requested in partial reload, even though lazy)
  assert !string.contains(body, "Alice")
  assert !string.contains(body, "Bob")

  // Expensive data should NOT be included (it's deferred and not requested)
  assert !string.contains(body, "deferred-value")

  // CRITICAL: deferredProps metadata should NOT be included
  // On partial reloads (pagination), we should NOT re-advertise deferred props
  assert !string.contains(body, "deferredProps")
  assert !string.contains(body, "expensive_data")
}

// Props type with multiple deferred fields for group testing
type MultiDeferredProps {
  MultiDeferredProps(
    page: String,
    default_prop: option.Option(String),
    quick_prop: option.Option(String),
    slow_prop1: option.Option(String),
    slow_prop2: option.Option(String),
  )
}

fn encode_multi_deferred_props(
  props: MultiDeferredProps,
) -> dict.Dict(String, json.Json) {
  let base = dict.from_list([#("page", json.string(props.page))])

  let with_default = case props.default_prop {
    option.Some(value) -> dict.insert(base, "default_prop", json.string(value))
    option.None -> base
  }

  let with_quick = case props.quick_prop {
    option.Some(value) ->
      dict.insert(with_default, "quick_prop", json.string(value))
    option.None -> with_default
  }

  let with_slow1 = case props.slow_prop1 {
    option.Some(value) ->
      dict.insert(with_quick, "slow_prop1", json.string(value))
    option.None -> with_quick
  }

  case props.slow_prop2 {
    option.Some(value) ->
      dict.insert(with_slow1, "slow_prop2", json.string(value))
    option.None -> with_slow1
  }
}

// Test: Multiple deferred prop groups generate correct metadata
pub fn multiple_deferred_prop_groups_test() {
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")

  let initial_props =
    MultiDeferredProps(
      page: "Dashboard",
      default_prop: option.None,
      quick_prop: option.None,
      slow_prop1: option.None,
      slow_prop2: option.None,
    )

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(initial_props, encode_multi_deferred_props)
    // One prop in default group
    |> response_builder.defer("default_prop", fn(props) {
      Ok(
        MultiDeferredProps(..props, default_prop: option.Some("default-value")),
      )
    })
    // One prop in "quick" group
    |> response_builder.defer_in_group("quick_prop", "quick", fn(props) {
      Ok(MultiDeferredProps(..props, quick_prop: option.Some("quick-value")))
    })
    // Two props in "slow" group
    |> response_builder.defer_in_group("slow_prop1", "slow", fn(props) {
      Ok(MultiDeferredProps(..props, slow_prop1: option.Some("slow-value-1")))
    })
    |> response_builder.defer_in_group("slow_prop2", "slow", fn(props) {
      Ok(MultiDeferredProps(..props, slow_prop2: option.Some("slow-value-2")))
    })
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // Page should be included (not deferred)
  assert body |> string.contains("Dashboard")

  // None of the deferred values should be included
  assert !string.contains(body, "default-value")
  assert !string.contains(body, "quick-value")
  assert !string.contains(body, "slow-value-1")
  assert !string.contains(body, "slow-value-2")

  // Response should contain deferredProps metadata
  assert body |> string.contains("deferredProps")

  // Should contain all three groups: "default", "quick", "slow"
  assert body |> string.contains("\"default\"")
  assert body |> string.contains("\"quick\"")
  assert body |> string.contains("\"slow\"")

  // Verify group memberships
  // default_prop should be in "default" group
  assert body |> string.contains("default_prop")

  // quick_prop should be in "quick" group
  assert body |> string.contains("quick_prop")

  // Both slow props should be in "slow" group
  assert body |> string.contains("slow_prop1")
  assert body |> string.contains("slow_prop2")
}

// Test: Partial reload for deferred group does NOT re-advertise deferred props
pub fn deferred_group_partial_reload_no_readvertise_test() {
  // Simulate a request for the "slow" deferred group
  let req =
    simulate.request(http.Get, "/dashboard")
    |> simulate.header("x-inertia", "true")
    |> simulate.header("x-inertia-partial-component", "Dashboard")
    |> simulate.header("x-inertia-partial-data", "slow_prop1,slow_prop2")

  let initial_props =
    MultiDeferredProps(
      page: "Dashboard",
      default_prop: option.None,
      quick_prop: option.None,
      slow_prop1: option.None,
      slow_prop2: option.None,
    )

  let response =
    response_builder.response_builder(req, "Dashboard")
    |> response_builder.props(initial_props, encode_multi_deferred_props)
    |> response_builder.defer("default_prop", fn(props) {
      Ok(
        MultiDeferredProps(..props, default_prop: option.Some("default-value")),
      )
    })
    |> response_builder.defer_in_group("quick_prop", "quick", fn(props) {
      Ok(MultiDeferredProps(..props, quick_prop: option.Some("quick-value")))
    })
    |> response_builder.defer_in_group("slow_prop1", "slow", fn(props) {
      Ok(MultiDeferredProps(..props, slow_prop1: option.Some("slow-value-1")))
    })
    |> response_builder.defer_in_group("slow_prop2", "slow", fn(props) {
      Ok(MultiDeferredProps(..props, slow_prop2: option.Some("slow-value-2")))
    })
    |> response_builder.response(200)

  let body = simulate.read_body(response)

  // The "page" prop should NOT be included (not requested in partial reload)
  // Note: Don't check for "Dashboard" as it appears as the component name in metadata
  assert !string.contains(body, "\"page\"")

  // The requested slow props SHOULD be evaluated and included
  assert body |> string.contains("slow-value-1")
  assert body |> string.contains("slow-value-2")

  // Other deferred values should NOT be included
  assert !string.contains(body, "default-value")
  assert !string.contains(body, "quick-value")

  // CRITICAL: deferredProps metadata should NOT be included
  // When resolving a deferred group, we should NOT re-advertise deferred props
  assert !string.contains(body, "deferredProps")
  assert !string.contains(body, "\"default\"")
  assert !string.contains(body, "\"quick\"")
  assert !string.contains(body, "\"slow\"")
}
