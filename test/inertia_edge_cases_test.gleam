import gleam/dict
import gleam/dynamic/decode
import gleam/function
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

// Simple props type for testing
pub type TestProps {
  TestProps(
    users: List(String),
    data: String,
    api_data: String,
    title: String,
    count: Int,
    empty_string: String,
    empty_array: List(String),
    empty_object: dict.Dict(String, String),
    null_value: option.Option(String),
    items: List(TestItem),
    unicode: String,
    quotes: String,
    html_entities: String,
    newlines: String,
    nested: TestNested,
  )
}

fn users(users: List(String)) {
  #("users", fn(p) { TestProps(..p, users: users) })
}

fn data(data: String) {
  #("data", fn(p) { TestProps(..p, data: data) })
}

fn api_data(api_data: fn() -> String) {
  #("api_data", fn(p) { TestProps(..p, api_data: api_data()) })
}

fn title(title: String) {
  #("title", fn(p) { TestProps(..p, title: title) })
}

fn count(count: Int) {
  #("count", fn(p) { TestProps(..p, count: count) })
}

fn empty_string(empty_string: String) {
  #("empty_string", fn(p) { TestProps(..p, empty_string: empty_string) })
}

fn empty_array(empty_array: List(String)) {
  #("empty_array", fn(p) { TestProps(..p, empty_array: empty_array) })
}

fn empty_object(empty_object: dict.Dict(String, String)) {
  #("empty_object", fn(p) { TestProps(..p, empty_object: empty_object) })
}

fn null_value(null_value: option.Option(String)) {
  #("null_value", fn(p) { TestProps(..p, null_value: null_value) })
}

fn items(items: List(TestItem)) {
  #("items", fn(p) { TestProps(..p, items: items) })
}

fn unicode(unicode: String) {
  #("unicode", fn(p) { TestProps(..p, unicode: unicode) })
}

fn quotes(quotes: String) {
  #("quotes", fn(p) { TestProps(..p, quotes: quotes) })
}

fn html_entities(html_entities: String) {
  #("html_entities", fn(p) { TestProps(..p, html_entities: html_entities) })
}

fn newlines(newlines: String) {
  #("newlines", fn(p) { TestProps(..p, newlines: newlines) })
}

fn nested(nested: TestNested) {
  #("nested", fn(p) { TestProps(..p, nested: nested) })
}

pub type TestItem {
  TestItem(id: Int, name: String, data: String)
}

pub type TestNested {
  TestNested(level1: TestLevel1)
}

pub type TestLevel1 {
  TestLevel1(level2: TestLevel2)
}

pub type TestLevel2 {
  TestLevel2(level3: TestLevel3)
}

pub type TestLevel3 {
  TestLevel3(level4: TestLevel4)
}

pub type TestLevel4 {
  TestLevel4(value: String, array: List(TestNestedItem))
}

pub type TestNestedItem {
  TestNestedItem(item: String)
}

// Encoder for test props
pub fn test_item_to_json(item: TestItem) -> json.Json {
  json.object([
    #("id", json.int(item.id)),
    #("name", json.string(item.name)),
    #("data", json.string(item.data)),
  ])
}

pub fn test_nested_item_to_json(nested_item: TestNestedItem) -> json.Json {
  json.object([#("item", json.string(nested_item.item))])
}

pub fn test_level4_to_json(level4: TestLevel4) -> json.Json {
  json.object([
    #("value", json.string(level4.value)),
    #("array", json.array(level4.array, test_nested_item_to_json)),
  ])
}

pub fn test_level3_to_json(level3: TestLevel3) -> json.Json {
  json.object([#("level4", test_level4_to_json(level3.level4))])
}

pub fn test_level2_to_json(level2: TestLevel2) -> json.Json {
  json.object([#("level3", test_level3_to_json(level2.level3))])
}

pub fn test_level1_to_json(level1: TestLevel1) -> json.Json {
  json.object([#("level2", test_level2_to_json(level1.level2))])
}

pub fn test_nested_to_json(nested: TestNested) -> json.Json {
  json.object([#("level1", test_level1_to_json(nested.level1))])
}

pub fn test_props_to_json(props: TestProps) -> json.Json {
  json.object([
    #("users", json.array(props.users, json.string)),
    #("data", json.string(props.data)),
    #("api_data", json.string(props.api_data)),
    #("title", json.string(props.title)),
    #("count", json.int(props.count)),
    #("empty_string", json.string(props.empty_string)),
    #("empty_array", json.array(props.empty_array, json.string)),
    #(
      "empty_object",
      json.dict(props.empty_object, function.identity, json.string),
    ),
    #("null_value", json.nullable(props.null_value, json.string)),
    #("items", json.array(props.items, test_item_to_json)),
    #("unicode", json.string(props.unicode)),
    #("quotes", json.string(props.quotes)),
    #("html_entities", json.string(props.html_entities)),
    #("newlines", json.string(props.newlines)),
    #("nested", test_nested_to_json(props.nested)),
  ])
}

pub fn encode_test_props(props: TestProps) -> json.Json {
  test_props_to_json(props)
}

// Helper to create initial props
fn initial_props() -> TestProps {
  TestProps(
    users: [],
    data: "",
    api_data: "",
    title: "",
    count: 0,
    empty_string: "",
    empty_array: [],
    empty_object: dict.new(),
    null_value: option.None,
    items: [],
    unicode: "",
    quotes: "",
    html_entities: "",
    newlines: "",
    nested: TestNested(TestLevel1(TestLevel2(TestLevel3(TestLevel4("", []))))),
  )
}

// Test version mismatch handling

pub fn version_mismatch_forces_redirect_test() {
  // Create Inertia request with mismatched version
  let req =
    wisp_testing.get("/users", [
      #("accept", "application/json"),
      #("x-inertia", "true"),
      #("x-inertia-version", "old-version"),
    ])
  let config =
    inertia.config(version: "new-version", ssr: False, encrypt_history: False)

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.prop(users(["users"]))
    |> inertia.render("UsersList")
  }

  // Should force a full page reload due to version mismatch
  response.status |> should.equal(409)
  list.contains(response.headers, #("x-inertia-location", "/users"))
  |> should.equal(True)
}

pub fn version_match_returns_json_test() {
  let req =
    wisp_testing.get("/users", [
      #("accept", "application/json"),
      #("x-inertia", "true"),
      #("x-inertia-version", "v1.0.0"),
    ])
  let config =
    inertia.config(version: "v1.0.0", ssr: False, encrypt_history: False)

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.prop(users(["user1"]))
    |> inertia.render("UsersList")
  }

  // Should return JSON response when versions match
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("UsersList"))
  testing.prop(response, "users", decode.list(decode.string))
  |> should.equal(Ok(["user1"]))
}

pub fn missing_version_header_test() {
  // Create Inertia request without version header
  let req =
    wisp_testing.get("/test", [
      #("accept", "application/json"),
      #("x-inertia", "true"),
    ])
  let config =
    inertia.config(version: "v1.0.0", ssr: False, encrypt_history: False)

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.prop(data("test data"))
    |> inertia.render("TestPage")
  }

  // Should still work, treating missing version as valid
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("TestPage"))
}

// Test empty and null prop values

pub fn empty_props_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.prop(empty_string(""))
    |> inertia.prop(empty_array([]))
    |> inertia.prop(empty_object(dict.new()))
    |> inertia.prop(null_value(option.None))
    |> inertia.render("EmptyPropsPage")
  }

  testing.component(response) |> should.equal(Ok("EmptyPropsPage"))
  testing.prop(response, "empty_string", decode.string) |> should.equal(Ok(""))
  testing.prop(response, "empty_array", decode.list(decode.string))
  |> should.equal(Ok([]))
  testing.prop(
    response,
    "empty_object",
    decode.dict(decode.string, decode.string),
  )
  |> should.equal(Ok(dict.new()))
  testing.prop(response, "null_value", decode.optional(decode.string))
  |> should.equal(Ok(option.None))
}

// Test large data payloads

pub fn large_props_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  // Create a large array
  let large_data =
    list.range(1, 1000)
    |> list.map(fn(i) {
      TestItem(
        id: i,
        name: "Item " <> int.to_string(i),
        data: "Some data for item " <> int.to_string(i),
      )
    })

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.prop(items(large_data))
    |> inertia.prop(count(1000))
    |> inertia.render("LargeDataPage")
  }

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

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.prop(unicode("Hello 世界 🌍"))
    |> inertia.prop(quotes("\"Double quotes\" and 'single quotes'"))
    |> inertia.prop(html_entities("<script>alert('xss')</script>"))
    |> inertia.prop(newlines("Line 1\nLine 2\rLine 3"))
    |> inertia.render("SpecialCharsPage")
  }

  testing.component(response) |> should.equal(Ok("SpecialCharsPage"))
  testing.prop(response, "unicode", decode.string)
  |> should.equal(Ok("Hello 世界 🌍"))
  testing.prop(response, "quotes", decode.string)
  |> should.equal(Ok("\"Double quotes\" and 'single quotes'"))
  testing.prop(response, "html_entities", decode.string)
  |> should.equal(Ok("<script>alert('xss')</script>"))
  testing.prop(response, "newlines", decode.string)
  |> should.equal(Ok("Line 1\nLine 2\rLine 3"))
}

// Test request without inertia headers but with accept: application/json

pub fn json_request_without_inertia_header_test() {
  let req = wisp_testing.get("/api/data", [#("accept", "application/json")])
  let config = inertia.default_config()

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.prop(api_data(fn() { "API response" }))
    |> inertia.render("ApiPage")
  }

  // Should treat as regular request and return HTML
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("ApiPage"))
  testing.prop(response, "api_data", decode.string)
  |> should.equal(Ok("API response"))
}

// Test prop overwriting

pub fn prop_overwriting_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.prop(title("Original Title"))
    |> inertia.prop(title("Updated Title"))
    |> inertia.prop(count(1))
    |> inertia.prop(count(2))
    |> inertia.render("OverwritePage")
  }

  testing.component(response) |> should.equal(Ok("OverwritePage"))
  // Should use the latest assigned values
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Updated Title"))
  testing.prop(response, "count", decode.int) |> should.equal(Ok(2))
}

// Test mixed prop types (always, regular, optional)

pub fn mixed_prop_types_partial_request_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["title", "data"])
  let config = inertia.default_config()

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.always_prop(users(["always included"]))
    |> inertia.prop(title("included in partial"))
    |> inertia.prop(count(999))
    |> inertia.prop(data("data included"))
    |> inertia.optional_prop(api_data(fn() { "never included" }))
    |> inertia.render("MixedPropsPage")
  }

  testing.component(response) |> should.equal(Ok("MixedPropsPage"))

  // Always props should be included
  testing.prop(response, "users", decode.list(decode.string))
  |> should.equal(Ok(["always included"]))

  // Requested props should be included
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("included in partial"))
  testing.prop(response, "data", decode.string)
  |> should.equal(Ok("data included"))

  // Non-requested props should not be included
  testing.prop(response, "count", decode.int) |> should.be_error()
  testing.prop(response, "api_data", decode.string) |> should.be_error()
}

// Test error accumulation (simulated with regular props since assign_error was removed)

pub fn multiple_errors_accumulation_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let errors =
    dict.new()
    |> dict.insert("field1", "Updated Error 1")
    |> dict.insert("field2", "Error 2")
    |> dict.insert("field3", "Error 3")
    |> dict.insert("field4", "Error 4")

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.errors(errors)
    |> inertia.render("ErrorsPage")
  }

  testing.component(response) |> should.equal(Ok("ErrorsPage"))
  testing.prop(response, "errors", decode.at(["field1"], decode.string))
  |> should.equal(Ok("Updated Error 1"))
  testing.prop(response, "errors", decode.at(["field2"], decode.string))
  |> should.equal(Ok("Error 2"))
  testing.prop(response, "errors", decode.at(["field3"], decode.string))
  |> should.equal(Ok("Error 3"))
  testing.prop(response, "errors", decode.at(["field4"], decode.string))
  |> should.equal(Ok("Error 4"))
}

// Test deeply nested data structures

pub fn deeply_nested_data_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let nested_data =
    TestNested(
      TestLevel1(
        TestLevel2(
          TestLevel3(
            TestLevel4(value: "deep value", array: [
              TestNestedItem(item: "nested item 1"),
              TestNestedItem(item: "nested item 2"),
            ]),
          ),
        ),
      ),
    )

  let response = {
    use ctx <- inertia.middleware(req, config, option.None)
    ctx
    |> inertia.set_props(initial_props(), encode_test_props)
    |> inertia.prop(nested(nested_data))
    |> inertia.render("NestedDataPage")
  }

  testing.component(response) |> should.equal(Ok("NestedDataPage"))
  testing.prop(
    response,
    "nested",
    decode.at(["level1", "level2", "level3", "level4", "value"], decode.string),
  )
  |> should.equal(Ok("deep value"))
  testing.prop(
    response,
    "nested",
    decode.at(
      ["level1", "level2", "level3", "level4", "array"],
      decode.list(decode.at(["item"], decode.string)),
    ),
  )
  |> should.equal(Ok(["nested item 1", "nested item 2"]))
}
