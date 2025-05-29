//// @internal
////
//// Version management for Inertia.js asset cache busting and version mismatches.
////
//// This module handles the Inertia.js versioning system, which is crucial for
//// proper cache busting and ensuring clients receive updated assets when the
//// application is deployed with changes.
////
//// ## How Versioning Works
////
//// 1. The server includes a version identifier in every response
//// 2. Client requests include the version they expect (X-Inertia-Version header)
//// 3. If versions don't match, the server forces a full page reload
//// 4. This ensures users always get the latest assets after deployments
////
//// ## Version Mismatch Handling
////
//// When a version mismatch is detected:
//// - The server responds with a 409 Conflict status
//// - The client performs a full page reload to get fresh assets
//// - This prevents issues with stale JavaScript/CSS files
////
//// ## Usage
////
//// Version checking is automatically handled by the Inertia middleware.
//// You configure the version in your Inertia config, and this module
//// handles the comparison and mismatch responses.

import gleam/http/request
import gleam/result
import inertia_wisp/internal/types.{type Config}
import wisp.{type Request, type Response}

/// Check if the incoming request version matches the current app version
pub fn version_matches(req: Request, config: Config) -> Bool {
  case get_request_version(req) {
    Ok(request_version) -> {
      let current_version = get_current_version(config)
      request_version == current_version
    }
    Error(_) -> True
    // If no version header, assume match (initial load)
  }
}

/// Get the version from the request headers
pub fn get_request_version(req: Request) -> Result(String, Nil) {
  request.get_header(req, "x-inertia-version")
  |> result.map_error(fn(_) { Nil })
}

/// Get the current application version based on the strategy
pub fn get_current_version(config: Config) -> String {
  config.version
}

/// Create a version mismatch response
pub fn version_mismatch_response() -> Response {
  wisp.response(409)
  |> wisp.set_header("x-inertia", "true")
}
