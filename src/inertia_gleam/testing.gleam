import gleam/http
import gleam/http/request
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/string_tree
import wisp.{type Response}

/// Test helpers for Inertia.js applications
///
/// This module provides utilities for testing Inertia responses,
/// making it easy to verify that your handlers return the correct
/// components and props.
/// Create a mock request for testing
pub fn mock_request() -> wisp.Request {
  let body = wisp.create_canned_connection(<<>>, "test_secret_key_base")
  request.new()
  |> request.set_method(http.Get)
  |> request.set_path("/")
  |> request.set_body(body)
}

/// Create a mock Inertia XHR request for testing
pub fn mock_inertia_request() -> wisp.Request {
  mock_request()
  |> request.set_header("x-inertia", "true")
  |> request.set_header("x-inertia-version", "1")
}

/// Create a mock request with specific path
pub fn mock_request_with_path(path: String) -> wisp.Request {
  mock_request()
  |> request.set_path(path)
}

/// Create a mock Inertia request with specific path
pub fn mock_inertia_request_with_path(path: String) -> wisp.Request {
  mock_inertia_request()
  |> request.set_path(path)
}

/// Create a mock request with partial data header
pub fn mock_partial_request(props: List(String)) -> wisp.Request {
  let partial_data = string.join(props, ",")
  mock_inertia_request()
  |> request.set_header("x-inertia-partial-data", partial_data)
}

/// Extract JSON string from HTML data-page attribute
pub fn extract_json_from_html(html: String) -> Result(String, String) {
  case string.split_once(html, "data-page=\"") {
    Error(_) -> Error("No data-page attribute found in HTML")
    Ok(#(_, after_start)) -> {
      case string.split_once(after_start, "\"") {
        Error(_) -> Error("Malformed data-page attribute")
        Ok(#(json_string, _)) -> {
          Ok(unescape_html(json_string))
        }
      }
    }
  }
}

/// Get response body as string
pub fn get_response_body(response: wisp.Response) -> String {
  case response.body {
    wisp.Text(body) -> string_tree.to_string(body)
    _ -> ""
  }
}

/// Check if response is JSON
pub fn is_json_response(response: wisp.Response) -> Bool {
  let content_type = get_content_type(response)
  string.contains(content_type, "application/json")
}

pub fn assert_component(
  response: wisp.Response,
  expected_component: String,
) -> Result(Nil, String) {
  assert_component_in_json(get_response_body(response), expected_component)
}

/// Assert that a response contains the expected component name
pub fn assert_component_in_json(
  json_string: String,
  expected_component: String,
) -> Result(Nil, String) {
  case
    string.contains(
      json_string,
      "\"component\":\"" <> expected_component <> "\"",
    )
  {
    True -> Ok(Nil)
    False ->
      Error(
        "Expected component '" <> expected_component <> "' not found in JSON",
      )
  }
}

/// Assert that a response contains the expected prop value
fn assert_prop_in_json(
  json_string: String,
  key: String,
  expected_value: String,
) -> Result(Nil, String) {
  let prop_pattern = "\"" <> key <> "\":" <> expected_value
  case string.contains(json_string, prop_pattern) {
    True -> Ok(Nil)
    False ->
      Error(
        "Expected prop '"
        <> key
        <> "' with value "
        <> expected_value
        <> " not found in JSON",
      )
  }
}

pub fn assert_string_prop(
  resp: Response,
  key: String,
  expected_value: String,
) -> Result(Nil, String) {
  assert_string_prop_in_json(get_response_body(resp), key, expected_value)
}

pub fn assert_int_prop(
  resp: Response,
  key: String,
  expected_value: Int,
) -> Result(Nil, String) {
  assert_int_prop_in_json(get_response_body(resp), key, expected_value)
}

pub fn assert_no_prop(resp: Response, key: String) -> Result(Nil, String) {
  let prop_pattern = "\"" <> key <> "\":"
  case string.contains(get_response_body(resp), prop_pattern) {
    True -> Error("Unexpected prop '" <> key <> " found in JSON")
    False -> Ok(Nil)
  }
}

/// Assert that a response contains the expected string prop
pub fn assert_string_prop_in_json(
  json_string: String,
  key: String,
  expected_value: String,
) -> Result(Nil, String) {
  assert_prop_in_json(json_string, key, "\"" <> expected_value <> "\"")
}

/// Assert that a response contains the expected int prop
pub fn assert_int_prop_in_json(
  json_string: String,
  key: String,
  expected_value: Int,
) -> Result(Nil, String) {
  assert_prop_in_json(json_string, key, int.to_string(expected_value))
}

/// Assert that a response contains the expected bool prop
pub fn assert_bool_prop_in_json(
  json_string: String,
  key: String,
  expected_value: Bool,
) -> Result(Nil, String) {
  let value_str = case expected_value {
    True -> "true"
    False -> "false"
  }
  assert_prop_in_json(json_string, key, value_str)
}

/// Assert that a response has the expected URL
pub fn assert_url_in_json(
  json_string: String,
  expected_url: String,
) -> Result(Nil, String) {
  case string.contains(json_string, "\"url\":\"" <> expected_url <> "\"") {
    True -> Ok(Nil)
    False -> Error("Expected URL '" <> expected_url <> "' not found in JSON")
  }
}

/// Assert that a response has the expected version
pub fn assert_version_in_json(
  json_string: String,
  expected_version: String,
) -> Result(Nil, String) {
  case
    string.contains(json_string, "\"version\":\"" <> expected_version <> "\"")
  {
    True -> Ok(Nil)
    False ->
      Error("Expected version '" <> expected_version <> "' not found in JSON")
  }
}

/// Convenience function to test Inertia response
pub fn assert_inertia_response(
  response: wisp.Response,
  expected_component: String,
) -> Result(String, String) {
  let body = get_response_body(response)

  case response.status {
    200 -> {
      case is_json_response(response) {
        True -> {
          use _ <- result.try(assert_component_in_json(body, expected_component))
          Ok(body)
        }
        False -> {
          use json_string <- result.try(extract_json_from_html(body))
          use _ <- result.try(assert_component_in_json(
            json_string,
            expected_component,
          ))
          Ok(json_string)
        }
      }
    }
    _ ->
      Error("Expected 200 status code, got " <> int.to_string(response.status))
  }
}

/// Helper functions
fn get_content_type(response: wisp.Response) -> String {
  list.find_map(response.headers, fn(header) {
    case header {
      #("content-type", value) -> Ok(value)
      _ -> Error(Nil)
    }
  })
  |> result.unwrap("")
}

fn unescape_html(text: String) -> String {
  text
  |> string.replace("&quot;", "\"")
  |> string.replace("&#x27;", "'")
  |> string.replace("&lt;", "<")
  |> string.replace("&gt;", ">")
  |> string.replace("&amp;", "&")
}
