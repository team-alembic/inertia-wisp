import gleam/option
import inertia_wisp/inertia
import shared_types/dashboard
import wisp

// ===== PAGE HANDLERS =====

// Dashboard handler
pub fn dashboard_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  ctx
  |> dashboard.with_dashboard_page_props()
  // Critical system status - always included for monitoring
  |> inertia.assign_prop_t(dashboard.system_status("All systems operational"))
  // Core metrics - included by default for dashboard overview  
  |> inertia.assign_prop_t(dashboard.user_count(1247))
  |> inertia.assign_prop_t(dashboard.post_count(89))
  // Detailed data - only loaded when admin specifically requests it (potentially expensive query)
  |> inertia.assign_prop_t(dashboard.recent_signups(fn() {
    option.Some(["alice@example.com", "bob@test.com", "carol@demo.org"])
  }))
  |> inertia.render("Dashboard")
}