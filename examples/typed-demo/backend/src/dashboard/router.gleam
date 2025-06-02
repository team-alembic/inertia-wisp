import gleam/http
import inertia_wisp/inertia
import dashboard/handlers
import wisp

pub fn dashboard_router(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  request: wisp.Request,
) -> wisp.Response {
  case wisp.path_segments(request) {
    // GET /dashboard - show dashboard
    ["dashboard"] -> case request.method {
      http.Get -> handlers.dashboard_handler(ctx)
      _ -> wisp.method_not_allowed([http.Get])
    }
    
    // Catch all for unknown dashboard routes
    _ -> wisp.not_found()
  }
}