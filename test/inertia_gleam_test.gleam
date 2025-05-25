import gleam/dict
import gleam/http
import gleam/http/request
import gleam/io
import gleam/json
import gleam/string
import gleeunit
import gleeunit/should
import inertia_gleam
import inertia_gleam/html
import inertia_gleam/json as inertia_json
import inertia_gleam/testing
import inertia_gleam/types.{EagerProp}

import wisp

pub fn main() {
  gleeunit.main()
}

// Mock request for testing
fn mock_request() -> wisp.Request {
  let body = wisp.create_canned_connection(<<>>, "test_secret_key")
  let request =
    request.new()
    |> request.set_header("x-inertia", "true")
    |> request.set_header("Content-Type", "application/json")
    |> request.set_method(http.Get)
    |> request.set_path("/")
    |> request.set_body(body)

  request
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

  let body = testing.get_response_body(response)
  io.debug(body)

  // The lazy prop should be evaluated in the response
  testing.assert_string_prop(response, "expensive_data", "calculated_value")
  |> should.be_ok
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
  testing.assert_string_prop(response, "eager", "eager_value") |> should.be_ok
  testing.assert_string_prop(response, "lazy", "lazy_value") |> should.be_ok
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
  testing.assert_component(response, "TestComponent") |> should.be_ok

  // Test prop assertions
  testing.assert_string_prop(response, "title", "Test Page") |> should.be_ok
  testing.assert_int_prop(response, "count", 42) |> should.be_ok
}

pub fn testing_no_prop_test() {
  let req = mock_request()
  let response =
    inertia_gleam.context(req)
    |> inertia_gleam.assign_prop("existing", json.string("value"))
    |> inertia_gleam.render("TestComponent")

  // Should find existing prop
  let assert Ok(_) = testing.assert_string_prop(response, "existing", "value")

  // Should not find non-existing prop
  let assert Ok(_) = testing.assert_no_prop(response, "non_existing")
}
