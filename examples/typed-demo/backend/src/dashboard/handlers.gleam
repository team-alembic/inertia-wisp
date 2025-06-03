import gleam/option
import inertia_wisp/inertia
import shared_types/dashboard
import wisp

// ===== PAGE HANDLERS =====

// Dashboard handler
pub fn dashboard_handler(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
  ctx
  |> inertia.with_encoder(dashboard.encode_dashboard_page_prop)
  |> inertia.prop("system_status", dashboard.SystemStatus("All systems operational"))
  |> inertia.prop("user_count", dashboard.UserCount(1247))
  |> inertia.prop("post_count", dashboard.PostCount(89))
  |> inertia.prop("recent_signups", dashboard.RecentSignups(
    option.Some(["alice@example.com", "bob@test.com", "carol@demo.org"])
  ))
  |> inertia.render("Dashboard")
}