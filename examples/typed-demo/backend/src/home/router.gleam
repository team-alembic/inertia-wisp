import gleam/http
import home/handlers
import inertia_wisp/inertia
import wisp

pub fn home_router(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  request: wisp.Request,
) -> wisp.Response {
  case wisp.path_segments(request) {
    // GET /
    [] ->
      case request.method {
        http.Get -> handlers.home_page_handler(ctx)
        _ -> wisp.method_not_allowed([http.Get])
      }

    // Catch all for unknown routes
    _ -> wisp.not_found()
  }
}