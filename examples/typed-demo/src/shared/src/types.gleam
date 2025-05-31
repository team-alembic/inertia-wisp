import gleam/dynamic/decode
import gleam/json
import gleam/option

// User profile page props
pub type UserProfilePageProps {
  UserProfilePageProps(
    name: String,
    email: String,
    id: Int,
    interests: option.Option(List(String)),
    bio: String,
  )
}

// Encoder for UserProfilePageProps
pub fn encode_user_profile_props(props: UserProfilePageProps) -> json.Json {
  json.object([
    #("name", json.string(props.name)),
    #("email", json.string(props.email)),
    #("id", json.int(props.id)),
    #(
      "interests",
      json.nullable(props.interests, of: json.array(_, json.string)),
    ),
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
    view_count: option.Option(Int),
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
    #("view_count", json.nullable(props.view_count, json.int)),
  ])
}

// Dashboard page props
pub type DashboardPageProps {
  DashboardPageProps(
    user_count: Int,
    post_count: Int,
    recent_signups: option.Option(List(String)),
    system_status: String,
  )
}

// Encoder for DashboardPageProps
pub fn encode_dashboard_props(props: DashboardPageProps) -> json.Json {
  json.object([
    #("user_count", json.int(props.user_count)),
    #("post_count", json.int(props.post_count)),
    #(
      "recent_signups",
      json.nullable(props.recent_signups, json.array(_, json.string)),
    ),
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

// Decoder for UserProfilePageProps
pub fn user_profile_page_props_decoder() -> decode.Decoder(UserProfilePageProps) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use id <- decode.field("id", decode.int)
  use interests <- decode.optional_field(
    "interests",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use bio <- decode.field("bio", decode.string)
  decode.success(UserProfilePageProps(name:, email:, id:, interests:, bio:))
}

// Decoder for BlogPostPageProps
pub fn blog_post_page_props_decoder() -> decode.Decoder(BlogPostPageProps) {
  use title <- decode.field("title", decode.string)
  use content <- decode.field("content", decode.string)
  use author <- decode.field("author", decode.string)
  use published_at <- decode.field("published_at", decode.string)
  use tags <- decode.field("tags", decode.list(decode.string))
  use view_count <- decode.optional_field(
    "view_count",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(BlogPostPageProps(
    title:,
    content:,
    author:,
    published_at:,
    tags:,
    view_count:,
  ))
}

pub fn decode_blog_post_page_props(data: decode.Dynamic) {
  let assert Ok(props) = decode.run(data, blog_post_page_props_decoder())
  props
}

pub fn decode_home_page_props(data: decode.Dynamic) {
  let assert Ok(props) = decode.run(data, home_page_props_decoder())
  props
}

pub fn decode_user_profile_page_props(data: decode.Dynamic) {
  let assert Ok(props) = decode.run(data, user_profile_page_props_decoder())
  props
}

pub fn decode_dashboard_page_props(data: decode.Dynamic) {
  let assert Ok(props) = decode.run(data, dashboard_page_props_decoder())
  props
}

// Decoder for DashboardPageProps
pub fn dashboard_page_props_decoder() -> decode.Decoder(DashboardPageProps) {
  use user_count <- decode.field("user_count", decode.int)
  use post_count <- decode.field("post_count", decode.int)
  use recent_signups <- decode.optional_field(
    "recent_signups",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use system_status <- decode.field("system_status", decode.string)
  decode.success(DashboardPageProps(
    user_count:,
    post_count:,
    recent_signups:,
    system_status:,
  ))
}

// Encoder for HomePageProps
pub fn encode_home_page_props(props: HomePageProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
    #("features", json.array(props.features, json.string)),
  ])
}
