import gleam/dict
import gleam/dynamic/decode
import gleam/http/response
import gleam/json
import gleam/option
import gleam/result
import gleeunit
import gleeunit/should
import inertia_wisp/internal/types
import inertia_wisp/response_builder
import inertia_wisp/testing

pub fn main() {
  gleeunit.main()
}

// Test data types for prop encoding
pub type TestProp {
  UserData(name: String, email: String)
  CountData(count: Int)
}

pub fn encode_test_prop(prop: TestProp) -> json.Json {
  case prop {
    UserData(name, email) ->
      json.object([#("name", json.string(name)), #("email", json.string(email))])
    CountData(count) -> json.int(count)
  }
}

// Basic builder creation tests
pub fn response_builder_creates_empty_builder_test() {
  let req = testing.inertia_request()
  let response =
    req
    |> response_builder.response_builder("TestComponent")
    |> response_builder.response()

  // Should create valid response with component name
  let assert Ok("TestComponent") = testing.component(response)
}

pub fn component_sets_component_name_test() {
  let req = testing.inertia_request()
  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.response()

  // Should set component name correctly
  let assert Ok("Users/Show") = testing.component(response)
}

// Props handling tests
pub fn props_with_single_prop_test() {
  let req = testing.inertia_request()
  let props = [types.DefaultProp("user", UserData("John", "john@example.com"))]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should include the prop in the response
  let assert Ok("John") =
    testing.prop(response, "user", decode.at(["name"], decode.string))
}

pub fn props_with_multiple_props_test() {
  let req = testing.inertia_request()
  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.DefaultProp("count", CountData(42)),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Index")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should include both props in the response
  let assert Ok("John") =
    testing.prop(response, "user", decode.at(["name"], decode.string))
  let assert Ok(42) = testing.prop(response, "count", decode.int)
}

// Error handling tests
pub fn errors_sets_validation_errors_test() {
  let req = testing.inertia_request()
  let errors =
    dict.from_list([
      #("name", "Name is required"),
      #("email", "Email is invalid"),
    ])

  let response =
    req
    |> response_builder.response_builder("Users/Create")
    |> response_builder.errors(errors)
    |> response_builder.response()

  // Should include errors in the response
  let assert Ok("Name is required") =
    testing.prop(response, "errors", decode.at(["name"], decode.string))
  let assert Ok("Email is invalid") =
    testing.prop(response, "errors", decode.at(["email"], decode.string))
}

pub fn redirect_sets_redirect_url_test() {
  let req = testing.inertia_request()

  let response =
    req
    |> response_builder.response_builder("Users/Create")
    |> response_builder.redirect("/users/create")
    |> response_builder.response()

  // Should be a JSON response (redirect doesn't change response type)
  let assert Ok("application/json; charset=utf-8") =
    response.get_header(response, "content-type")
}

// Metadata tests
pub fn clear_history_sets_flag_test() {
  let req = testing.inertia_request()

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.clear_history()
    |> response_builder.response()

  // Should set clear_history flag to true
  let assert Ok(True) = testing.clear_history(response)
}

pub fn encrypt_history_sets_flag_test() {
  let req = testing.inertia_request()

  let response =
    req
    |> response_builder.response_builder("SecurePage")
    |> response_builder.encrypt_history()
    |> response_builder.response()

  // Should set encrypt_history flag to true
  let assert Ok(True) = testing.encrypt_history(response)
}

pub fn version_sets_version_string_test() {
  let req = testing.inertia_request()

  let response =
    req
    |> response_builder.response_builder("HomePage")
    |> response_builder.version("2.1.0")
    |> response_builder.response()

  // Should set version string correctly
  let assert Ok("2.1.0") = testing.version(response)
}

// Complete response building tests
pub fn response_builds_basic_response_test() {
  let req = testing.inertia_request()
  let props = [types.DefaultProp("user", UserData("John", "john@example.com"))]

  let response =
    req
    |> response_builder.response_builder("HomePage")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should build a valid response
  response
  |> response.get_header("content-type")
  |> should.equal(Ok("application/json; charset=utf-8"))
}

pub fn response_builds_error_only_response_test() {
  let req = testing.inertia_request()
  let errors = dict.from_list([#("email", "Email is required")])

  let response =
    req
    |> response_builder.response_builder("FormPage")
    |> response_builder.errors(errors)
    |> response_builder.redirect("/form")
    |> response_builder.response()

  // Should build a valid response with errors
  response
  |> response.get_header("content-type")
  |> should.equal(Ok("application/json; charset=utf-8"))
}

pub fn response_includes_props_in_json_test() {
  let req = testing.inertia_request()
  let props = [types.DefaultProp("user", UserData("John", "john@example.com"))]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should include props in JSON response
  response
  |> testing.component()
  |> should.equal(Ok("Users/Show"))
}

pub fn response_includes_errors_in_json_test() {
  let req = testing.inertia_request()
  let errors = dict.from_list([#("email", "Email is required")])

  let response =
    req
    |> response_builder.response_builder("Users/Create")
    |> response_builder.errors(errors)
    |> response_builder.redirect("/users/create")
    |> response_builder.response()

  // Should include errors in JSON response
  let assert Ok("application/json; charset=utf-8") =
    response.get_header(response, "content-type")

  // Should include the actual errors in the JSON
  let assert Ok("Email is required") =
    testing.prop(response, "errors", decode.at(["email"], decode.string))
}

// Deferred props tests
pub fn deferred_props_not_evaluated_test() {
  let req = testing.inertia_request()
  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.DeferProp("expensive", option.None, fn() {
      // This should NOT be called during response building
      panic as "Should not be evaluated"
    }),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should succeed without panic - deferred prop not evaluated
  let assert Ok("Users/Show") = testing.component(response)
}

pub fn deferred_props_included_in_json_test() {
  let req = testing.inertia_request()
  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.DeferProp("expensive", option.None, fn() { Ok(CountData(42)) }),
    types.DeferProp("analytics", option.Some("custom"), fn() {
      Ok(CountData(100))
    }),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should include deferred props metadata in JSON (at top level, not in props)
  let assert Ok(["expensive"]) =
    testing.deferred_props(response, "default", decode.list(decode.string))
  let assert Ok(["analytics"]) =
    testing.deferred_props(response, "custom", decode.list(decode.string))
}

pub fn merge_props_metadata_test() {
  let req = testing.inertia_request()
  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.MergeProp(
      types.DefaultProp("posts", CountData(5)),
      option.None,
      False,
    ),
    types.MergeProp(
      types.DefaultProp("comments", CountData(10)),
      option.None,
      False,
    ),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should include merge props metadata (at top level, not in props)
  let assert Ok(["posts", "comments"]) =
    testing.merge_props(response, decode.list(decode.string))
}

pub fn deep_merge_props_metadata_test() {
  let req = testing.inertia_request()
  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.MergeProp(
      types.DefaultProp("nested", CountData(5)),
      option.None,
      True,
    ),
    types.MergeProp(types.DefaultProp("deep", CountData(10)), option.None, True),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should include deep merge props metadata (at top level, not in props)
  let assert Ok(["nested", "deep"]) =
    testing.deep_merge_props(response, decode.list(decode.string))
}

pub fn match_props_on_metadata_test() {
  let req = testing.inertia_request()
  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.MergeProp(
      types.DefaultProp("posts", CountData(5)),
      option.Some(["id", "slug"]),
      False,
    ),
    types.MergeProp(
      types.DefaultProp("comments", CountData(10)),
      option.Some(["user_id"]),
      True,
    ),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Index")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should include match props on metadata (at top level, not in props)
  let assert Ok(["posts.slug", "posts.id", "comments.user_id"]) =
    testing.match_props_on(response, decode.list(decode.string))
}

pub fn mixed_advanced_props_test() {
  let req = testing.inertia_request()
  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.DeferProp("expensive", option.None, fn() { Ok(CountData(42)) }),
    types.MergeProp(
      types.DeferProp("analytics", option.Some("custom"), fn() {
        Ok(CountData(100))
      }),
      option.None,
      False,
    ),
    types.MergeProp(
      types.DefaultProp("nested", CountData(5)),
      option.Some(["id"]),
      deep: True,
    ),
  ]

  let response =
    req
    |> response_builder.response_builder("Dashboard")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should handle mixed deferred and merge props correctly (at top level, not in props)
  let assert Ok(["expensive"]) =
    testing.deferred_props(response, "default", decode.list(decode.string))
  let assert Ok(["analytics"]) =
    testing.deferred_props(response, "custom", decode.list(decode.string))

  // Should NOT include deferred prop in mergeProps initially
  assert result.is_error(testing.merge_props(
    response,
    decode.list(decode.string),
  ))

  let assert Ok(["nested"]) =
    testing.deep_merge_props(response, decode.list(decode.string))
  let assert Ok(["nested.id"]) =
    testing.match_props_on(response, decode.list(decode.string))
}

// Partial reload tests
pub fn partial_reload_component_match_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user"])
    |> testing.partial_component("Users/Show")

  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.DefaultProp("message", CountData(42)),
    types.AlwaysProp("count", CountData(100)),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Component match should respect partial reload
  // Should include: user (requested) + count (AlwaysProp) = 2 props
  let assert Ok("John") =
    testing.prop(response, "user", decode.at(["name"], decode.string))
  let assert Ok(100) = testing.prop(response, "count", decode.int)

  // Should NOT include message (not requested, not AlwaysProp)
  assert result.is_error(testing.prop(response, "message", decode.int))
}

pub fn partial_reload_component_mismatch_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user"])
    |> testing.partial_component("DifferentComponent")

  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.DefaultProp("message", CountData(42)),
    types.AlwaysProp("count", CountData(100)),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Component mismatch should ignore partial reload and include all non-optional props
  let assert Ok("John") =
    testing.prop(response, "user", decode.at(["name"], decode.string))
  let assert Ok(42) = testing.prop(response, "message", decode.int)
  let assert Ok(100) = testing.prop(response, "count", decode.int)
}

pub fn partial_reload_always_props_included_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["specific"])
    |> testing.partial_component("Users/Index")

  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.DefaultProp("specific", CountData(42)),
    types.AlwaysProp("always1", CountData(100)),
    types.AlwaysProp("always2", CountData(200)),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Index")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should include requested prop + all AlwaysProps
  let assert Ok(42) = testing.prop(response, "specific", decode.int)
  let assert Ok(100) = testing.prop(response, "always1", decode.int)
  let assert Ok(200) = testing.prop(response, "always2", decode.int)

  // Should NOT include non-requested DefaultProp
  assert result.is_error(testing.prop(
    response,
    "user",
    decode.at(["name"], decode.string),
  ))
}

pub fn partial_reload_optional_props_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["optional"])
    |> testing.partial_component("Users/Index")

  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.OptionalProp("optional", fn() { Ok(CountData(42)) }),
    types.AlwaysProp("always", CountData(100)),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Index")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should include requested OptionalProp + AlwaysProp
  // Should include requested OptionalProp + AlwaysProps, exclude others
  let assert Ok(42) = testing.prop(response, "optional", decode.int)
  let assert Ok(100) = testing.prop(response, "always", decode.int)

  // Should NOT include non-requested DefaultProp
  assert result.is_error(testing.prop(
    response,
    "user",
    decode.at(["name"], decode.string),
  ))
}

pub fn partial_reload_no_component_header_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user", "settings"])
  // No partial_component header

  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.DefaultProp("message", CountData(42)),
    types.AlwaysProp("count", CountData(100)),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // No component header means no partial reload - should include all non-optional props
  let assert Ok("John") =
    testing.prop(response, "user", decode.at(["name"], decode.string))
  let assert Ok(42) = testing.prop(response, "message", decode.int)
  let assert Ok(100) = testing.prop(response, "count", decode.int)
}

pub fn partial_reload_deferred_props_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["expensive"])
    |> testing.partial_component("Users/Show")

  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.DeferProp("expensive", option.None, fn() { Ok(CountData(42)) }),
    types.AlwaysProp("always", CountData(100)),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should evaluate and return the requested deferred prop as a regular prop
  let assert Ok(42) = testing.prop(response, "expensive", decode.int)

  // Should include AlwaysProp
  let assert Ok(100) = testing.prop(response, "always", decode.int)

  // Should NOT include non-requested DefaultProp
  assert result.is_error(testing.prop(
    response,
    "user",
    decode.at(["name"], decode.string),
  ))

  // Should NOT include deferred prop in deferredProps metadata when it's been evaluated
  assert result.is_error(testing.deferred_props(
    response,
    "default",
    decode.list(decode.string),
  ))
}

pub fn initial_page_load_deferred_props_test() {
  let req = testing.regular_request()
  let props = [
    types.DefaultProp("user", UserData("John", "john@example.com")),
    types.DeferProp("expensive", option.None, fn() { Ok(CountData(42)) }),
    types.DeferProp("analytics", option.Some("custom"), fn() {
      Ok(CountData(100))
    }),
  ]

  let response =
    req
    |> response_builder.response_builder("Users/Show")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // Should be HTML response for initial page load
  let assert Ok("text/html; charset=utf-8") =
    response.get_header(response, "content-type")

  // Should include deferred props metadata in embedded JSON
  let assert Ok(["expensive"]) =
    testing.deferred_props(response, "default", decode.list(decode.string))
  let assert Ok(["analytics"]) =
    testing.deferred_props(response, "custom", decode.list(decode.string))

  // Should include regular props in embedded JSON
  let assert Ok("John") =
    testing.prop(response, "user", decode.at(["name"], decode.string))
}

// Fluent API chaining tests
pub fn fluent_api_chaining_test() {
  let req = testing.inertia_request()
  let props = [types.DefaultProp("user", UserData("John", "john@example.com"))]
  let errors = dict.from_list([#("name", "Name is too short")])

  let response =
    req
    |> response_builder.response_builder("Users/Edit")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.errors(errors)
    |> response_builder.version("1.0.0")
    |> response_builder.clear_history()
    |> response_builder.response()

  // Should successfully chain all builder methods
  let assert Ok("application/json; charset=utf-8") =
    response.get_header(response, "content-type")
}

pub fn test_lazy_prop_error_handling() {
  let req = testing.inertia_request()
  let error_dict = dict.from_list([#("database", "Connection failed")])
  let failing_prop = types.LazyProp("user_count", fn() { Error(error_dict) })

  let response =
    req
    |> response_builder.response_builder("Users/Index")
    |> response_builder.props([failing_prop], encode_test_prop)
    |> response_builder.on_error("Error")
    |> response_builder.response()

  // Test that the response contains the error in the props
  let assert Ok(errors) =
    testing.prop(response, "errors", decode.dict(decode.string, decode.string))
  assert dict.has_key(errors, "database")
  let assert Ok(error_message) = dict.get(errors, "database")
  assert error_message == "Connection failed"
}

pub fn test_optional_prop_error_handling() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user_analytics"])
    |> testing.partial_component("Users/Index")
  let error_dict = dict.from_list([#("analytics", "Service unavailable")])
  let failing_prop =
    types.OptionalProp("user_analytics", fn() { Error(error_dict) })

  let response =
    req
    |> response_builder.response_builder("Users/Index")
    |> response_builder.props([failing_prop], encode_test_prop)
    |> response_builder.on_error("Error")
    |> response_builder.response()

  // Test that the response contains the error in the props
  let assert Ok(errors) =
    testing.prop(response, "errors", decode.dict(decode.string, decode.string))
  assert dict.has_key(errors, "analytics")
  let assert Ok(error_message) = dict.get(errors, "analytics")
  assert error_message == "Service unavailable"
}

pub fn test_defer_prop_error_handling() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["external_data"])
    |> testing.partial_component("Users/Index")
  let error_dict = dict.from_list([#("external_api", "Timeout")])
  let failing_prop =
    types.DeferProp("external_data", option.None, fn() { Error(error_dict) })

  let response =
    req
    |> response_builder.response_builder("Users/Index")
    |> response_builder.props([failing_prop], encode_test_prop)
    |> response_builder.on_error("Error")
    |> response_builder.response()

  // Test that the response contains the error in the props
  let assert Ok(errors) =
    testing.prop(response, "errors", decode.dict(decode.string, decode.string))
  assert dict.has_key(errors, "external_api")
  let assert Ok(error_message) = dict.get(errors, "external_api")
  assert error_message == "Timeout"
}

pub fn url_without_query_params_test() {
  let req = testing.inertia_request_to("/dashboard")
  let props = [types.DefaultProp("user_count", CountData(42))]

  let response =
    req
    |> response_builder.response_builder("Dashboard/Index")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // URL should be just the path without query parameters
  let assert Ok(url) = testing.url(response)
  assert url == "/dashboard"
}

pub fn url_with_query_params_test() {
  let req = testing.inertia_request_to("/dashboard?delay=5000")
  let props = [types.DefaultProp("user_count", CountData(42))]

  let response =
    req
    |> response_builder.response_builder("Dashboard/Index")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // URL should include the query parameters
  let assert Ok(url) = testing.url(response)
  assert url == "/dashboard?delay=5000"
}

pub fn url_with_multiple_query_params_test() {
  let req = testing.inertia_request_to("/users?search=test&page=2&sort=name")
  let props = [types.DefaultProp("user_count", CountData(42))]

  let response =
    req
    |> response_builder.response_builder("Users/Index")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // URL should include all query parameters
  let assert Ok(url) = testing.url(response)
  assert url == "/users?search=test&page=2&sort=name"
}

pub fn url_with_empty_query_string_test() {
  let req = testing.inertia_request_to("/dashboard?")
  let props = [types.DefaultProp("user_count", CountData(42))]

  let response =
    req
    |> response_builder.response_builder("Dashboard/Index")
    |> response_builder.props(props, encode_test_prop)
    |> response_builder.response()

  // URL should not include empty query string
  let assert Ok(url) = testing.url(response)
  assert url == "/dashboard"
}
