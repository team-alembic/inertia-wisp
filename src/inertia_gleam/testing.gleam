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
/// testing.component(response) |> should.equal(Ok("HomePage"))
/// ```
pub fn inertia_request() -> Request {
  testing.request(
    http.Get,
    "/",
    [
      #("accept", "application/json"),
      #("x-inertia", "true"),
      #("x-inertia-version", "1"),
    ],
    bit_array.from_string(""),
  )
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

/// Extract the component name from an Inertia response.
/// 
/// This works for both JSON responses (XHR requests) and HTML responses
/// (initial page loads) by parsing the appropriate format.
/// 
/// ## Example
/// 
/// ```gleam
/// let response = my_handler(req)
/// testing.component(response) |> should.equal(Ok("HomePage"))
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
/// testing.prop(response, "title", decode.string) 
/// |> should.equal(Ok("My Title"))
/// 
/// // Test an integer prop
/// testing.prop(response, "count", decode.int) 
/// |> should.equal(Ok(42))
/// 
/// // Test a complex object
/// testing.prop(response, "user", decode.field("name", decode.string))
/// |> should.equal(Ok("John"))
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
/// testing.url(response) |> should.equal(Ok("/dashboard"))
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
/// testing.version(response) |> should.equal(Ok("1"))
/// ```
pub fn version(response: Response) {
  response
  |> inertia_data(decode.at(["version"], decode.string))
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
  |> result.then(fn(x) { json.parse(x, decoder) })
}

/// Check if response has JSON content type
fn is_json_response(response: Response) -> Bool {
  let content_type = get_content_type(response)
  string.contains(content_type, "application/json")
}

/// Extract JSON string from HTML data-page attribute
fn extract_json_from_html(html: String) -> Result(String, String) {
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
