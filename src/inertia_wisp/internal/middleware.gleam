//// @internal
////
//// Middleware for detecting and handling Inertia.js requests.
////
//// This module provides the core middleware functionality that bridges between
//// Wisp web requests and the Inertia.js protocol. It:
////
//// - Detects whether incoming requests are Inertia XHR requests or initial page loads
//// - Handles version matching and asset cache busting
//// - Creates and manages the InertiaContext for request handling
//// - Coordinates with optional SSR (Server-Side Rendering) functionality
//// - Manages partial reload requests for performance optimization
////
//// ## Request Detection
////
//// The middleware identifies Inertia requests by checking for:
//// - `X-Inertia: true` header for XHR requests
//// - `X-Inertia-Version` for version matching
//// - `X-Inertia-Partial-Data` for partial reloads
//// - `X-Inertia-Partial-Component` for component-specific reloads
////
//// ## Response Handling
////
//// Based on the request type, the middleware ensures:
//// - JSON responses for Inertia XHR requests
//// - HTML responses for initial page loads
//// - Proper HTTP status codes and headers
//// - Version mismatch handling with appropriate redirects

import gleam/erlang/process.{type Subject}
import gleam/http/request
import gleam/list
import gleam/option.{type Option}
import gleam/string
import inertia_wisp/internal/types.{type Config, type InertiaContext, type SSRMessage}
import inertia_wisp/internal/version
import wisp.{type Request, type Response}

/// Middleware to detect and process Inertia requests with config and optional SSR
pub fn inertia_middleware(
  req: Request,
  config: Config,
  ssr_supervisor: Option(Subject(SSRMessage)),
  handler: fn(InertiaContext) -> Response,
) -> Response {
  let is_inertia_request = is_inertia_request(req)
  // Check version compatibility first
  case is_inertia_request && !version.version_matches(req, config) {
    True -> version.version_mismatch_response()
    False -> {
      let context = types.new_context(config, req)
      // Configure SSR if supervisor is available
      let context = case ssr_supervisor {
        option.Some(supervisor) -> {
          context
          |> enable_ssr()
          |> with_ssr_supervisor(supervisor)
        }
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
fn add_inertia_headers(response: Response) -> Response {
  response
  |> wisp.set_header("x-inertia", "true")
  |> wisp.set_header("vary", "X-Inertia")
}

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

/// Enable SSR for the given context
fn enable_ssr(ctx: InertiaContext) -> InertiaContext {
  let new_config = types.Config(..ctx.config, ssr: True)
  types.InertiaContext(..ctx, config: new_config)
}

/// Set the SSR supervisor for the given context
fn with_ssr_supervisor(
  ctx: InertiaContext,
  supervisor: Subject(SSRMessage),
) -> InertiaContext {
  types.InertiaContext(..ctx, ssr_supervisor: option.Some(supervisor))
}
