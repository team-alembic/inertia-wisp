import gleam/json
import gleam/option
import inertia_wisp/inertia

// ===== PROPS TYPES (with encoders) =====

pub type DashboardPageProps {
  DashboardPageProps(
    user_count: Int,
    post_count: Int,
    recent_signups: option.Option(List(String)),
    system_status: String,
  )
}

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

/// Zero value for Dashboard Page Props
pub const zero_dashboard_page_props = DashboardPageProps(
  user_count: 0,
  post_count: 0,
  recent_signups: option.None,
  system_status: "",
)

@target(erlang)
/// Use Dashboard Page Props for the current InertiaJS handler
pub fn with_dashboard_page_props(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> inertia.InertiaContext(DashboardPageProps) {
  ctx
  |> inertia.set_props(zero_dashboard_page_props, encode_dashboard_props)
}

//prop assignment functions. Generates tuples for use with inertia.prop
pub fn user_count(uc: Int) {
  #("user_count", fn(p) { DashboardPageProps(..p, user_count: uc) })
}

pub fn post_count(pc: Int) {
  #("post_count", fn(p) { DashboardPageProps(..p, post_count: pc) })
}

pub fn recent_signups(rs: fn() -> option.Option(List(String))) {
  #("recent_signups", fn(p) { DashboardPageProps(..p, recent_signups: rs()) })
}

pub fn system_status(ss: String) {
  #("system_status", fn(p) { DashboardPageProps(..p, system_status: ss) })
}
