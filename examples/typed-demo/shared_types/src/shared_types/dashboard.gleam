import gleam/json
import gleam/option

// ===== PROPS TYPES (with encoders) =====

pub type DashboardPageProp {
  UserCount(user_count: Int)
  PostCount(post_count: Int)
  RecentSignups(recent_signups: option.Option(List(String)))
  SystemStatus(system_status: String)
}

pub fn encode_dashboard_page_prop(prop: DashboardPageProp) -> json.Json {
  case prop {
    UserCount(user_count) -> json.int(user_count)
    PostCount(post_count) -> json.int(post_count)
    RecentSignups(recent_signups) -> json.nullable(recent_signups, json.array(_, json.string))
    SystemStatus(system_status) -> json.string(system_status)
  }
}