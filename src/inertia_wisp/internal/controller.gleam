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
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option
import gleam/string
import gleam/string_tree
import inertia_wisp/internal/html
import inertia_wisp/internal/middleware

import inertia_wisp/internal/types.{type Page}
import wisp.{type Request, type Response}

/// Render a typed Inertia response from typed context
pub fn render_typed(
  ctx: types.InertiaContext(props),
  component: String,
) -> Response {
  let is_inertia = middleware.is_inertia_request(ctx.request)
  let partial_data = middleware.get_partial_data(ctx.request)

  // Apply prop transformations and get which props should be included
  let #(final_props, included_props) =
    evaluate_typed_props(ctx, is_inertia, partial_data)

  // Encode only the included props and merge with errors
  let props_json =
    encode_selective_props(
      final_props,
      included_props,
      ctx.props_encoder,
      ctx.errors,
    )

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
    False ->
      render_html_response_with_ssr_check(
        page,
        // Convert typed context to regular context for SSR compatibility
        types.InertiaContext(
          config: ctx.config,
          request: ctx.request,
          prop_transforms: ctx.prop_transforms,
          props_encoder: ctx.props_encoder,
          props_zero: ctx.props_zero,
          errors: ctx.errors,
          encrypt_history: ctx.encrypt_history,
          clear_history: ctx.clear_history,
          ssr_supervisor: ctx.ssr_supervisor,
        ),
      )
  }
}

/// Evaluate typed props based on request type and partial data requirements
/// Returns both the final props and a list of prop names that should be included
fn evaluate_typed_props(
  ctx: types.InertiaContext(props),
  is_inertia: Bool,
  partial_data: List(String),
) -> #(props, List(String)) {
  // Check if this is a partial reload (Inertia request with specific data requested)
  let is_partial_reload = is_inertia && list.length(partial_data) > 0

  let #(final_props, included_props) =
    list.fold(
      list.reverse(ctx.prop_transforms),
      #(ctx.props_zero, []),
      fn(acc, prop_transform) {
        let #(current_props, current_included) = acc
        let should_include = case prop_transform.include {
          // Always props are included in all types of requests
          types.IncludeAlways -> True

          // Default props are included in:
          // - Initial renders (non-Inertia requests)
          // - Regular Inertia requests (not partial reloads)
          // - Partial reloads when specifically requested
          types.IncludeDefault ->
            case is_partial_reload {
              True -> list.contains(partial_data, prop_transform.name)
              False -> True
              // Include in initial renders and regular Inertia requests
            }

          // Optional props are only included when specifically requested in partial reloads
          types.IncludeOptionally ->
            case is_partial_reload {
              True -> list.contains(partial_data, prop_transform.name)
              False -> False
              // Never included in initial renders or regular Inertia requests
            }
        }

        case should_include {
          True -> #(prop_transform.transform(current_props), [
            prop_transform.name,
            ..current_included
          ])
          False -> #(current_props, current_included)
        }
      },
    )

  #(final_props, list.reverse(included_props))
}

/// Encode only the props that should be included and merge with errors
fn encode_selective_props(
  props: props,
  included_props: List(String),
  encoder: fn(props) -> json.Json,
  errors: dict.Dict(String, String),
) -> json.Json {
  // Start with an empty list of props
  let base_props = case list.is_empty(included_props) {
    True -> []
    // No props to include
    _ -> {
      // Encode all props first, then parse and filter
      let full_json = encoder(props)
      let json_string = json.to_string(full_json)

      // Parse JSON to get all props as a dictionary
      case json.parse(json_string, decode.dict(decode.string, decode.dynamic)) {
        Ok(all_props) -> {
          // Filter to only include the specified props
          list.filter_map(included_props, fn(prop_name) {
            case dict.get(all_props, prop_name) {
              Ok(dynamic_value) -> {
                // Convert dynamic value back to JSON string and parse as JSON
                let value_json = convert_dynamic_to_json(dynamic_value)
                Ok(#(prop_name, value_json))
              }
              Error(_) -> Error(Nil)
            }
          })
        }
        Error(_) -> []
        // Fallback on parse error
      }
    }
  }

  // Always include errors if they exist
  let final_props = case dict.is_empty(errors) {
    True -> base_props
    False -> {
      let errors_json =
        json.object(
          dict.to_list(errors)
          |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
        )
      [#("errors", errors_json), ..base_props]
    }
  }

  json.object(final_props)
}

pub fn convert_dynamic_to_json(dynamic_value) {
  case dynamic.classify(dynamic_value) {
    "Nil" -> json.null()
    "Bool" -> {
      let assert Ok(b) = decode.run(dynamic_value, decode.bool)
      json.bool(b)
    }
    "Int" -> {
      let assert Ok(i) = decode.run(dynamic_value, decode.int)
      json.int(i)
    }
    "String" -> {
      let assert Ok(s) = decode.run(dynamic_value, decode.string)
      json.string(s)
    }
    "Float" -> {
      let assert Ok(f) = decode.run(dynamic_value, decode.float)
      json.float(f)
    }
    "List" -> {
      let assert Ok(l) = decode.run(dynamic_value, decode.list(decode.dynamic))
      json.array(l, convert_dynamic_to_json)
    }
    "Dict" -> {
      let assert Ok(d) =
        decode.run(dynamic_value, decode.dict(decode.string, decode.dynamic))
      d
      |> dict.to_list()
      |> list.map(fn(kv) { #(kv.0, convert_dynamic_to_json(kv.1)) })
      |> json.object()
    }
    _ -> panic
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
        option.Some(_supervisor) -> {
          // Try SSR render with the fully evaluated page
          let _page_json = types.encode_page(page) |> json.to_string()
          // For now, fall back to regular HTML until SSR is fully implemented
          render_html_response(page)
        }
        option.None -> render_html_response(page)
      }
    }
    False -> render_html_response(page)
  }
}

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
