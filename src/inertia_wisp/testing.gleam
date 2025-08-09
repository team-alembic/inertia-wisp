//// Testing utilities for Inertia.js applications built with Gleam and Wisp.
////
//// This module provides a comprehensive set of testing utilities specifically
//// designed for testing Inertia.js applications. It handles the complexities
//// of testing both XHR requests (JSON responses) and initial page loads
//// (HTML responses with embedded JSON data).
////
//// ## Core Testing Features
////
//// - **Mock Request Creation**: Generate properly formatted Inertia requests
//// - **Response Parsing**: Extract data from both JSON and HTML responses
//// - **Prop Testing**: Type-safe extraction and validation of component props
//// - **Partial Reload Testing**: Test selective prop loading for performance
//// - **Header Management**: Automatic handling of Inertia-specific headers
////
//// ## Usage Patterns
////
//// ### Basic Response Testing
////
//// ```gleam
//// import inertia_wisp/testing
////
//// pub fn test_home_page() {
////   let req = testing.inertia_request()
////   let response = my_handler(req)
////
////   assert testing.component(response) == Ok("HomePage")
////   assert testing.prop(response, "title", decode.string) == Ok("Welcome")
//// }
//// ```
////
//// ### Partial Reload Testing
////
//// ```gleam
//// pub fn test_partial_reload() {
////   let req = testing.inertia_request()
////     |> testing.partial_data(["posts", "comments"])
////   let response = my_handler(req)
////
////   // Only specified props should be present
////   case testing.prop(response, "posts", decode.list(decode.string)) {
////     Ok(_) -> Nil
////     Error(_) -> panic as "Expected posts prop to be present"
////   }
//// }
//// ```
////
//// ### Complex Prop Testing
////
//// ```gleam
//// pub fn test_user_data() {
////   let req = testing.inertia_request()
////   let response = user_profile_handler(req)
////
////   // Test nested object props
////   assert testing.prop(response, "user", decode.field("name", decode.string)) == Ok("John Doe")
////
////   // Test array props
////   assert testing.prop(response, "items", decode.list(decode.int)) == Ok([1, 2, 3])
//// }
//// ```
////
//// ## Response Format Handling
////
//// This module automatically handles both response formats:
////
//// 1. **JSON Responses**: Direct JSON parsing for XHR requests
//// 2. **HTML Responses**: Extraction of JSON data from `data-page` attributes
////    in initial page loads, with proper HTML entity unescaping
////
//// ## Type Safety
////
//// All prop extraction functions use Gleam's dynamic decoders, ensuring
//// type-safe testing of response data. This catches both missing props
//// and type mismatches at test time.

import gleam/bit_array
import gleam/dynamic
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/json.{UnableToDecode}
import gleam/list
import gleam/result
import gleam/string
import wisp.{type Request, type Response}
import wisp/testing

/// Create a mock Inertia XHR request for testing.
///
/// This creates a request with the necessary Inertia headers:
/// - `x-inertia: true` to indicate this is an Inertia request
/// - `x-inertia-version: 1` for version matching
/// - `accept: application/json` for JSON responses
///
/// ## Example
///
/// ```gleam
/// let req = testing.inertia_request()
/// let response = my_handler(req)
/// assert testing.component(response) == Ok("HomePage")
/// ```
pub fn inertia_request() -> Request {
  inertia_request_to("/")
}

/// Create a mock Inertia XHR request for testing with a custom path.
///
/// This creates a request with the necessary Inertia headers:
/// - `x-inertia: true` to indicate this is an Inertia request
/// - `x-inertia-version: 1` for version matching
/// - `accept: application/json` for JSON responses
///
/// ## Example
///
/// ```gleam
/// let req = testing.inertia_request_to("/users?search=Demo")
/// let response = my_handler(req)
/// assert testing.component(response) == Ok("Users/Index")
/// ```
pub fn inertia_request_to(path: String) -> Request {
  testing.get(path, [
    #("accept", "application/json"),
    #("x-inertia", "true"),
    #("x-inertia-version", "1"),
  ])
}

/// Create a regular HTTP request for testing initial page loads.
///
/// This creates a request WITHOUT Inertia headers, simulating a direct
/// browser visit or page refresh. The response should be HTML with
/// embedded JSON data in the data-page attribute.
///
/// ## Example
///
/// ```gleam
/// let req = testing.regular_request()
/// let response = my_handler(req)
/// assert testing.component(response) == Ok("HomePage")
/// ```
pub fn regular_request() -> Request {
  regular_request_to("/")
}

/// Create a regular HTTP request for testing initial page loads with a custom path.
///
/// This creates a request WITHOUT Inertia headers, simulating a direct
/// browser visit or page refresh to a specific URL.
///
/// ## Example
///
/// ```gleam
/// let req = testing.regular_request_to("/users/123")
/// let response = my_handler(req)
/// assert testing.component(response) == Ok("Users/Show")
/// ```
pub fn regular_request_to(path: String) -> Request {
  testing.get(path, [#("accept", "text/html")])
}

/// Add partial data headers to a request for testing partial reloads.
///
/// This modifies an existing request to include the `x-inertia-partial-data`
/// header, which tells Inertia to only return the specified props.
///
/// ## Example
///
/// ```gleam
/// let req = testing.inertia_request()
///   |> testing.partial_data(["posts", "comments"])
/// let response = my_handler(req)
/// // Only "posts" and "comments" props will be included
/// ```
pub fn partial_data(req: Request, props: List(String)) -> Request {
  let partial_data = string.join(props, ",")
  req
  |> request.set_header("x-inertia-partial-data", partial_data)
}

/// Add partial component header to a request for testing component matching.
///
/// This modifies an existing request to include the `x-inertia-partial-component`
/// header, which specifies which component is expected for partial reloads.
/// If the component doesn't match, it should be treated as a regular page load.
///
/// ## Example
///
/// ```gleam
/// let req = testing.inertia_request()
///   |> testing.partial_data(["posts"])
///   |> testing.partial_component("HomePage")
/// let response = my_handler(req)
/// // Should only include partial data if component matches "HomePage"
/// ```
pub fn partial_component(req: Request, component: String) -> Request {
  req
  |> request.set_header("x-inertia-partial-component", component)
}

/// Create an Inertia JSON POST request for testing form submissions.
///
/// This creates a POST request with the necessary headers for Inertia.js form
/// submissions using JSON data (as sent by useForm().post() or router.post()).
///
/// The request will include:
/// - `Content-Type: application/json`
/// - `Accept: application/json`
/// - `X-Inertia: true`
/// - `X-Inertia-Version: 1`
///
/// ## Examples
///
/// Testing user creation:
/// ```gleam
/// let data = json.object([
///   #("name", json.string("John Doe")),
///   #("email", json.string("john@example.com")),
/// ])
/// let req = testing.inertia_post("/users", data)
/// let response = create_user_handler(req, db)
/// assert testing.component(response) == Error(_) // Should redirect on success
/// ```
///
/// Testing validation errors:
/// ```gleam
/// let invalid_data = json.object([
///   #("name", json.string("")),  // Invalid: empty name
///   #("email", json.string("invalid-email")),  // Invalid: bad format
/// ])
/// let req = testing.inertia_post("/users", invalid_data)
/// let response = create_user_handler(req, db)
/// assert testing.component(response) == Ok("Users/Create") // Should return form with errors
/// ```
pub fn inertia_post(path: String, data: json.Json) -> Request {
  testing.request(
    http.Post,
    path,
    [
      #("content-type", "application/json"),
      #("accept", "application/json"),
      #("x-inertia", "true"),
      #("x-inertia-version", "1"),
    ],
    json.to_string(data) |> bit_array.from_string,
  )
}

/// Extract the component name from an Inertia response.
///
/// This works for both JSON responses (XHR requests) and HTML responses
/// (initial page loads) by parsing the appropriate format.
///
/// ## Example
///
/// ```gleam
/// let response = my_handler(req)
/// assert testing.component(response) == Ok("HomePage")
/// ```
pub fn component(response: Response) {
  response
  |> inertia_data(decode.at(["component"], decode.string))
}

/// Extract a specific prop value from an Inertia response.
///
/// This function allows you to retrieve and decode any prop from the response
/// using Gleam's dynamic decoders. Works for both JSON and HTML responses.
///
/// ## Example
///
/// ```gleam
/// // Test a string prop
/// assert testing.prop(response, "title", decode.string) == Ok("My Title")
///
/// // Test an integer prop
/// assert testing.prop(response, "count", decode.int) == Ok(42)
///
/// // Test a complex object
/// assert testing.prop(response, "user", decode.field("name", decode.string)) == Ok("John")
/// ```
pub fn prop(resp: Response, key: String, decoder: decode.Decoder(a)) {
  resp
  |> inertia_data(decode.at(["props", key], decoder))
}

/// Extract the URL from an Inertia response.
///
/// ## Example
///
/// ```gleam
/// assert testing.url(response) == Ok("/dashboard")
/// ```
pub fn url(response: Response) {
  response
  |> inertia_data(decode.at(["url"], decode.string))
}

/// Extract the version from an Inertia response.
///
/// ## Example
///
/// ```gleam
/// assert testing.version(response) == Ok("1")
/// ```
pub fn version(response: Response) {
  response
  |> inertia_data(decode.at(["version"], decode.string))
}

/// Extract the encrypt_history flag from an Inertia response.
///
/// ## Example
///
/// ```gleam
/// assert testing.encrypt_history(response) == Ok(True)
/// ```
pub fn encrypt_history(response: Response) {
  response
  |> inertia_data(decode.at(["encryptHistory"], decode.bool))
}

/// Extract the clear_history flag from an Inertia response.
///
/// ## Example
///
/// ```gleam
/// assert testing.clear_history(response) == Ok(True)
/// ```
pub fn clear_history(response: Response) {
  response
  |> inertia_data(decode.at(["clearHistory"], decode.bool))
}

/// Extract deferred props from an Inertia response.
///
/// ```gleam
/// assert testing.deferred_props(response, "default", decode.list(decode.string)) == Ok(["expensive"])
/// ```
pub fn deferred_props(
  response: Response,
  group: String,
  decoder: decode.Decoder(a),
) {
  response
  |> inertia_data(decode.at(["deferredProps", group], decoder))
}

/// Extract merge props from an Inertia response.
///
/// ```gleam
/// assert testing.merge_props(response, decode.list(decode.string)) == Ok(["posts", "comments"])
/// ```
pub fn merge_props(response: Response, decoder: decode.Decoder(a)) {
  response
  |> inertia_data(decode.at(["mergeProps"], decoder))
}

/// Extract deep merge props from an Inertia response.
///
/// ```gleam
/// assert testing.deep_merge_props(response, decode.list(decode.string)) == Ok(["nested", "deep"])
/// ```
pub fn deep_merge_props(response: Response, decoder: decode.Decoder(a)) {
  response
  |> inertia_data(decode.at(["deepMergeProps"], decoder))
}

/// Extract match props on from an Inertia response.
///
/// ```gleam
/// assert testing.match_props_on(response, decode.list(decode.string)) == Ok(["posts.id", "posts.slug"])
/// ```
pub fn match_props_on(response: Response, decoder: decode.Decoder(a)) {
  response
  |> inertia_data(decode.at(["matchPropsOn"], decoder))
}

// Private helper functions below this line

/// Extract and decode Inertia data from either JSON or HTML responses
fn inertia_data(
  response: Response,
  decoder: decode.Decoder(a),
) -> Result(a, json.DecodeError) {
  case is_json_response(response) {
    True -> Ok(testing.string_body(response))
    False -> {
      extract_json_from_html(testing.string_body(response))
    }
  }
  |> result.map_error(fn(x) {
    UnableToDecode(decode.decode_error("JSON in response", dynamic.string(x)))
  })
  |> result.try(json.parse(_, decoder))
}

/// Check if response has JSON content type
fn is_json_response(response: Response) -> Bool {
  let content_type = get_content_type(response)
  string.contains(content_type, "application/json")
}

/// Extract JSON string from HTML data-page attribute
fn extract_json_from_html(html: String) -> Result(String, String) {
  case string.split_once(html, "data-page=\"") {
    Error(_) -> {
      Error("No data-page attribute found in HTML")
    }
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

/// Get content type header from response
fn get_content_type(response: Response) -> String {
  list.find_map(response.headers, fn(header) {
    case header {
      #("content-type", value) -> Ok(value)
      _ -> Error(Nil)
    }
  })
  |> result.unwrap("")
}

/// Unescape HTML entities in JSON string
fn unescape_html(text: String) -> String {
  text
  |> string.replace("&quot;", "\"")
  |> string.replace("&#x27;", "'")
  |> string.replace("&lt;", "<")
  |> string.replace("&gt;", ">")
  |> string.replace("&amp;", "&")
}
