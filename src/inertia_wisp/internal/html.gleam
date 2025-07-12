//// @internal
////
//// HTML template generation for Inertia.js initial page loads.
////
//// This module handles the generation of HTML responses for initial page loads
//// (when users navigate directly to a URL or refresh the page). It creates the
//// root HTML template that includes:
////
//// - The basic HTML structure with DOCTYPE, head, and body
//// - Meta tags for charset and viewport
//// - CSS and JavaScript asset links
//// - The initial page data embedded as JSON in a div element
//// - The root div where the frontend framework will mount
////
//// ## Template Structure
////
//// The generated HTML includes:
//// - `#app` div for frontend framework mounting
//// - `#page-data` div containing the serialized page data
//// - Asset links for CSS and JavaScript files
//// - Support for SSR-rendered content when available
////
//// This ensures that both client-side navigation (via Inertia XHR requests)
//// and direct page loads work seamlessly in Inertia.js applications.

import gleam/json
import gleam/string
import inertia_wisp/internal/types.{type Page}

/// Generate the root HTML template for initial page loads
pub fn root_template(page: Page(prop), title: String) -> String {
  let page_json = json.to_string(encode_page_for_html(page))

  "<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>" <> title <> "</title>
    <link rel=\"stylesheet\" href=\"/static/css/styles.css\">
</head>
<body>
    <div id=\"app\" data-page=\"" <> escape_html(page_json) <> "\"></div>
    <script type=\"module\" src=\"/static/js/main.js\"></script>
</body>
</html>"
}

// FIXME: SSR
/// Generate SSR HTML template with server-rendered content
// pub fn ssr_template(ssr_response: SSRResponse, _page: Page) -> String {
//   let head_elements = string.join(ssr_response.head, "\n    ")

//   "<!DOCTYPE html>
// <html lang=\"en\">
// <head>
//     <meta charset=\"UTF-8\">
//     <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
//     " <> head_elements <> "
//     <link rel=\"stylesheet\" href=\"/static/css/styles.css\">
// </head>
// <body>
//     " <> ssr_response.body <> "
//     <script type=\"module\" src=\"/static/js/main.js\"></script>
// </body>
// </html>"
// }

/// Generate minimal HTML template with just the app div
pub fn app_template(page: Page(prop)) -> String {
  let page_json = json.to_string(encode_page_for_html(page))

  "<div id=\"app\" data-page=\"" <> escape_html(page_json) <> "\"></div>"
}

/// Encode page for HTML data attribute (same as JSON but formatted for HTML)
fn encode_page_for_html(page: Page(prop)) -> json.Json {
  types.encode_page(page)
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
