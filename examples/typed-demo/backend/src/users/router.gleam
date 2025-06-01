import gleam/http
import gleam/int
import inertia_wisp/inertia
import users/handlers/create_user_handlers
import users/handlers/edit_profile_handlers
import users/handlers/show_profile_handler
import wisp

pub fn users_router(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  request: wisp.Request,
) -> wisp.Response {
  case wisp.path_segments(request) {
    // GET /users/create - show create user form
    // POST /users/create - process create user form
    ["users", "create"] ->
      case request.method {
        http.Get -> create_user_handlers.create_user_page_handler(ctx)
        http.Post -> create_user_handlers.create_user_handler(ctx)
        _ -> wisp.method_not_allowed([http.Get, http.Post])
      }

    // GET /users/:id - show user profile
    ["users", user_id] ->
      case request.method {
        http.Get -> {
          case int.parse(user_id) {
            Ok(id) -> show_profile_handler.user_profile_handler(ctx, id)
            Error(_) -> wisp.bad_request()
          }
        }
        _ -> wisp.method_not_allowed([http.Get])
      }

    // GET /users/:id/edit - show edit profile form
    // POST /users/:id/edit - process edit profile form
    ["users", user_id, "edit"] ->
      case request.method {
        http.Get ->
          edit_profile_handlers.edit_profile_page_handler(ctx, user_id)
        http.Post -> edit_profile_handlers.update_profile_handler(ctx, user_id)
        _ -> wisp.method_not_allowed([http.Get, http.Post])
      }

    // Legacy route /user/:id - redirect to /users/:id
    ["user", user_id] ->
      case request.method {
        http.Get -> {
          case int.parse(user_id) {
            Ok(id) -> show_profile_handler.user_profile_handler(ctx, id)
            Error(_) -> wisp.bad_request()
          }
        }
        _ -> wisp.method_not_allowed([http.Get])
      }

    // Catch all for unknown user routes
    _ -> wisp.not_found()
  }
}
