//// @internal
////
//// Core controller functions for managing Inertia.js context and response generation.
////
//// This module provides the core functionality for:
//// - Assigning props to the Inertia context in a pipe-friendly manner
//// - Managing lazy props for performance optimization
//// - Handling always props that appear on every request
//// - Rendering Inertia responses (JSON for XHR requests, HTML for initial loads)
//// - Managing redirects and external redirects
////
//// The controller maintains the Inertia context state and coordinates between
//// the middleware, SSR, and HTML generation modules to produce appropriate responses.

import gleam/dict.{type Dict}
import gleam/json
import gleam/list
import gleam/option

import gleam/string
import gleam/string_tree
import inertia_wisp/internal/html
import inertia_wisp/internal/middleware
import inertia_wisp/internal/ssr
import inertia_wisp/internal/types.{
  type InertiaContext, type Page, type Prop, type PropValue, InertiaContext,
}
import wisp.{type Request, type Response}

/// Add a prop to the context in a pipe-friendly way
pub fn assign_prop(
  ctx: InertiaContext,
  key: String,
  value: json.Json,
) -> InertiaContext {
  InertiaContext(
    ..ctx,
    props: dict.insert(
      ctx.props,
      key,
      types.DefaultProp(types.EagerProp(value)),
    ),
  )
}

/// Add a lazy prop to the context that will only be evaluated when requested
pub fn assign_lazy_prop(
  ctx: InertiaContext,
  key: String,
  evaluator: fn() -> json.Json,
) -> InertiaContext {
  InertiaContext(
    ..ctx,
    props: dict.insert(
      ctx.props,
      key,
      types.DefaultProp(types.LazyProp(evaluator)),
    ),
  )
}

/// Add an optional prop to the context that will only be included when specifically requested
pub fn assign_optional_prop(
  ctx: InertiaContext,
  key: String,
  value: json.Json,
) -> InertiaContext {
  InertiaContext(
    ..ctx,
    props: dict.insert(
      ctx.props,
      key,
      types.OptionalProp(types.EagerProp(value)),
    ),
  )
}

/// Add an optional lazy prop to the context that will only be included and evaluated when specifically requested
pub fn assign_optional_lazy_prop(
  ctx: InertiaContext,
  key: String,
  evaluator: fn() -> json.Json,
) -> InertiaContext {
  InertiaContext(
    ..ctx,
    props: dict.insert(
      ctx.props,
      key,
      types.OptionalProp(types.LazyProp(evaluator)),
    ),
  )
}

/// Add an always prop to the context that will be included in every response
pub fn assign_always_prop(
  ctx: InertiaContext,
  key: String,
  value: json.Json,
) -> InertiaContext {
  InertiaContext(
    ..ctx,
    props: dict.insert(ctx.props, key, types.AlwaysProp(types.EagerProp(value))),
  )
}

/// Add an always lazy prop to the context that will be included in every response but evaluated lazily
pub fn assign_always_lazy_prop(
  ctx: InertiaContext,
  key: String,
  evaluator: fn() -> json.Json,
) -> InertiaContext {
  InertiaContext(
    ..ctx,
    props: dict.insert(
      ctx.props,
      key,
      types.AlwaysProp(types.LazyProp(evaluator)),
    ),
  )
}

/// Add multiple props to the context
pub fn assign_props(
  ctx: InertiaContext,
  props: List(#(String, json.Json)),
) -> InertiaContext {
  let prop_values =
    list.map(props, fn(pair) {
      #(pair.0, types.DefaultProp(types.EagerProp(pair.1)))
    })
  let new_props = dict.merge(ctx.props, dict.from_list(prop_values))
  InertiaContext(..ctx, props: new_props)
}

/// Add multiple always props to the context
pub fn assign_always_props(
  ctx: InertiaContext,
  props: List(#(String, json.Json)),
) -> InertiaContext {
  let prop_values =
    list.map(props, fn(pair) {
      #(pair.0, types.AlwaysProp(types.EagerProp(pair.1)))
    })
  let new_props = dict.merge(ctx.props, dict.from_list(prop_values))
  InertiaContext(..ctx, props: new_props)
}

/// Render an Inertia response from context
pub fn render(ctx: InertiaContext, component: String) -> Response {
  let is_inertia = middleware.is_inertia_request(ctx.request)
  let partial_data = middleware.get_partial_data(ctx.request)

  // Evaluate props based on whether it's a partial request
  let evaluated_props = evaluate_props(ctx.props, is_inertia, partial_data)

  let url = wisp.path_segments(ctx.request) |> string.join("/")
  let url = "/" <> url

  // Create page object
  let page =
    types.Page(
      component: component,
      props: evaluated_props,
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

/// Evaluate props based on request type and partial data requirements
fn evaluate_props(
  props: Dict(String, Prop),
  is_inertia: Bool,
  partial_data: List(String),
) -> Dict(String, json.Json) {
  case is_inertia && list.length(partial_data) > 0 {
    // Partial request - evaluate always props + only requested props
    True -> {
      dict.fold(props, dict.new(), fn(acc, key, prop) {
        case prop {
          types.AlwaysProp(prop_value) ->
            dict.insert(acc, key, evaluate_prop_value(prop_value))
          types.DefaultProp(prop_value) | types.OptionalProp(prop_value) ->
            case list.contains(partial_data, key) {
              True -> dict.insert(acc, key, evaluate_prop_value(prop_value))
              False -> acc
            }
        }
      })
    }
    // Full request - evaluate always props and default props (but not optional)
    False -> {
      dict.fold(props, dict.new(), fn(acc, key, prop) {
        case prop {
          types.AlwaysProp(prop_value) | types.DefaultProp(prop_value) ->
            dict.insert(acc, key, evaluate_prop_value(prop_value))
          types.OptionalProp(_) -> acc
        }
      })
    }
  }
}

/// Evaluate a single prop value
fn evaluate_prop_value(prop_value: PropValue) -> json.Json {
  case prop_value {
    types.EagerProp(value) -> value
    types.LazyProp(evaluator) -> evaluator()
  }
}

/// Render JSON response for Inertia XHR requests
fn render_json_response(page: types.Page) -> Response {
  let json_body = types.encode_page(page) |> json.to_string_tree()

  wisp.json_response(json_body, 200)
  |> wisp.set_header("x-inertia", "true")
  |> wisp.set_header("vary", "X-Inertia")
}

/// Render HTML response for initial page loads
fn render_html_response(page: Page) -> Response {
  let html_body = html.root_template(page, page.component)

  wisp.html_response(string_tree.from_string(html_body), 200)
}

/// Render HTML response with SSR check at the final moment
fn render_html_response_with_ssr_check(
  page: Page,
  ctx: InertiaContext,
) -> Response {
  // Check if SSR is enabled and supervisor is available
  let should_use_ssr = ctx.config.ssr && option.is_some(ctx.ssr_supervisor)

  case should_use_ssr {
    True -> {
      case ctx.ssr_supervisor {
        option.Some(supervisor) -> {
          // Try SSR render with the fully evaluated page
          let _page_json = types.encode_page(page) |> json.to_string()

          case
            ssr.render_page(
              supervisor,
              page.component,
              json.object(dict.to_list(page.props)),
              page.url,
              page.version,
            )
          {
            types.SSRSuccess(ssr_response) -> {
              // SSR successful - return the rendered HTML with SSR template
              let html_body = html.ssr_template(ssr_response, page)
              wisp.html_response(string_tree.from_string(html_body), 200)
            }
            types.SSRFallback(_reason) | types.SSRError(_error) -> {
              // SSR failed - fall back to CSR
              render_html_response(page)
            }
          }
        }
        option.None -> {
          // No supervisor available - fall back to CSR
          render_html_response(page)
        }
      }
    }
    False -> {
      // SSR not enabled - use CSR
      render_html_response(page)
    }
  }
}

/// Check if current request is an Inertia request
pub fn is_inertia_request(req: Request) -> Bool {
  middleware.is_inertia_request(req)
}

/// Add validation errors to the context
/// These errors will be included in the response under the "errors" prop
pub fn assign_errors(
  ctx: InertiaContext,
  errors: Dict(String, String),
) -> InertiaContext {
  // Merge new errors with existing ones (new errors override existing)
  let merged_errors = dict.merge(ctx.errors, errors)
  
  let errors_list =
    dict.fold(merged_errors, [], fn(acc, key, value) {
      [#(key, json.string(value)), ..acc]
    })

  let updated_ctx = InertiaContext(..ctx, errors: merged_errors)
  assign_prop(updated_ctx, "errors", json.object(errors_list))
}

/// Add a single validation error
pub fn assign_error(
  ctx: InertiaContext,
  field: String,
  message: String,
) -> InertiaContext {
  let errors = dict.from_list([#(field, message)])
  assign_errors(ctx, errors)
}

/// Set encrypt history flag on context
pub fn encrypt_history(ctx: InertiaContext) -> InertiaContext {
  InertiaContext(..ctx, encrypt_history: True)
}

/// Set clear history flag on context
pub fn clear_history(ctx: InertiaContext) -> InertiaContext {
  InertiaContext(..ctx, clear_history: True)
}

/// Create a redirect response that works with both regular browsers and Inertia XHR requests
pub fn redirect(_req: Request, to url: String) -> Response {
  wisp.response(303)
  |> wisp.set_header("location", url)
  |> wisp.set_header("vary", "X-Inertia")
}

/// Create an external redirect that forces a full page reload
pub fn external_redirect(to url: String) -> Response {
  wisp.response(409)
  |> wisp.set_header("x-inertia-location", url)
}
