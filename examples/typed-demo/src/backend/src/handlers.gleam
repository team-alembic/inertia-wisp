import gleam/option
import inertia_wisp/inertia
import types.{
  BlogPostPageProps, DashboardPageProps, HomePageProps, UserProfilePageProps,
  encode_blog_post_props, encode_dashboard_props, encode_home_page_props,
  encode_user_profile_props,
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
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  user_id: Int,
) -> wisp.Response {
  // Transform to typed context
  let typed_ctx = ctx
    |> inertia.set_props(
      UserProfilePageProps("", "", 0, option.None, ""), // zero value
      encode_user_profile_props,
    )

  // Simulate fetching user data
  let user = get_user_by_id(user_id)
  
  typed_ctx
  // Always included props (essential user data)
  |> inertia.assign_always_prop("name", fn(props) { UserProfilePageProps(..props, name: user.name) })
  |> inertia.assign_always_prop("id", fn(props) { UserProfilePageProps(..props, id: user.id) })
  // Default props (included in initial load and when requested)
  |> inertia.assign_prop("email", fn(props) { UserProfilePageProps(..props, email: user.email) })
  |> inertia.assign_prop("bio", fn(props) { UserProfilePageProps(..props, bio: user.bio) })
  // Optional props (only included when specifically requested - good for expensive data)
  |> inertia.assign_optional_prop("interests", fn(props) { UserProfilePageProps(..props, interests: option.Some(user.interests)) })
  |> inertia.render("UserProfile")
}

// Blog post handler
pub fn blog_post_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  _post_id: Int,
) -> wisp.Response {
  let typed_ctx = ctx
    |> inertia.set_props(
      BlogPostPageProps("", "", "", "", [], option.None), // zero value
      encode_blog_post_props,
    )

  // Mock blog post data
  typed_ctx
  // Essential post metadata - always included
  |> inertia.assign_always_prop("title", fn(props) { BlogPostPageProps(..props, title: "Getting Started with Gleam") })
  |> inertia.assign_always_prop("author", fn(props) { BlogPostPageProps(..props, author: "Alice Johnson") })
  |> inertia.assign_always_prop("published_at", fn(props) { BlogPostPageProps(..props, published_at: "2024-01-20") })
  // Main content - included by default
  |> inertia.assign_prop("content", fn(props) { BlogPostPageProps(..props, content: "Gleam is a friendly language for building type-safe systems that can run anywhere. With its friendly syntax, first-class error handling, and powerful type system, Gleam makes it easy to build reliable software.") })
  |> inertia.assign_prop("tags", fn(props) { BlogPostPageProps(..props, tags: ["gleam", "functional-programming", "web-development"]) })
  // Analytics data - only load when specifically requested (expensive query)
  |> inertia.assign_optional_prop("view_count", fn(props) { BlogPostPageProps(..props, view_count: option.Some(1250)) })
  |> inertia.render("BlogPost")
}

// Dashboard handler
pub fn dashboard_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  let typed_ctx = ctx
    |> inertia.set_props(
      DashboardPageProps(0, 0, option.None, ""), // zero value
      encode_dashboard_props,
    )

  // Mock dashboard data
  typed_ctx
  // Critical system status - always included for monitoring
  |> inertia.assign_always_prop("system_status", fn(props) { DashboardPageProps(..props, system_status: "All systems operational") })
  // Core metrics - included by default for dashboard overview  
  |> inertia.assign_prop("user_count", fn(props) { DashboardPageProps(..props, user_count: 1247) })
  |> inertia.assign_prop("post_count", fn(props) { DashboardPageProps(..props, post_count: 89) })
  // Detailed data - only loaded when admin specifically requests it (potentially expensive query)
  |> inertia.assign_optional_prop("recent_signups", fn(props) { DashboardPageProps(..props, recent_signups: option.Some(["alice@example.com", "bob@test.com", "carol@demo.org"])) })
  |> inertia.render("Dashboard")
}

// ===== FORM PAGE HANDLERS =====

// Create user form page
pub fn create_user_page_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  let typed_ctx = ctx
    |> inertia.set_props(
      HomePageProps("", "", []), // reuse simple props
      encode_home_page_props,
    )

  typed_ctx
  |> inertia.assign_always_prop("title", fn(props) { HomePageProps(..props, title: "Create New User") })
  |> inertia.assign_prop("message", fn(props) { HomePageProps(..props, message: "Fill out the form below to create a new user account.") })
  |> inertia.assign_prop("features", fn(props) { HomePageProps(..props, features: []) })
  |> inertia.render("CreateUser")
}

// Edit profile form page
pub fn edit_profile_page_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  _user_id: String,
) -> wisp.Response {
  let typed_ctx = ctx
    |> inertia.set_props(
      UserProfilePageProps("", "", 0, option.None, ""), // zero value
      encode_user_profile_props,
    )

  // Simulate fetching user data for editing
  let user = get_user_by_id(1) // Would parse user_id in real app
  
  typed_ctx
  |> inertia.assign_always_prop("name", fn(props) { UserProfilePageProps(..props, name: user.name) })
  |> inertia.assign_always_prop("id", fn(props) { UserProfilePageProps(..props, id: user.id) })
  |> inertia.assign_prop("email", fn(props) { UserProfilePageProps(..props, email: user.email) })
  |> inertia.assign_prop("bio", fn(props) { UserProfilePageProps(..props, bio: user.bio) })
  |> inertia.assign_prop("interests", fn(props) { UserProfilePageProps(..props, interests: option.Some(user.interests)) })
  |> inertia.render("EditProfile")
}

// Login form page
pub fn login_page_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  let typed_ctx = ctx
    |> inertia.set_props(
      HomePageProps("", "", []), // reuse simple props
      encode_home_page_props,
    )

  typed_ctx
  |> inertia.assign_always_prop("title", fn(props) { HomePageProps(..props, title: "Login") })
  |> inertia.assign_prop("message", fn(props) { HomePageProps(..props, message: "Please sign in to your account.") })
  |> inertia.assign_prop("features", fn(props) { HomePageProps(..props, features: ["Demo credentials: demo@example.com / password123"]) })
  |> inertia.render("Login")
}

// Contact form page
pub fn contact_page_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  let typed_ctx = ctx
    |> inertia.set_props(
      HomePageProps("", "", []), // reuse simple props
      encode_home_page_props,
    )

  typed_ctx
  |> inertia.assign_always_prop("title", fn(props) { HomePageProps(..props, title: "Contact Us") })
  |> inertia.assign_prop("message", fn(props) { HomePageProps(..props, message: "We'd love to hear from you. Send us a message!") })
  |> inertia.assign_prop("features", fn(props) { HomePageProps(..props, features: []) })
  |> inertia.render("ContactForm")
}