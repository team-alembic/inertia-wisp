//// @internal
////
//// Middleware and utility functions for detecting and handling Inertia.js requests.
////
//// This module provides:
//// - Middleware for handling typed Inertia contexts with version checking
//// - Utility functions for detecting Inertia requests and extracting data
//// - Managing Inertia-specific HTTP headers
////
//// ## Request Detection
////
//// The utilities identify Inertia requests by checking for:
//// - `X-Inertia: true` header for XHR requests
//// - `X-Inertia-Partial-Data` for partial reloads
//// - `X-Inertia-Partial-Component` for component-specific reloads

import gleam/erlang/process.{type Subject}
import gleam/http/request
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/string
import inertia_wisp/internal/types.{type Config, type SSRMessage}
import inertia_wisp/internal/version
import wisp.{type Request, type Response}

/// Check if current request is an Inertia request
pub fn is_inertia_request(req: Request) -> Bool {
  case request.get_header(req, "x-inertia") {
    Ok("true") -> True
    _ -> False
  }
}

/// Get partial data keys from request headers
pub fn get_partial_data(req: Request) -> List(String) {
  case request.get_header(req, "x-inertia-partial-data") {
    Ok(data) -> string.split(data, ",") |> list.map(string.trim)
    _ -> []
  }
}

/// Middleware for typed Inertia contexts with version checking and SSR support
///
/// This middleware handles:
/// - Version checking and mismatch responses
/// - Setting up SSR supervisor if provided
/// - Adding required Inertia headers to responses
///
/// ## Example
///
/// ```gleam
/// pub fn handle_request(req: wisp.Request) -> wisp.Response {
///   let config = inertia.config(version: "1.0.0", ssr: False, encrypt_history: False)
///
///   use ctx <- inertia.middleware(req, config, option.None, HomeProps(title: "", count: 0), encode_home_props)
///
///   case wisp.path_segments(req) {
///     [] -> home_page(ctx)
///     ["about"] -> about_page(ctx)
///     _ -> wisp.not_found()
///   }
/// }
/// ```
pub fn middleware(
  req: Request,
  config: Config,
  ssr_supervisor: Option(Subject(SSRMessage)),
  props_zero: props,
  props_encoder: fn(props) -> json.Json,
  handler: fn(types.InertiaContext(props)) -> Response,
) -> Response {
  let is_inertia_request = is_inertia_request(req)

  // Check version compatibility first
  case is_inertia_request && !version.version_matches(req, config) {
    True -> version.version_mismatch_response(req)
    False -> {
      // Create typed context
      let context = types.new_context(config, req, props_zero, props_encoder)

      // Configure SSR if supervisor is available
      let context = case ssr_supervisor {
        option.Some(supervisor) ->
          types.InertiaContext(
            ..context,
            ssr_supervisor: option.Some(supervisor),
          )
        option.None -> context
      }

      let response = handler(context)

      case is_inertia_request {
        True -> add_inertia_headers(response)
        False -> response
      }
    }
  }
}

/// Add required Inertia headers to response
pub fn add_inertia_headers(response: Response) -> Response {
  response
  |> wisp.set_header("x-inertia", "true")
  |> wisp.set_header("vary", "X-Inertia")
}
