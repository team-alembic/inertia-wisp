import gleam/dict
import gleam/http/request
import gleam/list
import gleam/string
import inertia_gleam/types.{type InertiaState}
import wisp.{type Request, type Response}

/// Middleware to detect and process Inertia requests
pub fn inertia_middleware(
  req: Request,
  handler: fn(Request) -> Response,
) -> Response {
  let inertia_state = detect_inertia_request(req)
  let updated_req = set_inertia_state(req, inertia_state)

  let response = handler(updated_req)

  case inertia_state.is_inertia {
    True -> add_inertia_headers(response)
    False -> response
  }
}

/// Detect if this is an Inertia request and extract relevant headers
fn detect_inertia_request(req: Request) -> InertiaState {
  let headers = request.get_header(req, "x-inertia")
  let is_inertia = case headers {
    Ok("true") -> True
    _ -> False
  }

  let partial_data = case request.get_header(req, "x-inertia-partial-data") {
    Ok(data) -> string.split(data, ",") |> list.map(string.trim)
    _ -> []
  }

  types.InertiaState(
    is_inertia: is_inertia,
    partial_data: partial_data,
    props: dict.new(),
  )
}

/// Store Inertia state in the request context
fn set_inertia_state(req: Request, _state: InertiaState) -> Request {
  // Note: This is a simplified approach - in real implementation,
  // we'd use Wisp's context system when available
  req
}

/// Get Inertia state from request context
pub fn get_inertia_state(_req: Request) -> Result(InertiaState, Nil) {
  // Placeholder - would retrieve from request context
  Error(Nil)
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
