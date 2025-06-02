import gleam/option
import inertia_wisp/inertia
import shared_types/blog
import wisp

// Blog post handler
pub fn blog_post_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  _post_id: Int,
) -> wisp.Response {
  ctx
  |> blog.with_blog_post_page_props()
  |> inertia.assign_prop_t(blog.title("Getting Started with Gleam"))
  |> inertia.assign_prop_t(blog.author("Alice Johnson"))
  |> inertia.assign_prop_t(blog.published_at("2024-01-20"))
  |> inertia.assign_prop_t(blog.content(
    "Gleam is a friendly language for building type-safe systems that can run anywhere. "
    <> "With its friendly syntax, first-class error handling, and powerful type system, "
    <> "Gleam makes it easy to build reliable software.",
  ))
  |> inertia.assign_prop_t(
    blog.tags(fn() { ["gleam", "functional-programming", "web-development"] }),
  )
  |> inertia.assign_prop_t(blog.view_count(fn() { option.Some(1250) }))
  |> inertia.render("blog/BlogPost")
}
