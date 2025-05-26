import gleam/json
import gleam/string
import inertia_gleam/json as inertia_json
import inertia_gleam/types.{type Page}

/// Generate the root HTML template for initial page loads
pub fn root_template(page: Page, title: String) -> String {
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

/// Generate minimal HTML template with just the app div
pub fn app_template(page: Page) -> String {
  let page_json = json.to_string(encode_page_for_html(page))

  "<div id=\"app\" data-page=\"" <> escape_html(page_json) <> "\"></div>"
}

/// Encode page for HTML data attribute (same as JSON but formatted for HTML)
fn encode_page_for_html(page: Page) -> json.Json {
  inertia_json.encode_page(page)
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
