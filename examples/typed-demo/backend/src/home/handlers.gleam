import inertia_wisp/inertia
import shared_types/home
import wisp

// ===== PAGE HANDLERS =====

// Home page handler
pub fn home_page_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  ctx
  |> home.with_home_page_props()
  |> inertia.assign_prop_t(home.title("Typed Props Demo"))
  |> inertia.assign_prop_t(home.message(
    "Welcome to the statically typed props demo!",
  ))
  |> inertia.assign_prop_t(home.features(fn() {
    [
      "🔒 Compile-time type safety across full stack",
      "📝 Shared Gleam/TypeScript types with single source of truth",
      "🔄 Transformation-based props with immutable updates",
      "⚡ Partial reload support with selective prop loading",
      "🎯 Zero runtime overhead - all type checking at compile time",
      "🛡️ Prevents runtime errors from type mismatches",
    ]
  }))
  |> inertia.render("Home")
}