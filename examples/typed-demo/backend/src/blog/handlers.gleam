import gleam/option
import inertia_wisp/inertia
import shared_types/blog
import wisp

// Blog post handler
pub fn blog_post_handler(
  ctx: inertia.InertiaContext(Nil),
  _post_id: Int,
) -> wisp.Response {
  ctx
  |> inertia.with_encoder(blog.encode_blog_post_prop)
  |> inertia.prop("title", blog.Title("Getting Started with Gleam"))
  |> inertia.prop("author", blog.Author("Alice Johnson"))
  |> inertia.prop("published_at", blog.PublishedAt("2024-01-20"))
  |> inertia.prop(
    "content",
    blog.Content(
      "Gleam is a friendly language for building type-safe systems that can run anywhere. "
      <> "With its friendly syntax, first-class error handling, and powerful type system, "
      <> "Gleam makes it easy to build reliable software.",
    ),
  )
  |> inertia.prop(
    "tags",
    blog.Tags(["gleam", "functional-programming", "web-development"]),
  )
  |> inertia.optional_prop("view_count", fn() {
    blog.ViewCount(option.Some(1250))
  })
  |> inertia.render("blog/BlogPost")
}
