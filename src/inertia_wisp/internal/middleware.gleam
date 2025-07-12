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

import gleam/http/request
import gleam/list
import gleam/option.{type Option}
import gleam/string
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

/// Get partial component from request headers
pub fn get_partial_component(req: Request) -> Option(String) {
  case request.get_header(req, "x-inertia-partial-component") {
    Ok(component) -> option.Some(component)
    _ -> option.None
  }
}

/// Add required Inertia headers to response
pub fn add_inertia_headers(response: Response) -> Response {
  response
  |> wisp.set_header("x-inertia", "true")
  |> wisp.set_header("vary", "X-Inertia")
}
