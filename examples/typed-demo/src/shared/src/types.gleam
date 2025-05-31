import gleam/dynamic/decode
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

// Home page props
pub type HomePageProps {
  HomePageProps(title: String, message: String, features: List(String))
}

pub fn home_page_props_decoder() -> decode.Decoder(HomePageProps) {
  use title <- decode.field("title", decode.string)
  use message <- decode.field("message", decode.string)
  use features <- decode.field("features", decode.list(decode.string))
  decode.success(HomePageProps(title:, message:, features:))
}

// Encoder for HomePageProps
pub fn encode_home_page_props(props: HomePageProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
    #("features", json.array(props.features, json.string)),
  ])
}
