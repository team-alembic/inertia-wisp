import gleam/json
import gleam/option
import inertia_wisp/inertia

// ===== PROPS TYPES (with encoders) =====

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

/// Zero value for Blog Post Page Props
pub const zero_blog_post_page_props = BlogPostPageProps(
  title: "",
  content: "",
  author: "",
  published_at: "",
  tags: [],
  view_count: option.None,
)

@target(erlang)
/// Use Blog Post Page Props for the current InertiaJS handler
pub fn with_blog_post_page_props(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> inertia.InertiaContext(BlogPostPageProps) {
  ctx
  |> inertia.set_props(zero_blog_post_page_props, encode_blog_post_props)
}

//prop assignment functions. Generates tuples for use with inertia.assign_prop_t
pub fn title(t: String) {
  #("title", fn(p) { BlogPostPageProps(..p, title: t) })
}

pub fn content(c: String) {
  #("content", fn(p) { BlogPostPageProps(..p, content: c) })
}

pub fn author(a: String) {
  #("author", fn(p) { BlogPostPageProps(..p, author: a) })
}

pub fn published_at(pa: String) {
  #("published_at", fn(p) { BlogPostPageProps(..p, published_at: pa) })
}

pub fn tags(t: fn() -> List(String)) {
  #("tags", fn(p) { BlogPostPageProps(..p, tags: t()) })
}

pub fn view_count(vc: fn() -> option.Option(Int)) {
  #("view_count", fn(p) { BlogPostPageProps(..p, view_count: vc()) })
}
