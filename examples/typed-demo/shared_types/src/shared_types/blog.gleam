import gleam/json
import gleam/option

// ===== PROPS TYPES (with encoders) =====

pub type BlogPostPageProp {
  Title(title: String)
  Content(content: String)
  Author(author: String)
  PublishedAt(published_at: String)
  Tags(tags: List(String))
  ViewCount(view_count: option.Option(Int))
}

pub fn encode_blog_post_prop(prop: BlogPostPageProp) -> json.Json {
  case prop {
    Title(title) -> json.string(title)
    Content(content) -> json.string(content)
    Author(author) -> json.string(author)
    PublishedAt(published_at) -> json.string(published_at)
    Tags(tags) -> json.array(tags, json.string)
    ViewCount(view_count) -> json.nullable(view_count, json.int)
  }
}
