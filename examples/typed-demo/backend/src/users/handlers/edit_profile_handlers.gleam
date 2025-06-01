import gleam/dict
import gleam/option
import inertia_wisp/inertia
import shared_types/users
import users/validators
import wisp

// Mock data
type User {
  User(
    id: Int,
    name: String,
    email: String,
    bio: String,
    interests: List(String),
  )
}

fn get_user_by_id(id: Int) -> User {
  User(
    id: id,
    name: "Alice Johnson",
    email: "alice@example.com",
    bio: "Software engineer passionate about functional programming and web development.",
    interests: ["Programming", "Reading", "Hiking", "Photography"],
  )
}

// ===== PAGE HANDLERS =====

// Edit profile form page
pub fn edit_profile_page_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  _user_id: String,
) -> wisp.Response {
  // Simulate fetching user data for editing
  let user = get_user_by_id(1)
  // Would parse user_id in real app

  ctx
  |> users.with_user_profile_page_props()
  |> inertia.assign_prop_t(users.name(user.name))
  |> inertia.assign_prop_t(users.id(user.id))
  |> inertia.assign_prop_t(users.email(user.email))
  |> inertia.assign_prop_t(users.bio(user.bio))
  |> inertia.assign_prop_t(
    users.interests(fn() { option.Some(user.interests) }),
  )
  |> inertia.render("users/EditProfile")
}

// ===== FORM HANDLERS =====

// Update profile form handler
pub fn update_profile_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  user_id: String,
) -> wisp.Response {
  use request <- inertia.require_json(
    ctx,
    users.update_profile_request_decoder(),
  )

  // Validate the request
  let validation_errors =
    validators.validate_update_profile_request(
      request.name,
      request.bio,
      request.interests,
    )

  case dict.is_empty(validation_errors) {
    True -> {
      // Success - redirect to user profile
      inertia.redirect(ctx.request, "/user/" <> user_id)
    }
    False -> {
      // Validation errors - re-render edit profile form with errors
      // Get user data (would normally fetch from database)
      let user = get_user_by_id(1)

      ctx
      |> users.with_user_profile_page_props()
      |> inertia.assign_prop_t(users.name(user.name))
      |> inertia.assign_prop_t(users.id(user.id))
      |> inertia.assign_prop_t(users.email(user.email))
      |> inertia.assign_prop_t(users.bio(user.bio))
      |> inertia.assign_prop_t(
        users.interests(fn() { option.Some(user.interests) }),
      )
      |> inertia.assign_errors(validation_errors)
      |> inertia.render("users/EditProfile")
    }
  }
}
