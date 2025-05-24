import gleam/dict.{type Dict}
import gleam/json
import gleam/string
import gleam/string_tree
import inertia_gleam/html
import inertia_gleam/json as inertia_json
import inertia_gleam/middleware
import inertia_gleam/types.{type Page}
import wisp.{type Request, type Response}

/// Render an Inertia response with component name only
pub fn render_inertia(req: Request, component: String) -> Response {
  render_inertia_with_props(req, component, dict.new())
}

/// Render an Inertia response with component and props
pub fn render_inertia_with_props(
  req: Request,
  component: String,
  props: Dict(String, json.Json),
) -> Response {
  let url = wisp.path_segments(req) |> string.join("/")
  let url = "/" <> url

  // Create page object
  let page =
    types.Page(
      component: component,
      props: props,
      url: url,
      version: "1",
      // TODO: Get from config
    )

  case middleware.is_inertia_request(req) {
    True -> render_json_response(page)
    False -> render_html_response(page)
  }
}

/// Add a prop to the request context (simplified version)
pub fn assign_prop(req: Request, _key: String, _value: json.Json) -> Request {
  // In a full implementation, this would store props in request context
  // For now, we'll handle this in render_inertia_with_props directly
  req
}

/// Render JSON response for Inertia XHR requests
fn render_json_response(page: Page) -> Response {
  let json_body = inertia_json.encode_page(page) |> json.to_string_tree()

  wisp.json_response(json_body, 200)
  |> wisp.set_header("x-inertia", "true")
  |> wisp.set_header("vary", "X-Inertia")
}

/// Render HTML response for initial page loads
fn render_html_response(page: Page) -> Response {
  let html_body = html.root_template(page, page.component)

  wisp.html_response(string_tree.from_string(html_body), 200)
}

/// Helper to convert string to JSON for props
pub fn string_prop(value: String) -> json.Json {
  json.string(value)
}

/// Helper to convert int to JSON for props
pub fn int_prop(value: Int) -> json.Json {
  json.int(value)
}

/// Helper to convert bool to JSON for props
pub fn bool_prop(value: Bool) -> json.Json {
  json.bool(value)
}

/// Helper to create props dict from list of tuples
pub fn props_from_list(
  props: List(#(String, json.Json)),
) -> Dict(String, json.Json) {
  dict.from_list(props)
}

/// Check if current request is an Inertia request
pub fn is_inertia_request(req: Request) -> Bool {
  middleware.is_inertia_request(req)
}
