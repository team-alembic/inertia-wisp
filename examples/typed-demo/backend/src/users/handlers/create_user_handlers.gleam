import gleam/dict
import inertia_wisp/inertia
import shared_types/home
import shared_types/users
import users/validators
import wisp

// ===== PAGE HANDLERS =====

// Create user form page
pub fn create_user_page_handler(
  ctx: inertia.InertiaContext(Nil),
) -> wisp.Response {
  ctx
  |> inertia.with_encoder(home.encode_home_page_prop)
  |> inertia.prop("title", home.Title("Create New User"))
  |> inertia.prop("message", home.Message(
    "Fill out the form below to create a new user account.",
  ))
  |> inertia.prop("features", home.Features([]))
  |> inertia.render("users/CreateUser")
}

// ===== FORM HANDLERS =====

// Create user form handler
pub fn create_user_handler(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
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
      |> inertia.errors(validation_errors)
      |> inertia.render("users/CreateUser")
    }
  }
}