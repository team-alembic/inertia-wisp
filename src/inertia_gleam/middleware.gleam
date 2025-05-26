import gleam/http/request
import gleam/list
import gleam/string
import inertia_gleam/types.{type Config, type InertiaContext}
import inertia_gleam/version
import wisp.{type Request, type Response}

/// Middleware to detect and process Inertia requests with config
pub fn inertia_middleware(
  req: Request,
  config: Config,
  handler: fn(InertiaContext) -> Response,
) -> Response {
  let is_inertia_request = is_inertia_request(req)
  // Check version compatibility first
  case is_inertia_request && !version.version_matches(req, config) {
    True -> version.version_mismatch_response()
    False -> {
      let context = types.new_context(config, req)
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
