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

  // Convert User to UserProfile
  let user_profile =
    users.UserProfile(
      name: user.name,
      email: user.email,
      id: user.id,
      interests: user.interests,
      bio: user.bio,
    )

  ctx
  |> users.with_user_profile_page_props()
  |> inertia.prop(users.user_profile(user_profile))
  |> inertia.render("users/UserProfile")
}
