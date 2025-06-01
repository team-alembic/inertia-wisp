import auth/handlers
import gleam/http
import inertia_wisp/inertia
import wisp

pub fn auth_router(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  request: wisp.Request,
) -> wisp.Response {
  case wisp.path_segments(request) {
    // GET /auth/login
    ["auth", "login"] ->
      case request.method {
        http.Get -> handlers.login_page_handler(ctx)
        http.Post -> handlers.login_handler(ctx)
        _ -> wisp.method_not_allowed([http.Get, http.Post])
      }

    // Catch all for unknown auth routes
    _ -> wisp.not_found()
  }
}
