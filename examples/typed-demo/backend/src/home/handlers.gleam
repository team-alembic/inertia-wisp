import inertia_wisp/inertia
import shared_types/home
import wisp

// ===== PAGE HANDLERS =====

// Home page handler
pub fn home_page_handler(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
  ctx
  |> inertia.with_encoder(home.encode_home_page_prop)
  |> inertia.prop("title", home.Title("Typed Props Demo"))
  |> inertia.prop("message", home.Message(
    "Welcome to the Inertia.js Gleam demo with statically typed props!",
  ))
  |> inertia.prop("features", home.Features([
    "🔒 Compile-time type safety across full stack",
    "📝 Shared Gleam/TypeScript types with single source of truth",
    "🔄 Transformation-based props with immutable updates",
    "⚡ Partial reload support with selective prop loading",
    "🎯 Zero runtime overhead - all type checking at compile time",
    "🛡️ Prevents runtime errors from type mismatches",
  ]))
  |> inertia.render("Home")
}