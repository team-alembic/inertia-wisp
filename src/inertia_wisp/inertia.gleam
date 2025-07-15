//// Inertia.js adapter for the Gleam Wisp web framework.

import gleam/dict
import gleam/json
import gleam/string_tree
import inertia_wisp/internal/html
import inertia_wisp/internal/middleware
import inertia_wisp/internal/types.{type Page}
import inertia_wisp/response_builder
import wisp.{type Request, type Response}

// Re-export Response Builder API
pub type InertiaResponseBuilder =
  response_builder.InertiaResponseBuilder

pub fn render(req: Request, page: Page(prop)) -> Response {
  case middleware.is_inertia_request(req) {
    True -> render_json_response(page)
    False -> render_html_response(page)
  }
}

fn render_json_response(page: Page(prop)) -> Response {
  let json_body = types.encode_page(page) |> json.to_string()

  json_body
  |> string_tree.from_string()
  |> wisp.json_response(200)
  |> middleware.add_inertia_headers()
}

fn render_html_response(page: Page(prop)) -> Response {
  let html_body = html.root_template(page, page.component)
  wisp.html_response(string_tree.from_string(html_body), 200)
}

pub fn external_redirect(url: String) -> Response {
  wisp.response(409)
  |> wisp.set_header("x-inertia-location", url)
}

// Response Builder API re-exports
pub fn response_builder(
  req: Request,
  component: String,
) -> InertiaResponseBuilder {
  response_builder.response_builder(req, component)
}

pub fn props(
  builder: InertiaResponseBuilder,
  props: List(types.Prop(p)),
  encode_prop: fn(p) -> json.Json,
) -> InertiaResponseBuilder {
  response_builder.props(builder, props, encode_prop)
}

pub fn errors(
  builder: InertiaResponseBuilder,
  errors: dict.Dict(String, String),
) -> InertiaResponseBuilder {
  response_builder.errors(builder, errors)
}

pub fn redirect(
  builder: InertiaResponseBuilder,
  url: String,
) -> InertiaResponseBuilder {
  response_builder.redirect(builder, url)
}

pub fn on_error(
  builder: InertiaResponseBuilder,
  error_component: String,
) -> InertiaResponseBuilder {
  response_builder.on_error(builder, error_component)
}

pub fn clear_history(builder: InertiaResponseBuilder) -> InertiaResponseBuilder {
  response_builder.clear_history(builder)
}

pub fn encrypt_history(
  builder: InertiaResponseBuilder,
) -> InertiaResponseBuilder {
  response_builder.encrypt_history(builder)
}

pub fn version(
  builder: InertiaResponseBuilder,
  version: String,
) -> InertiaResponseBuilder {
  response_builder.version(builder, version)
}

pub fn response(builder: InertiaResponseBuilder) -> Response {
  response_builder.response(builder)
}
