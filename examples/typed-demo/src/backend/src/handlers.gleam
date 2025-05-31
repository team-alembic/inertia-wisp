import inertia_wisp/inertia
import types.{
  BlogPostPageProps, DashboardPageProps, UserProfilePageProps,
  encode_blog_post_props, encode_dashboard_props, encode_user_profile_props,
}
import wisp

// Mock data
type User {
  User(id: Int, name: String, email: String, bio: String, interests: List(String))
}

fn get_user_by_id(id: Int) -> User {
  User(
    id: id,
    name: "Alice Johnson",
    email: "alice@example.com",
    bio: "Software engineer passionate about functional programming and web development.",
    interests: ["Programming", "Reading", "Hiking", "Photography"]
  )
}

// User profile handler using typed props
pub fn user_profile_handler(
  request: wisp.Request,
  config: inertia.Config,
  user_id: Int,
) -> wisp.Response {
  // Create typed context with zero values and encoder
  let ctx = inertia.new_typed_context(
    config,
    request,
    UserProfilePageProps("", "", 0, [], ""), // zero value
    encode_user_profile_props,
  )

  // Simulate fetching user data
  let user = get_user_by_id(user_id)
  
  ctx
  |> inertia.assign_typed_prop("name", fn(props) { UserProfilePageProps(..props, name: user.name) })
  |> inertia.assign_typed_prop("email", fn(props) { UserProfilePageProps(..props, email: user.email) })
  |> inertia.assign_typed_prop("id", fn(props) { UserProfilePageProps(..props, id: user.id) })
  |> inertia.assign_typed_prop("bio", fn(props) { UserProfilePageProps(..props, bio: user.bio) })
  |> inertia.assign_typed_prop("interests", fn(props) { UserProfilePageProps(..props, interests: user.interests) })
  |> inertia.render_typed("UserProfile")
}

// Blog post handler
pub fn blog_post_handler(
  request: wisp.Request,
  config: inertia.Config,
  _post_id: Int,
) -> wisp.Response {
  let ctx = inertia.new_typed_context(
    config,
    request,
    BlogPostPageProps("", "", "", "", [], 0), // zero value
    encode_blog_post_props,
  )

  // Mock blog post data
  ctx
  |> inertia.assign_typed_prop("title", fn(props) { BlogPostPageProps(..props, title: "Getting Started with Gleam") })
  |> inertia.assign_typed_prop("content", fn(props) { BlogPostPageProps(..props, content: "Gleam is a friendly language for building type-safe systems...") })
  |> inertia.assign_typed_prop("author", fn(props) { BlogPostPageProps(..props, author: "Alice Johnson") })
  |> inertia.assign_typed_prop("published_at", fn(props) { BlogPostPageProps(..props, published_at: "2024-01-20") })
  |> inertia.assign_typed_prop("tags", fn(props) { BlogPostPageProps(..props, tags: ["gleam", "functional-programming", "web-development"]) })
  |> inertia.assign_typed_prop("view_count", fn(props) { BlogPostPageProps(..props, view_count: 1250) })
  |> inertia.render_typed("BlogPost")
}

// Dashboard handler
pub fn dashboard_handler(
  request: wisp.Request,
  config: inertia.Config,
) -> wisp.Response {
  let ctx = inertia.new_typed_context(
    config,
    request,
    DashboardPageProps(0, 0, [], ""), // zero value
    encode_dashboard_props,
  )

  // Mock dashboard data
  ctx
  |> inertia.assign_typed_prop("user_count", fn(props) { DashboardPageProps(..props, user_count: 1247) })
  |> inertia.assign_typed_prop("post_count", fn(props) { DashboardPageProps(..props, post_count: 89) })
  |> inertia.assign_typed_prop("recent_signups", fn(props) { DashboardPageProps(..props, recent_signups: ["alice@example.com", "bob@test.com", "carol@demo.org"]) })
  |> inertia.assign_typed_prop("system_status", fn(props) { DashboardPageProps(..props, system_status: "All systems operational") })
  |> inertia.render_typed("Dashboard")
}