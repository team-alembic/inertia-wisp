import contact/handlers
import gleam/http
import inertia_wisp/inertia
import wisp

pub fn contact_router(
  ctx: inertia.InertiaContext(Nil),
  request: wisp.Request,
) -> wisp.Response {
  case wisp.path_segments(request) {
    // GET /contact - show contact form
    // POST /contact - process contact form
    ["contact"] ->
      case request.method {
        http.Get -> handlers.contact_page_handler(ctx)
        http.Post -> handlers.contact_form_handler(ctx)
        _ -> wisp.method_not_allowed([http.Get, http.Post])
      }

    // Catch all for unknown contact routes
    _ -> wisp.not_found()
  }
}
