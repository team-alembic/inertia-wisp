import gleam/option
import inertia_wisp/inertia
import shared_types/blog
import wisp

type DbConnection =
  Int

type UserId =
  Int

// pub type InertiaContext(prop) {
//   InertiaContext(
//     config: Config,
//     request: wisp.Request,
//     props: Dict(String, Prop(prop)),
//     prop_encoder: fn(prop) -> json.Json,
//     errors: Dict(String, String),
//     encrypt_history: Bool,
//     clear_history: Bool,
//     ssr_supervisor: Option(Subject(SSRMessage)),
//   )
// }
//
pub type HandlerContext {
  HandlerContext(db: DbConnection, current_user_id: UserId)
}

// Blog post handler
pub fn blog_post_handler(
  req: wisp.Request,
  post_id: Int,
  ctx: HandlerContext,
) -> wisp.Response {
  let resolver = fn(prop: String) {
    case prop {
      "title" -> blog.Title("Getting Started with Gleam")
      "published_at" -> blog.PublishedAt("2024-01-20")
      "content" ->
        blog.Content(
          "Gleam is a friendly language for building type-safe systems that can run anywhere. "
          <> "With its friendly syntax, first-class error handling, and powerful type system, "
          <> "Gleam makes it easy to build reliable software.",
        )
      "tags" ->
        blog.Tags(["gleam", "functional-programming", "web-development"])
      "view_count" -> blog.ViewCount(option.Some(1250))
    }
  }

  let eager_props = [
    blog.Title("Getting Started with Gleam"),
    blog.PublishedAt("2024-01-20"),
  ]

  request
  |> inertia.props([], parser)
  |> list.map(resolver)
  |> inertia.response(req, "blog/BlogPost", eager_props, resolver)
}
