import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/list
import gleam/option
import gleam/string_tree
import gleeunit
import gleeunit/should
import inertia_wisp/inertia
import inertia_wisp/testing
import wisp
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Test inertia_request creation

pub fn inertia_request_creation_test() {
  let req = testing.inertia_request()
  
  // Should have correct method and path
  req.method |> should.equal(http.Get)
  req.path |> should.equal("/")
  
  // Should have required Inertia headers
  list.contains(req.headers, #("accept", "application/json")) |> should.equal(True)
  list.contains(req.headers, #("x-inertia", "true")) |> should.equal(True)
  list.contains(req.headers, #("x-inertia-version", "1")) |> should.equal(True)
}

// Test partial_data function

pub fn partial_data_header_test() {
  let req = testing.inertia_request()
    |> testing.partial_data(["posts", "comments", "user"])
  
  list.contains(req.headers, #("x-inertia-partial-data", "posts,comments,user")) |> should.equal(True)
}

pub fn partial_data_empty_list_test() {
  let req = testing.inertia_request()
    |> testing.partial_data([])
  
  list.contains(req.headers, #("x-inertia-partial-data", "")) |> should.equal(True)
}

pub fn partial_data_single_item_test() {
  let req = testing.inertia_request()
    |> testing.partial_data(["single_prop"])
  
  list.contains(req.headers, #("x-inertia-partial-data", "single_prop")) |> should.equal(True)
}

// Test JSON response parsing

pub fn json_response_component_extraction_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("title", json.string("Test"))
    |> inertia.render("JsonTestComponent")
  })
  
  testing.component(response) |> should.equal(Ok("JsonTestComponent"))
}

pub fn json_response_prop_extraction_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("string_prop", json.string("test string"))
    |> inertia.assign_prop("int_prop", json.int(42))
    |> inertia.assign_prop("bool_prop", json.bool(True))
    |> inertia.assign_prop("array_prop", json.array([json.string("a"), json.string("b")], fn(x) { x }))
    |> inertia.render("PropTestComponent")
  })
  
  testing.prop(response, "string_prop", decode.string) |> should.equal(Ok("test string"))
  testing.prop(response, "int_prop", decode.int) |> should.equal(Ok(42))
  testing.prop(response, "bool_prop", decode.bool) |> should.equal(Ok(True))
  testing.prop(response, "array_prop", decode.list(decode.string)) |> should.equal(Ok(["a", "b"]))
}

pub fn json_response_url_extraction_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.render("UrlTestComponent")
  })
  
  testing.url(response) |> should.equal(Ok("/"))
}

pub fn json_response_version_extraction_test() {
  let req = wisp_testing.request(
    http.Get,
    "/",
    [
      #("accept", "application/json"),
      #("x-inertia", "true"),
      #("x-inertia-version", "test-version"),
    ],
    <<"">>
  )
  let config = inertia.config(version: "test-version", ssr: False, encrypt_history: False)
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.render("VersionTestComponent")
  })
  
  testing.version(response) |> should.equal(Ok("test-version"))
}

// Test HTML response parsing (initial page loads)

pub fn html_response_component_extraction_test() {
  let req = wisp_testing.request(http.Get, "/test", [], <<"">>)
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("title", json.string("HTML Test"))
    |> inertia.render("HtmlTestComponent")
  })
  
  testing.component(response) |> should.equal(Ok("HtmlTestComponent"))
}

pub fn html_response_prop_extraction_test() {
  let req = wisp_testing.request(http.Get, "/test", [], <<"">>)
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("html_string", json.string("html test string"))
    |> inertia.assign_prop("html_number", json.int(123))
    |> inertia.assign_prop("html_bool", json.bool(False))
    |> inertia.render("HtmlPropTestComponent")
  })
  
  testing.prop(response, "html_string", decode.string) |> should.equal(Ok("html test string"))
  testing.prop(response, "html_number", decode.int) |> should.equal(Ok(123))
  testing.prop(response, "html_bool", decode.bool) |> should.equal(Ok(False))
}

pub fn html_response_url_extraction_test() {
  let req = wisp_testing.request(http.Get, "/html-test", [], <<"">>)
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.render("HtmlUrlTestComponent")
  })
  
  testing.url(response) |> should.equal(Ok("/html-test"))
}

// Test error cases

pub fn missing_component_test() {
  // Create a mock response without proper Inertia data
  let response = wisp.response(200)
    |> wisp.set_body(wisp.Text(string_tree.from_string("Not an Inertia response")))
  
  testing.component(response) |> should.be_error()
}

pub fn missing_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("existing_prop", json.string("exists"))
    |> inertia.render("TestComponent")
  })
  
  testing.prop(response, "existing_prop", decode.string) |> should.equal(Ok("exists"))
  testing.prop(response, "missing_prop", decode.string) |> should.be_error()
}

pub fn wrong_prop_type_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("string_prop", json.string("not a number"))
    |> inertia.render("TestComponent")
  })
  
  // Should fail when trying to decode string as int
  testing.prop(response, "string_prop", decode.int) |> should.be_error()
}

// Test complex data structures

pub fn nested_object_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let user_data = json.object([
    #("id", json.int(1)),
    #("name", json.string("John")),
    #("profile", json.object([
      #("email", json.string("john@example.com")),
      #("settings", json.object([
        #("theme", json.string("dark")),
        #("notifications", json.bool(True))
      ]))
    ]))
  ])
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("user", user_data)
    |> inertia.render("UserComponent")
  })
  
  testing.prop(response, "user", decode.at(["id"], decode.int)) |> should.equal(Ok(1))
  testing.prop(response, "user", decode.at(["name"], decode.string)) |> should.equal(Ok("John"))
  testing.prop(response, "user", decode.at(["profile", "email"], decode.string)) 
    |> should.equal(Ok("john@example.com"))
  testing.prop(response, "user", decode.at(["profile", "settings", "theme"], decode.string)) 
    |> should.equal(Ok("dark"))
  testing.prop(response, "user", decode.at(["profile", "settings", "notifications"], decode.bool)) 
    |> should.equal(Ok(True))
}

pub fn array_of_objects_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let items = json.array([
    json.object([#("id", json.int(1)), #("name", json.string("Item 1"))]),
    json.object([#("id", json.int(2)), #("name", json.string("Item 2"))]),
    json.object([#("id", json.int(3)), #("name", json.string("Item 3"))])
  ], fn(x) { x })
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("items", items)
    |> inertia.render("ItemsComponent")
  })
  
  testing.prop(response, "items", decode.list(decode.at(["id"], decode.int)))
    |> should.equal(Ok([1, 2, 3]))
  testing.prop(response, "items", decode.list(decode.at(["name"], decode.string)))
    |> should.equal(Ok(["Item 1", "Item 2", "Item 3"]))
}

// Test HTML entity unescaping

pub fn html_entity_unescaping_test() {
  let req = wisp_testing.request(http.Get, "/test", [], <<"">>)
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("quotes", json.string("\"Hello\""))
    |> inertia.assign_prop("apostrophe", json.string("It's working"))
    |> inertia.assign_prop("html_tags", json.string("<div>test</div>"))
    |> inertia.assign_prop("ampersand", json.string("Tom & Jerry"))
    |> inertia.render("EscapeTestComponent")
  })
  
  // The testing utilities should properly unescape HTML entities
  testing.prop(response, "quotes", decode.string) |> should.equal(Ok("\"Hello\""))
  testing.prop(response, "apostrophe", decode.string) |> should.equal(Ok("It's working"))
  testing.prop(response, "html_tags", decode.string) |> should.equal(Ok("<div>test</div>"))
  testing.prop(response, "ampersand", decode.string) |> should.equal(Ok("Tom & Jerry"))
}