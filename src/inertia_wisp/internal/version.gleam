import gleam/http/request
import gleam/list
import gleam/result
import gleam/string
import inertia_wisp/internal/types.{type Config}
import wisp.{type Request, type Response}

/// Check if the incoming request version matches the current app version
pub fn version_matches(req: Request, config: Config) -> Bool {
  let cfg_vsn =
    list.find_map(config, fn(cfg) {
      case cfg {
        types.Version(vsn) -> Ok(vsn)
        _ -> Error(Nil)
      }
    })

  let matching = {
    use cfg_vsn <- result.try(cfg_vsn)
    use req_vsn <- result.try(get_request_version(req))
    Ok(cfg_vsn == req_vsn)
  }

  matching |> result.unwrap(True)
}

/// Get the version from the request headers
pub fn get_request_version(req: Request) -> Result(String, Nil) {
  request.get_header(req, "x-inertia-version")
  |> result.map_error(fn(_) { Nil })
}

/// Create a version mismatch response
pub fn version_mismatch_response(req: Request) -> Response {
  let url = wisp.path_segments(req) |> string.join("/")
  let url = "/" <> url
  wisp.response(409)
  |> wisp.set_header("x-inertia", "true")
  |> wisp.set_header("x-inertia-location", url)
}
