import gleam/http
import gleam/int
import inertia_wisp/inertia
import blog/handlers
import wisp

pub fn blog_router(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  request: wisp.Request,
) -> wisp.Response {
  case wisp.path_segments(request) {
    // GET /blog/:id - show blog post
    ["blog", post_id] -> case request.method {
      http.Get -> {
        case int.parse(post_id) {
          Ok(id) -> handlers.blog_post_handler(ctx, id)
          Error(_) -> wisp.bad_request()
        }
      }
      _ -> wisp.method_not_allowed([http.Get])
    }
    
    // Catch all for unknown blog routes
    _ -> wisp.not_found()
  }
}