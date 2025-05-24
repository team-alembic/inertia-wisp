import gleam/json
import gleam/dict
import inertia_gleam/types.{type Page}

/// Encode a Page object to JSON
pub fn encode_page(page: Page) -> json.Json {
  json.object([
    #("component", json.string(page.component)),
    #("props", json.object(dict.to_list(page.props))),
    #("url", json.string(page.url)),
    #("version", json.string(page.version)),
  ])
}

/// Encode props dictionary to JSON
pub fn encode_props(props: dict.Dict(String, json.Json)) -> json.Json {
  json.object(dict.to_list(props))
}

/// Helper to convert a string to JSON
pub fn string_to_json(value: String) -> json.Json {
  json.string(value)
}

/// Helper to convert an int to JSON
pub fn int_to_json(value: Int) -> json.Json {
  json.int(value)
}

/// Helper to convert a bool to JSON
pub fn bool_to_json(value: Bool) -> json.Json {
  json.bool(value)
}

/// Helper to convert a list of strings to JSON array
pub fn string_list_to_json(values: List(String)) -> json.Json {
  json.array(values, json.string)
}

/// Helper to convert a list of ints to JSON array
pub fn int_list_to_json(values: List(Int)) -> json.Json {
  json.array(values, json.int)
}