import gleam/json
import shared_types/auth

// ===== DOMAIN TYPES =====

pub type ExpensiveData {
  ExpensiveData(
    computed_at: String,
    large_dataset: List(String),
    total_users: Int,
    active_sessions: Int,
    cache_hit_rate: Float,
  )
}

pub fn encode_expensive_data(data: ExpensiveData) -> json.Json {
  json.object([
    #("computed_at", json.string(data.computed_at)),
    #("large_dataset", json.array(data.large_dataset, json.string)),
    #("database_stats", json.object([
      #("total_users", json.int(data.total_users)),
      #("active_sessions", json.int(data.active_sessions)),
      #("cache_hit_rate", json.float(data.cache_hit_rate)),
    ])),
  ])
}

pub type PerformanceInfo {
  PerformanceInfo(
    request_time: String,
    render_mode: String,
    props_included: String,
  )
}

pub fn encode_performance_info(info: PerformanceInfo) -> json.Json {
  json.object([
    #("request_time", json.string(info.request_time)),
    #("render_mode", json.string(info.render_mode)),
    #("props_included", json.string(info.props_included)),
  ])
}

// ===== PROPS TYPES (with encoders) =====

pub type DemoFeaturesPageProp {
  Auth(auth: auth.Auth)
  CsrfToken(csrf_token: String)
  Title(title: String)
  Description(description: String)
  ExpensiveDataProp(expensive_data: ExpensiveData)
  PerformanceInfoProp(performance_info: PerformanceInfo)
}

pub fn encode_demo_features_page_prop(prop: DemoFeaturesPageProp) -> json.Json {
  case prop {
    Auth(auth_val) -> auth.encode_auth(auth_val)
    CsrfToken(csrf_token) -> json.string(csrf_token)
    Title(title) -> json.string(title)
    Description(description) -> json.string(description)
    ExpensiveDataProp(expensive_data) -> encode_expensive_data(expensive_data)
    PerformanceInfoProp(performance_info) -> encode_performance_info(performance_info)
  }
}