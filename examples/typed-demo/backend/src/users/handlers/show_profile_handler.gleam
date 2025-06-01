import gleam/option
import inertia_wisp/inertia
import shared_types/users
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

// User profile handler using typed props
pub fn user_profile_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  user_id: Int,
) -> wisp.Response {
  // Simulate fetching user data
  let user = get_user_by_id(user_id)

  ctx
  |> users.with_user_profile_page_props()
  // Always included props (essential user data)
  |> inertia.assign_prop_t(users.name(user.name))
  |> inertia.assign_prop_t(users.id(user.id))
  // Default props (included in initial load and when requested)
  |> inertia.assign_prop_t(users.email(user.email))
  |> inertia.assign_prop_t(users.bio(user.bio))
  // Optional props (only included when specifically requested - good for expensive data)
  |> inertia.assign_prop_t(
    users.interests(fn() { option.Some(user.interests) }),
  )
  |> inertia.render("users/UserProfile")
}
