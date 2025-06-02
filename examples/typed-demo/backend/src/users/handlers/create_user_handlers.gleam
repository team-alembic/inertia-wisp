import gleam/dict
import inertia_wisp/inertia
import shared_types/home
import shared_types/users
import users/validators
import wisp

// ===== PAGE HANDLERS =====

// Create user form page
pub fn create_user_page_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  ctx
  |> home.with_home_page_props()
  |> inertia.assign_prop_t(home.title("Create New User"))
  |> inertia.assign_prop_t(home.message(
    "Fill out the form below to create a new user account.",
  ))
  |> inertia.assign_prop_t(home.features(fn() { [] }))
  |> inertia.render("users/CreateUser")
}

// ===== FORM HANDLERS =====

// Create user form handler
pub fn create_user_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  use request <- inertia.require_json(ctx, users.create_user_request_decoder())

  // Validate the request
  let validation_errors =
    validators.validate_create_user_request(
      request.name,
      request.email,
      request.bio,
    )

  case dict.is_empty(validation_errors) {
    True -> {
      // Success - redirect to user profile
      // In a real app, you'd save to database and use the actual user ID
      inertia.redirect(ctx.request, "/user/1")
    }
    False -> {
      // Validation errors - re-render create user form with errors
      ctx
      |> inertia.assign_errors(validation_errors)
      |> inertia.render("users/CreateUser")
    }
  }
}
