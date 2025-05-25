import gleam/dict.{type Dict}
import gleam/json
import gleam/string
import gleam/string_tree
import inertia_gleam/html
import inertia_gleam/json as inertia_json
import inertia_gleam/middleware
import inertia_gleam/types.{type Page}
import wisp.{type Request, type Response}

/// Context wrapper for building up props before rendering
pub type InertiaContext {
  InertiaContext(request: Request, props: Dict(String, json.Json))
}

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

/// Create an Inertia context from a request
pub fn context(req: Request) -> InertiaContext {
  InertiaContext(request: req, props: dict.new())
}

/// Add a prop to the context in a pipe-friendly way
pub fn assign_prop(ctx: InertiaContext, key: String, value: json.Json) -> InertiaContext {
  InertiaContext(..ctx, props: dict.insert(ctx.props, key, value))
}

/// Add multiple props to the context
pub fn assign_props(ctx: InertiaContext, props: List(#(String, json.Json))) -> InertiaContext {
  let new_props = dict.merge(ctx.props, dict.from_list(props))
  InertiaContext(..ctx, props: new_props)
}

/// Render an Inertia response from context
pub fn render(ctx: InertiaContext, component: String) -> Response {
  render_inertia_with_props(ctx.request, component, ctx.props)
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
