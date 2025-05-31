import gleam/json

// User profile page props
pub type UserProfilePageProps {
  UserProfilePageProps(
    name: String,
    email: String,
    id: Int,
    interests: List(String),
    bio: String,
  )
}

// Encoder for UserProfilePageProps
pub fn encode_user_profile_props(props: UserProfilePageProps) -> json.Json {
  json.object([
    #("name", json.string(props.name)),
    #("email", json.string(props.email)),
    #("id", json.int(props.id)),
    #("interests", json.array(props.interests, json.string)),
    #("bio", json.string(props.bio)),
  ])
}

// Blog post page props
pub type BlogPostPageProps {
  BlogPostPageProps(
    title: String,
    content: String,
    author: String,
    published_at: String,
    tags: List(String),
    view_count: Int,
  )
}

// Encoder for BlogPostPageProps
pub fn encode_blog_post_props(props: BlogPostPageProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("content", json.string(props.content)),
    #("author", json.string(props.author)),
    #("published_at", json.string(props.published_at)),
    #("tags", json.array(props.tags, json.string)),
    #("view_count", json.int(props.view_count)),
  ])
}

// Dashboard page props
pub type DashboardPageProps {
  DashboardPageProps(
    user_count: Int,
    post_count: Int,
    recent_signups: List(String),
    system_status: String,
  )
}

// Encoder for DashboardPageProps  
pub fn encode_dashboard_props(props: DashboardPageProps) -> json.Json {
  json.object([
    #("user_count", json.int(props.user_count)),
    #("post_count", json.int(props.post_count)),
    #("recent_signups", json.array(props.recent_signups, json.string)),
    #("system_status", json.string(props.system_status)),
  ])
}