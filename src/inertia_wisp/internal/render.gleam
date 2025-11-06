//// Render Inertia responses as JSON or HTML.
////
//// This module handles converting Inertia response data into HTTP responses,
//// either as JSON (for XHR requests) or HTML (for initial page loads).

import gleam/json
import gleam/string
import inertia_wisp/internal/protocol
import wisp.{type Response}

/// Render as JSON response for Inertia XHR requests
///
/// Adds Inertia-specific headers and returns JSON with the given status code.
pub fn json(response_json: json.Json, status: Int) -> Response {
  json.to_string(response_json)
  |> wisp.json_response(status)
  |> protocol.add_inertia_headers()
}

/// Render as HTML response for initial page loads
///
/// Embeds the Inertia response data as JSON in the HTML's data-page attribute.
/// The component name is used as the page title.
pub fn html(
  response_json: json.Json,
  component_name: String,
  status: Int,
) -> Response {
  let json_string = json.to_string(response_json)
  let escaped_json = escape_html(json_string)

  let html_content = "<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>" <> component_name <> "</title>
    <link rel=\"stylesheet\" href=\"/static/css/styles.css\">
</head>
<body>
    <div id=\"app\" data-page=\"" <> escaped_json <> "\"></div>
    <script type=\"module\" src=\"/static/js/main.js\"></script>
</body>
</html>"

  wisp.html_response(html_content, status)
}

/// Escape HTML characters for safe insertion into attributes
fn escape_html(text: String) -> String {
  text
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
  |> string.replace("\"", "&quot;")
  |> string.replace("'", "&#x27;")
}
