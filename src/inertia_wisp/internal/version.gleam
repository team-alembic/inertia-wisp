import gleam/http/request
import gleam/result
import gleam/string
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
pub fn version_mismatch_response(req: Request) -> Response {
  let url = wisp.path_segments(req) |> string.join("/")
  let url = "/" <> url
  wisp.response(409)
  |> wisp.set_header("x-inertia", "true")
  |> wisp.set_header("x-inertia-location", url)
}
