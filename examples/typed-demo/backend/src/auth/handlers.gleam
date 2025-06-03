import auth/validators
import gleam/dict
import inertia_wisp/inertia
import shared_types/auth
import wisp

// ===== PAGE HANDLERS =====

// Login form page
pub fn login_page_handler(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
  ctx
  |> inertia.with_encoder(auth.encode_login_page_prop)
  |> inertia.prop("title", auth.Title("Login"))
  |> inertia.prop("message", auth.Message("Please sign in to your account."))
  |> inertia.prop(
    "demo_info",
    auth.DemoInfo(["Demo credentials: demo@example.com / password123"]),
  )
  |> inertia.render("auth/Login")
}

// ===== FORM HANDLERS =====

// Login form handler
pub fn login_handler(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
  use request <- inertia.require_json(ctx, auth.login_request_decoder())

  // Validate the request
  let validation_errors =
    validators.validate_login_credentials(request.email, request.password)

  case dict.is_empty(validation_errors) {
    True -> {
      // Success - redirect to dashboard
      inertia.redirect(ctx.request, "/dashboard")
    }
    False -> {
      // Validation errors - re-render login form with errors
      ctx
      |> inertia.errors(validation_errors)
      |> inertia.render("auth/Login")
    }
  }
}
