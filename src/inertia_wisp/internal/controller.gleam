//// @internal
////
//// Core controller functions for managing typed Inertia.js context and response generation.
////
//// This module provides the core functionality for:
//// - Rendering typed Inertia responses (JSON for XHR requests, HTML for initial loads)
//// - Managing redirects and external redirects
//// - Evaluating typed prop transformations based on request type
////
//// The controller coordinates between the middleware, SSR, and HTML generation
//// modules to produce appropriate responses for the typed prop system.

import gleam/dict
import gleam/function
import gleam/json
import gleam/list
import gleam/option
import gleam/string
import gleam/string_tree
import inertia_wisp/internal/html
import inertia_wisp/internal/middleware
import inertia_wisp/internal/ssr

import inertia_wisp/internal/types.{type Page}
import wisp.{type Request, type Response}

/// Render a typed Inertia response from typed context
pub fn render_typed(
  ctx: types.InertiaContext(props),
  component: String,
) -> Response {
  let is_inertia = middleware.is_inertia_request(ctx.request)
  let partial_data = middleware.get_partial_data(ctx.request)

  let partial_component = middleware.get_partial_component(ctx.request)
  let props =
    evaluate_props(ctx, is_inertia, partial_data, partial_component, component)
  let props_json = encode_props_with_errors(props, ctx.prop_encoder, ctx.errors)
  let url = wisp.path_segments(ctx.request) |> string.join("/")
  let url = "/" <> url

  // Create page object
  let page =
    types.Page(
      component: component,
      props: props_json,
      url: url,
      version: ctx.config.version,
      clear_history: ctx.clear_history,
      encrypt_history: ctx.encrypt_history,
    )

  case middleware.is_inertia_request(ctx.request) {
    True -> render_json_response(page)
    False -> render_html_response_with_ssr_check(page, ctx)
  }
}

fn evaluate_props(
  ctx: types.InertiaContext(prop),
  is_inertia: Bool,
  partial_data: List(String),
  partial_component: option.Option(String),
  current_component: String,
) -> dict.Dict(String, prop) {
  // Check if this is a partial reload - requires ALL three conditions:
  // 1. Is an Inertia request
  // 2. Has partial data requested (X-Inertia-Partial-Data header)
  // 3. Component matches (X-Inertia-Partial-Component header matches current component)
  let component_matches = case partial_component {
    option.Some(requested_component) -> requested_component == current_component
    option.None -> False
  }
  let is_partial_reload =
    is_inertia && !list.is_empty(partial_data) && component_matches

  let props_list = dict.to_list(ctx.props)
  props_list
  |> list.filter_map(fn(prop) {
    let #(name, prop) = prop
    let should_include = case prop.include {
      types.IncludeAlways -> True
      types.IncludeDefault ->
        !is_partial_reload || list.contains(partial_data, name)
      types.IncludeOptionally ->
        is_partial_reload && list.contains(partial_data, name)
    }
    case should_include {
      True -> Ok(#(name, prop.prop_fn()))
      False -> Error(Nil)
    }
  })
  |> dict.from_list()
}

fn encode_props_with_errors(
  props: dict.Dict(String, prop),
  encoder: fn(prop) -> json.Json,
  errors: dict.Dict(String, String),
) -> json.Json {
  // Convert props to JSON using the encoder
  let encoded_props =
    props
    |> dict.to_list()
    |> list.map(fn(kv) { #(kv.0, encoder(kv.1)) })
    |> dict.from_list()

  // Add errors to the result if they exist
  case dict.is_empty(errors) {
    False -> {
      let errors_json = errors |> json.dict(function.identity, json.string)
      encoded_props
      |> dict.insert("errors", errors_json)
      |> json.dict(function.identity, function.identity)
    }
    True -> {
      encoded_props
      |> json.dict(function.identity, function.identity)
    }
  }
}

/// Create a JSON response with proper headers
fn render_json_response(page: Page) -> Response {
  let json_body = types.encode_page(page) |> json.to_string()

  wisp.json_response(string_tree.from_string(json_body), 200)
  |> middleware.add_inertia_headers()
}

/// Render basic HTML response (fallback when SSR is not available)
fn render_html_response(page: Page) -> Response {
  let html_body = html.root_template(page, page.component)

  wisp.html_response(string_tree.from_string(html_body), 200)
}

/// Render HTML response with SSR check at the final moment
fn render_html_response_with_ssr_check(
  page: Page,
  ctx: types.InertiaContext(props),
) -> Response {
  // Check if SSR is enabled and supervisor is available
  let should_use_ssr = ctx.config.ssr && option.is_some(ctx.ssr_supervisor)

  case should_use_ssr {
    True -> {
      case ctx.ssr_supervisor {
        option.Some(supervisor) -> {
          case ssr.render_page(supervisor, page) {
            types.SSRSuccess(response) -> {
              response
              |> html.ssr_template(page)
              |> string_tree.from_string()
              |> wisp.html_response(200)
              |> option.Some
            }
            _ -> option.None
          }
        }
        _ -> option.None
      }
    }
    _ -> option.None
  }
  |> option.lazy_unwrap(fn() { render_html_response(page) })
}

/// SSR succeeded and returned rendered content
/// SSR failed but should fallback to CSR gracefully
/// SSR failed with an error that should be raised
/// Check if the current request is an Inertia request
pub fn is_inertia_request(req: Request) -> Bool {
  middleware.is_inertia_request(req)
}

/// Get the partial data from the request
pub fn get_partial_data(req: Request) -> List(String) {
  middleware.get_partial_data(req)
}

/// Perform a redirect (Inertia-aware)
pub fn redirect(req: Request, url: String) -> Response {
  case middleware.is_inertia_request(req) {
    True -> {
      // For Inertia requests, return a 303 redirect
      wisp.redirect(url)
    }
    False -> {
      // For regular requests, return a standard redirect
      wisp.redirect(url)
    }
  }
}

/// Perform an external redirect (forces full page reload)
pub fn external_redirect(url: String) -> Response {
  wisp.response(409)
  |> wisp.set_header("x-inertia-location", url)
}
