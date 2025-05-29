import gleam/dict
import gleam/dynamic/decode
import gleam/http
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleeunit
import gleeunit/should
import inertia_wisp/inertia
import inertia_wisp/testing
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Test version mismatch handling

pub fn version_mismatch_forces_redirect_test() {
  // Create Inertia request with mismatched version
  let req = wisp_testing.request(
    http.Get,
    "/users",
    [
      #("accept", "application/json"),
      #("x-inertia", "true"),
      #("x-inertia-version", "old-version"),
    ],
    <<"">>
  )
  let config = inertia.config(version: "new-version", ssr: False, encrypt_history: False)
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("users", json.array([json.string("user1")], fn(x) { x }))
    |> inertia.render("UsersList")
  })
  
  // Should force a full page reload due to version mismatch
  response.status |> should.equal(409)
  list.contains(response.headers, #("x-inertia-location", "/users")) |> should.equal(True)
}

pub fn version_match_returns_json_test() {
  let req = wisp_testing.request(
    http.Get,
    "/users",
    [
      #("accept", "application/json"),
      #("x-inertia", "true"),
      #("x-inertia-version", "v1.0.0"),
    ],
    <<"">>
  )
  let config = inertia.config(version: "v1.0.0", ssr: False, encrypt_history: False)
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("users", json.array([json.string("user1")], fn(x) { x }))
    |> inertia.render("UsersList")
  })
  
  // Should return JSON response when versions match
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("UsersList"))
  testing.prop(response, "users", decode.list(decode.string)) |> should.equal(Ok(["user1"]))
}

pub fn missing_version_header_test() {
  // Create Inertia request without version header
  let req = wisp_testing.request(
    http.Get,
    "/test",
    [
      #("accept", "application/json"),
      #("x-inertia", "true"),
    ],
    <<"">>
  )
  let config = inertia.config(version: "v1.0.0", ssr: False, encrypt_history: False)
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("data", json.string("test data"))
    |> inertia.render("TestPage")
  })
  
  // Should still work, treating missing version as valid
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("TestPage"))
}

// Test empty and null prop values

pub fn empty_props_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("empty_string", json.string(""))
    |> inertia.assign_prop("empty_array", json.array([], fn(x) { x }))
    |> inertia.assign_prop("empty_object", json.object([]))
    |> inertia.assign_prop("null_value", json.null())
    |> inertia.render("EmptyPropsPage")
  })
  
  testing.component(response) |> should.equal(Ok("EmptyPropsPage"))
  testing.prop(response, "empty_string", decode.string) |> should.equal(Ok(""))
  testing.prop(response, "empty_array", decode.list(decode.string)) |> should.equal(Ok([]))
  testing.prop(response, "empty_object", decode.dict(decode.string, decode.string)) |> should.equal(Ok(dict.new()))
  testing.prop(response, "null_value", decode.optional(decode.string)) |> should.equal(Ok(option.None))
}

// Test large data payloads

pub fn large_props_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  // Create a large array
  let large_data = json.array(
    list.range(1, 1000) |> list.map(fn(i) { 
      json.object([
        #("id", json.int(i)),
        #("name", json.string("Item " <> int.to_string(i))),
        #("data", json.string("Some data for item " <> int.to_string(i)))
      ])
    }),
    fn(x) { x }
  )
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("items", large_data)
    |> inertia.assign_prop("count", json.int(1000))
    |> inertia.render("LargeDataPage")
  })
  
  testing.component(response) |> should.equal(Ok("LargeDataPage"))
  testing.prop(response, "count", decode.int) |> should.equal(Ok(1000))
  // Test that we can extract data from the large payload
  testing.prop(response, "items", decode.list(decode.at(["id"], decode.int))) 
    |> should.equal(Ok(list.range(1, 1000)))
}

// Test special characters and encoding

pub fn special_characters_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("unicode", json.string("Hello 世界 🌍"))
    |> inertia.assign_prop("quotes", json.string("\"Double quotes\" and 'single quotes'"))
    |> inertia.assign_prop("html_entities", json.string("<script>alert('xss')</script>"))
    |> inertia.assign_prop("newlines", json.string("Line 1\nLine 2\rLine 3"))
    |> inertia.render("SpecialCharsPage")
  })
  
  testing.component(response) |> should.equal(Ok("SpecialCharsPage"))
  testing.prop(response, "unicode", decode.string) |> should.equal(Ok("Hello 世界 🌍"))
  testing.prop(response, "quotes", decode.string) |> should.equal(Ok("\"Double quotes\" and 'single quotes'"))
  testing.prop(response, "html_entities", decode.string) |> should.equal(Ok("<script>alert('xss')</script>"))
  testing.prop(response, "newlines", decode.string) |> should.equal(Ok("Line 1\nLine 2\rLine 3"))
}

// Test request without inertia headers but with accept: application/json

pub fn json_request_without_inertia_header_test() {
  let req = wisp_testing.request(
    http.Get,
    "/api/data",
    [
      #("accept", "application/json"),
    ],
    <<"">>
  )
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("api_data", json.string("API response"))
    |> inertia.render("ApiPage")
  })
  
  // Should treat as regular request and return HTML
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("ApiPage"))
  testing.prop(response, "api_data", decode.string) |> should.equal(Ok("API response"))
}

// Test prop overwriting

pub fn prop_overwriting_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("title", json.string("Original Title"))
    |> inertia.assign_prop("title", json.string("Updated Title"))
    |> inertia.assign_prop("count", json.int(1))
    |> inertia.assign_prop("count", json.int(2))
    |> inertia.render("OverwritePage")
  })
  
  testing.component(response) |> should.equal(Ok("OverwritePage"))
  // Should use the latest assigned values
  testing.prop(response, "title", decode.string) |> should.equal(Ok("Updated Title"))
  testing.prop(response, "count", decode.int) |> should.equal(Ok(2))
}

// Test mixed prop types (always, regular, lazy, optional)

pub fn mixed_prop_types_partial_request_test() {
  let req = testing.inertia_request()
    |> testing.partial_data(["regular_prop", "lazy_prop"])
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_always_prop("always_prop", json.string("always included"))
    |> inertia.assign_prop("regular_prop", json.string("included in partial"))
    |> inertia.assign_prop("other_regular_prop", json.string("not requested"))
    |> inertia.assign_lazy_prop("lazy_prop", fn() { json.string("lazy included") })
    |> inertia.assign_lazy_prop("other_lazy_prop", fn() { json.string("lazy not requested") })
    |> inertia.assign_optional_prop("optional_prop", json.string("never included"))
    |> inertia.assign_always_lazy_prop("always_lazy_prop", fn() { json.string("always lazy") })
    |> inertia.render("MixedPropsPage")
  })
  
  testing.component(response) |> should.equal(Ok("MixedPropsPage"))
  
  // Always props should be included
  testing.prop(response, "always_prop", decode.string) |> should.equal(Ok("always included"))
  testing.prop(response, "always_lazy_prop", decode.string) |> should.equal(Ok("always lazy"))
  
  // Requested props should be included
  testing.prop(response, "regular_prop", decode.string) |> should.equal(Ok("included in partial"))
  testing.prop(response, "lazy_prop", decode.string) |> should.equal(Ok("lazy included"))
  
  // Non-requested props should not be included
  testing.prop(response, "other_regular_prop", decode.string) |> should.be_error()
  testing.prop(response, "other_lazy_prop", decode.string) |> should.be_error()
  testing.prop(response, "optional_prop", decode.string) |> should.be_error()
}

// Test error accumulation

pub fn multiple_errors_accumulation_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_error("field1", "Error 1")
    |> inertia.assign_error("field2", "Error 2")
    |> inertia.assign_errors(dict.from_list([
      #("field3", "Error 3"),
      #("field4", "Error 4")
    ]))
    |> inertia.assign_error("field1", "Updated Error 1")  // Should overwrite
    |> inertia.render("ErrorsPage")
  })
  
  testing.component(response) |> should.equal(Ok("ErrorsPage"))
  testing.prop(response, "errors", decode.at(["field1"], decode.string)) |> should.equal(Ok("Updated Error 1"))
  testing.prop(response, "errors", decode.at(["field2"], decode.string)) |> should.equal(Ok("Error 2"))
  testing.prop(response, "errors", decode.at(["field3"], decode.string)) |> should.equal(Ok("Error 3"))
  testing.prop(response, "errors", decode.at(["field4"], decode.string)) |> should.equal(Ok("Error 4"))
}

// Test deeply nested data structures

pub fn deeply_nested_data_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()
  
  let nested_data = json.object([
    #("level1", json.object([
      #("level2", json.object([
        #("level3", json.object([
          #("level4", json.object([
            #("value", json.string("deep value")),
            #("array", json.array([
              json.object([#("item", json.string("nested item 1"))]),
              json.object([#("item", json.string("nested item 2"))])
            ], fn(x) { x }))
          ]))
        ]))
      ]))
    ]))
  ])
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("nested", nested_data)
    |> inertia.render("NestedDataPage")
  })
  
  testing.component(response) |> should.equal(Ok("NestedDataPage"))
  testing.prop(response, "nested", decode.at(["level1", "level2", "level3", "level4", "value"], decode.string))
    |> should.equal(Ok("deep value"))
  testing.prop(response, "nested", decode.at(["level1", "level2", "level3", "level4", "array"], decode.list(decode.at(["item"], decode.string))))
    |> should.equal(Ok(["nested item 1", "nested item 2"]))
}

// Test context modification chains

pub fn context_modification_chain_test() {
  let req = testing.inertia_request()
  let config = inertia.config(version: "1", ssr: False, encrypt_history: False)
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.set_config(inertia.config(version: "2.0.0", ssr: True, encrypt_history: True))
    |> inertia.enable_ssr()
    |> inertia.encrypt_history()
    |> inertia.clear_history()
    |> inertia.assign_prop("data", json.string("chained modifications"))
    |> inertia.render("ChainedPage")
  })
  
  testing.component(response) |> should.equal(Ok("ChainedPage"))
  testing.prop(response, "data", decode.string) |> should.equal(Ok("chained modifications"))
  testing.version(response) |> should.equal(Ok("2.0.0"))
  
  // Check that history flags are set in JSON
  testing.encrypt_history(response) |> should.equal(Ok(True))
  testing.clear_history(response) |> should.equal(Ok(True))
}