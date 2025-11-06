//// HTML layout helpers for Inertia.js applications.
////
//// This module provides utilities for creating HTML layouts that embed
//// Inertia page data. You can use these as-is or as examples for your own layouts.

import gleam/json
import gleam/string

/// A simple default HTML layout for development and getting started.
///
/// This layout includes:
/// - UTF-8 charset and viewport meta tags
/// - Component name as page title
/// - A div with id="app" and data-page attribute containing the Inertia data
/// - A script tag loading `/static/js/main.js` as an ES module
/// - A link to `/static/css/styles.css`
///
/// ## Example
///
/// ```gleam
/// |> inertia.response(200, html.default_layout)
/// ```
pub fn default_layout(component_name: String, page_data: json.Json) -> String {
  let json_string = json.to_string(page_data)
  let escaped_json = escape_html(json_string)

  "<!DOCTYPE html>
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
}

/// Escape HTML characters for safe insertion into attributes.
///
/// This function escapes characters that have special meaning in HTML to prevent
/// XSS attacks and ensure the JSON data is properly embedded.
///
/// ## Example
///
/// ```gleam
/// html.escape_html("<script>alert('xss')</script>")
/// // Returns: "&lt;script&gt;alert(&#x27;xss&#x27;)&lt;/script&gt;"
/// ```
pub fn escape_html(text: String) -> String {
  text
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
  |> string.replace("\"", "&quot;")
  |> string.replace("'", "&#x27;")
}
