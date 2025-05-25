import gleam/dict
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/json
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import inertia_gleam
import inertia_gleam/html
import inertia_gleam/json as inertia_json
import inertia_gleam/testing
import inertia_gleam/types.{EagerProp}

import wisp
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Mock request for testing
fn mock_request() -> wisp.Request {
  testing.inertia_request()
}

fn should_contain(haystack: String, needle: String) {
  string.contains(haystack, needle) |> should.be_true()
}

fn should_not_contain(haystack: String, needle: String) {
  string.contains(haystack, needle) |> should.be_false()
}

// Test basic configuration
pub fn default_config_test() {
  let config = inertia_gleam.default_config()
  config.version |> should.equal("1")
  config.ssr |> should.equal(False)
}

pub fn custom_config_test() {
  let config = inertia_gleam.config("2.0", True)
  config.version |> should.equal("2.0")
  config.ssr |> should.equal(True)
}

// Test prop helpers
pub fn string_prop_test() {
  let prop = inertia_gleam.string_prop("test")
  json.to_string(prop) |> should.equal("\"test\"")
}

pub fn int_prop_test() {
  let prop = inertia_gleam.int_prop(42)
  json.to_string(prop) |> should.equal("42")
}

pub fn bool_prop_test() {
  let prop = inertia_gleam.bool_prop(True)
  json.to_string(prop) |> should.equal("true")
}

pub fn props_from_list_test() {
  let props =
    inertia_gleam.props_from_list([
      #("name", inertia_gleam.string_prop("John")),
      #("age", inertia_gleam.int_prop(30)),
      #("active", inertia_gleam.bool_prop(True)),
    ])

  dict.size(props) |> should.equal(3)
  dict.has_key(props, "name") |> should.equal(True)
  dict.has_key(props, "age") |> should.equal(True)
  dict.has_key(props, "active") |> should.equal(True)
}

// Test page creation
pub fn new_page_test() {
  let props = dict.from_list([#("title", json.string("Test Page"))])

  let page = types.new_page("TestComponent", props, "/test", "1.0")

  page.component |> should.equal("TestComponent")
  page.url |> should.equal("/test")
  page.version |> should.equal("1.0")
}

// Test JSON encoding
pub fn encode_page_test() {
  let props =
    dict.from_list([#("message", json.string("Hello")), #("count", json.int(5))])

  let page =
    types.Page(
      component: "TestComponent",
      props: props,
      url: "/test",
      version: "1",
    )

  let encoded = inertia_json.encode_page(page)
  let json_string = json.to_string(encoded)

  // Should contain all required fields
  json_string |> should_contain("\"component\":\"TestComponent\"")
  json_string |> should_contain("\"url\":\"/test\"")
  json_string |> should_contain("\"version\":\"1\"")
  json_string |> should_contain("\"props\"")
}

// Test HTML generation
pub fn root_template_test() {
  let props = dict.new()
  let page = types.Page(component: "Home", props: props, url: "/", version: "1")

  let html = html.root_template(page, "Test App")

  html |> should_contain("<!DOCTYPE html>")
  html |> should_contain("<title>Test App</title>")
  html |> should_contain("<div id=\"app\"")
  html |> should_contain("data-page=")
}

pub fn app_template_test() {
  let props = dict.new()
  let page = types.Page(component: "Home", props: props, url: "/", version: "1")

  let html = html.app_template(page)

  html |> should_contain("<div id=\"app\"")
  html |> should_contain("data-page=")
  html |> should_not_contain("<!DOCTYPE html>")
}

// Test JSON helpers
pub fn string_list_to_json_test() {
  let json_array = inertia_json.string_list_to_json(["a", "b", "c"])
  json.to_string(json_array) |> should.equal("[\"a\",\"b\",\"c\"]")
}

pub fn int_list_to_json_test() {
  let json_array = inertia_json.int_list_to_json([1, 2, 3])
  json.to_string(json_array) |> should.equal("[1,2,3]")
}

// Test initial state
pub fn initial_state_test() {
  let state = types.initial_state()

  state.is_inertia |> should.equal(False)
  state.partial_data |> should.equal([])
  dict.size(state.props) |> should.equal(0)
}

// Test context-based prop assignment
pub fn context_creation_test() {
  let req = mock_request()
  let ctx = inertia_gleam.context(req)

  dict.size(ctx.props) |> should.equal(0)
}

pub fn assign_prop_test() {
  let req = mock_request()
  let ctx =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_prop("name", inertia_gleam.string_prop("Alice"))

  dict.size(ctx.props) |> should.equal(1)
  dict.has_key(ctx.props, "name") |> should.equal(True)
}

pub fn assign_multiple_props_test() {
  let req = mock_request()
  let ctx =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_prop("name", inertia_gleam.string_prop("Alice"))
    |> inertia_gleam.assign_prop("age", inertia_gleam.int_prop(30))
    |> inertia_gleam.assign_prop("active", inertia_gleam.bool_prop(True))

  dict.size(ctx.props) |> should.equal(3)
  dict.has_key(ctx.props, "name") |> should.equal(True)
  dict.has_key(ctx.props, "age") |> should.equal(True)
  dict.has_key(ctx.props, "active") |> should.equal(True)
}

pub fn assign_props_list_test() {
  let req = mock_request()
  let props_list = [
    #("title", inertia_gleam.string_prop("Test Page")),
    #("count", inertia_gleam.int_prop(42)),
  ]

  let ctx =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_props(props_list)

  dict.size(ctx.props) |> should.equal(2)
  dict.has_key(ctx.props, "title") |> should.equal(True)
  dict.has_key(ctx.props, "count") |> should.equal(True)
}

pub fn context_prop_override_test() {
  let req = mock_request()
  let ctx =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_prop("name", inertia_gleam.string_prop("Alice"))
    |> inertia_gleam.assign_prop("name", inertia_gleam.string_prop("Bob"))

  dict.size(ctx.props) |> should.equal(1)

  let prop = dict.get(ctx.props, "name")
  case prop {
    Ok(EagerProp(value)) -> json.to_string(value) |> should.equal("\"Bob\"")
    _ -> should.fail()
  }
}

// Test lazy props
pub fn assign_lazy_prop_test() {
  let req = mock_request()
  let expensive_calculation = fn() { json.string("expensive_result") }

  let ctx =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_lazy_prop("expensive_data", expensive_calculation)

  dict.size(ctx.props) |> should.equal(1)
  dict.has_key(ctx.props, "expensive_data") |> should.equal(True)
}

pub fn lazy_prop_evaluation_test() {
  let req = mock_request()
  let expensive_calculation = fn() {
    // Simulate expensive calculation
    json.string("calculated_value")
  }

  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_lazy_prop("expensive_data", expensive_calculation)
    |> inertia_gleam.render("TestComponent")

  // The lazy prop should be evaluated in the response
  testing.prop(response, "expensive_data", decode.string)
  |> should.equal(Ok("calculated_value"))
}

pub fn lazy_and_eager_props_test() {
  let req = mock_request()
  let expensive_calculation = fn() { json.string("lazy_value") }

  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_prop("eager", json.string("eager_value"))
    |> inertia_gleam.assign_lazy_prop("lazy", expensive_calculation)
    |> inertia_gleam.render("TestComponent")

  // Both props should be present
  testing.prop(response, "eager", decode.string)
  |> should.equal(Ok("eager_value"))
  testing.prop(response, "lazy", decode.string)
  |> should.equal(Ok("lazy_value"))
}

// Test always props
pub fn assign_always_prop_test() {
  let req = mock_request()
  let ctx =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_always_prop(
      "auth",
      inertia_gleam.string_prop("authenticated"),
    )

  dict.size(ctx.always_props) |> should.equal(1)
  dict.has_key(ctx.always_props, "auth") |> should.equal(True)
}

pub fn assign_always_props_test() {
  let req = mock_request()
  let always_props_list = [
    #("auth", inertia_gleam.string_prop("authenticated")),
    #("csrf_token", inertia_gleam.string_prop("abc123")),
  ]

  let ctx =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_always_props(always_props_list)

  dict.size(ctx.always_props) |> should.equal(2)
  dict.has_key(ctx.always_props, "auth") |> should.equal(True)
  dict.has_key(ctx.always_props, "csrf_token") |> should.equal(True)
}

pub fn assign_always_lazy_prop_test() {
  let req = mock_request()
  let auth_check = fn() { json.string("user_authenticated") }

  let ctx =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_always_lazy_prop("auth_status", auth_check)

  dict.size(ctx.always_props) |> should.equal(1)
  dict.has_key(ctx.always_props, "auth_status") |> should.equal(True)
}

pub fn always_props_in_response_test() {
  let req = mock_request()
  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_always_prop("auth", json.string("authenticated"))
    |> inertia_gleam.assign_prop("page_data", json.string("some_data"))
    |> inertia_gleam.render("TestComponent")

  // Both always props and regular props should be present
  testing.prop(response, "auth", decode.string)
  |> should.equal(Ok("authenticated"))
  testing.prop(response, "page_data", decode.string)
  |> should.equal(Ok("some_data"))
}

pub fn always_props_override_test() {
  let req = mock_request()
  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_always_prop("title", json.string("Default Title"))
    |> inertia_gleam.assign_prop("title", json.string("Page Title"))
    |> inertia_gleam.render("TestComponent")

  // Regular props should override always props
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Page Title"))
}

pub fn mixed_always_props_test() {
  let req = mock_request()
  let auth_calculation = fn() { json.string("lazy_auth_result") }

  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_always_prop("csrf", json.string("token123"))
    |> inertia_gleam.assign_always_lazy_prop("auth", auth_calculation)
    |> inertia_gleam.assign_prop("content", json.string("page_content"))
    |> inertia_gleam.render("TestComponent")

  // All props should be present
  testing.prop(response, "csrf", decode.string)
  |> should.equal(Ok("token123"))
  testing.prop(response, "auth", decode.string)
  |> should.equal(Ok("lazy_auth_result"))
  testing.prop(response, "content", decode.string)
  |> should.equal(Ok("page_content"))
}

pub fn partial_reload_with_always_props_test() {
  // Create a mock partial request that only wants "content" prop
  let body = wisp.create_canned_connection(<<>>, "test_secret_key")
  let req =
    request.new()
    |> request.set_header("x-inertia", "true")
    |> request.set_header("x-inertia-partial-data", "content")
    |> request.set_method(http.Get)
    |> request.set_path("/")
    |> request.set_body(body)

  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_always_prop("csrf", json.string("always_token"))
    |> inertia_gleam.assign_prop("content", json.string("requested_content"))
    |> inertia_gleam.assign_prop("sidebar", json.string("not_requested"))
    |> inertia_gleam.render("TestComponent")

  // Should only contain the requested "content" prop, not the "sidebar" prop
  // But always props should still be included even in partial requests
  testing.prop(response, "content", decode.string)
  |> should.equal(Ok("requested_content"))

  testing.prop(response, "sidebar", decode.string) |> should.be_error

  // Always props should still be present in partial requests
  testing.prop(response, "csrf", decode.string)
  |> should.equal(Ok("always_token"))
}

pub fn basic_partial_reload_test() {
  // Create a mock partial request for only "title" and "count" props
  let body = wisp.create_canned_connection(<<>>, "test_secret_key")
  let req =
    request.new()
    |> request.set_header("x-inertia", "true")
    |> request.set_header("x-inertia-partial-data", "title,count")
    |> request.set_method(http.Get)
    |> request.set_path("/")
    |> request.set_body(body)

  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_prop("title", json.string("Page Title"))
    |> inertia_gleam.assign_prop("count", json.int(42))
    |> inertia_gleam.assign_prop(
      "description",
      json.string("Should not be included"),
    )
    |> inertia_gleam.assign_prop("metadata", json.string("Also excluded"))
    |> inertia_gleam.render("TestComponent")

  // Should only contain the requested props
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Page Title"))
  testing.prop(response, "count", decode.int) |> should.equal(Ok(42))

  // Should not contain non-requested props
  testing.prop(response, "description", decode.string) |> should.be_error
}

// Test testing helpers
pub fn testing_helpers_test() {
  let req = mock_request()
  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_prop("title", json.string("Test Page"))
    |> inertia_gleam.assign_prop("count", json.int(42))
    |> inertia_gleam.render("TestComponent")

  // Test component assertion
  testing.component(response) |> should.equal(Ok("TestComponent"))

  // Test prop assertions
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Test Page"))
  testing.prop(response, "count", decode.int) |> should.equal(Ok(42))
}

pub fn testing_no_prop_test() {
  let req = mock_request()
  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_prop("existing", json.string("value"))
    |> inertia_gleam.render("TestComponent")

  // Should find existing prop
  testing.prop(response, "existing", decode.string) |> should.equal(Ok("value"))

  // Should not find non-existing prop
  testing.prop(response, "non_existing", decode.string) |> should.be_error
}

// Test form handling and validation errors
pub fn assign_errors_test() {
  let req = mock_request()
  let errors =
    dict.from_list([
      #("email", "Email is required"),
      #("password", "Password must be at least 8 characters"),
    ])

  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_errors(errors)
    |> inertia_gleam.render("LoginForm")

  // Should have errors prop
  testing.prop(response, "errors", decode.dict(decode.string, decode.string))
  |> should.be_ok
}

pub fn assign_single_error_test() {
  let req = mock_request()
  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_error("username", "Username is taken")
    |> inertia_gleam.render("SignupForm")

  // Should have errors prop with single error
  testing.prop(response, "errors", decode.dict(decode.string, decode.string))
  |> should.be_ok
}

pub fn multiple_errors_test() {
  let req = mock_request()
  let initial_errors = dict.from_list([#("email", "Email is required")])

  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_errors(initial_errors)
    |> inertia_gleam.assign_error("password", "Password is required")
    |> inertia_gleam.render("LoginForm")

  // Should have both errors
  testing.prop(response, "errors", decode.dict(decode.string, decode.string))
  |> should.be_ok
}

// Test redirect functionality
pub fn redirect_browser_request_test() {
  let req = wisp_testing.request(http.Post, "/submit", [], <<>>)
  let response = inertia_gleam.redirect(req, "/success")

  response.status |> should.equal(303)

  let location_header =
    list.find_map(response.headers, fn(header) {
      case header {
        #("location", value) -> Ok(value)
        _ -> Error(Nil)
      }
    })
  location_header |> should.equal(Ok("/success"))
}

pub fn redirect_inertia_request_test() {
  let req =
    testing.inertia_request()
    |> request.set_method(http.Post)
  let response = inertia_gleam.redirect(req, "/dashboard")

  response.status |> should.equal(303)

  let location_header =
    list.find_map(response.headers, fn(header) {
      case header {
        #("location", value) -> Ok(value)
        _ -> Error(Nil)
      }
    })
  location_header |> should.equal(Ok("/dashboard"))

  let vary_header =
    list.find_map(response.headers, fn(header) {
      case header {
        #("vary", value) -> Ok(value)
        _ -> Error(Nil)
      }
    })
  vary_header |> should.equal(Ok("X-Inertia"))
}

pub fn external_redirect_test() {
  let response = inertia_gleam.external_redirect("https://external.com")

  response.status |> should.equal(409)

  let location_header =
    list.find_map(response.headers, fn(header) {
      case header {
        #("x-inertia-location", value) -> Ok(value)
        _ -> Error(Nil)
      }
    })
  location_header |> should.equal(Ok("https://external.com"))
}

pub fn redirect_after_form_test() {
  let req =
    testing.inertia_request()
    |> request.set_method(http.Post)
  let response = inertia_gleam.redirect_after_form(req, "/success")

  response.status |> should.equal(303)

  let vary_header =
    list.find_map(response.headers, fn(header) {
      case header {
        #("vary", value) -> Ok(value)
        _ -> Error(Nil)
      }
    })
  vary_header |> should.equal(Ok("X-Inertia"))
}

// Test complete form submission workflow
pub fn form_submission_success_workflow_test() {
  let req =
    testing.inertia_request()
    |> request.set_method(http.Post)

  // Simulate successful form submission
  let response = inertia_gleam.redirect_after_form(req, "/users")

  response.status |> should.equal(303)

  let location_header =
    list.find_map(response.headers, fn(header) {
      case header {
        #("location", value) -> Ok(value)
        _ -> Error(Nil)
      }
    })
  location_header |> should.equal(Ok("/users"))
}

pub fn form_submission_with_errors_workflow_test() {
  let req =
    testing.inertia_request()
    |> request.set_method(http.Post)

  let validation_errors =
    dict.from_list([
      #("name", "Name is required"),
      #("email", "Email format is invalid"),
    ])

  // Simulate form submission with validation errors
  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_errors(validation_errors)
    |> inertia_gleam.assign_prop("name", json.string(""))
    |> inertia_gleam.assign_prop("email", json.string("invalid-email"))
    |> inertia_gleam.render("CreateUserForm")

  // Should contain the form data and errors
  testing.prop(response, "errors", decode.dict(decode.string, decode.string))
  |> should.be_ok

  testing.prop(response, "name", decode.string)
  |> should.equal(Ok(""))

  testing.prop(response, "email", decode.string)
  |> should.equal(Ok("invalid-email"))
}
