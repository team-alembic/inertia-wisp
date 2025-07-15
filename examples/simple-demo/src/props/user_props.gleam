//// User page prop types for the simple demo application.
////
//// This module defines the prop types that will be passed to user-related components.
//// It demonstrates LazyProp usage for expensive operations like user listing and
//// showcases dynamic data handling with database integration.

import data/users
import gleam/dict
import gleam/json
import gleam/option
import inertia_wisp/internal/types

/// Represents the different types of props that can be sent to user pages
pub type UserProp {
  UserList(List(users.User))
  UserCount(Int)
  UserData(users.User)
  UserFormData(name: String, email: String)
  SearchQuery(String)
  PaginationInfo(current_page: Int, total_pages: Int, per_page: Int)
  UserAnalytics(users.UserAnalytics)
  UserReport(users.UserReport)
}

// Factory functions for creating Prop(UserProp) instances

/// Create a form data prop (DefaultProp)
pub fn form_data(name: String, email: String) -> types.Prop(UserProp) {
  types.DefaultProp("form_data", UserFormData(name, email))
}

/// Create a user data prop (DefaultProp)
pub fn user_data(user: users.User) -> types.Prop(UserProp) {
  types.DefaultProp("user", UserData(user))
}

/// Create a user list prop (DefaultProp)
pub fn user_list(users: List(users.User)) -> types.Prop(UserProp) {
  types.DefaultProp("users", UserList(users))
}

/// Create a user count prop (DefaultProp)
pub fn user_count(count: Int) -> types.Prop(UserProp) {
  types.DefaultProp("user_count", UserCount(count))
}

/// Create a search query prop (DefaultProp)
pub fn search_query(query: String) -> types.Prop(UserProp) {
  types.DefaultProp("search_query", SearchQuery(query))
}

/// Create a user analytics prop (OptionalProp)
/// This is expensive to compute and should only be included when specifically requested
pub fn user_analytics(
  analytics_fn: fn() -> Result(users.UserAnalytics, dict.Dict(String, String)),
) -> types.Prop(UserProp) {
  types.OptionalProp("user_analytics", fn() {
    case analytics_fn() {
      Ok(analytics) -> Ok(UserAnalytics(analytics))
      Error(error_dict) -> Error(error_dict)
    }
  })
}

/// Create a user report prop (DeferProp)
/// This is very expensive to compute and should be deferred until specifically requested
pub fn user_report(
  report_fn: fn() -> Result(users.UserReport, dict.Dict(String, String)),
) -> types.Prop(UserProp) {
  types.DeferProp("user_report", option.Some("reports"), fn() {
    case report_fn() {
      Ok(report) -> Ok(UserReport(report))
      Error(error_dict) -> Error(error_dict)
    }
  })
}

/// Helper function to encode a single user to JSON
fn encode_user(user: users.User) -> json.Json {
  json.object([
    #("id", json.int(user.id)),
    #("name", json.string(user.name)),
    #("email", json.string(user.email)),
    #("created_at", json.string(user.created_at)),
  ])
}

/// Helper function to encode user list to JSON
fn encode_user_list(users: List(users.User)) -> json.Json {
  json.array(users, encode_user)
}

/// Helper function to encode pagination info
fn encode_pagination(current: Int, total: Int, per_page: Int) -> json.Json {
  json.object([
    #("current_page", json.int(current)),
    #("total_pages", json.int(total)),
    #("per_page", json.int(per_page)),
  ])
}

/// Helper function to encode user report to JSON
fn encode_user_report(report: users.UserReport) -> json.Json {
  json.object([
    #("total_users", json.int(report.total_users)),
    #("active_users", json.int(report.active_users)),
    #("inactive_users", json.int(report.inactive_users)),
    #("recent_signups", json.array(report.recent_signups, encode_user)),
    #(
      "top_domains",
      json.array(report.top_domains, fn(pair) {
        json.object([
          #("domain", json.string(pair.0)),
          #("count", json.int(pair.1)),
        ])
      }),
    ),
    #("activity_summary", json.string(report.activity_summary)),
  ])
}

/// Helper function to encode user analytics to JSON
fn encode_user_analytics(analytics: users.UserAnalytics) -> json.Json {
  json.object([
    #("total_users", json.int(analytics.total_users)),
    #("active_users", json.int(analytics.active_users)),
    #("growth_rate", json.float(analytics.growth_rate)),
    #("new_users_this_month", json.int(analytics.new_users_this_month)),
    #(
      "average_session_duration",
      json.float(analytics.average_session_duration),
    ),
  ])
}

/// Encode a UserProp to JSON only (for Response Builder API)
pub fn user_prop_to_json(prop: UserProp) -> json.Json {
  case prop {
    UserList(users) -> encode_user_list(users)
    UserCount(count) -> json.int(count)
    UserData(user) -> encode_user(user)
    UserFormData(name, email) ->
      json.object([#("name", json.string(name)), #("email", json.string(email))])
    SearchQuery(query) -> json.string(query)
    PaginationInfo(current, total, per_page) ->
      encode_pagination(current, total, per_page)
    UserAnalytics(analytics) -> encode_user_analytics(analytics)
    UserReport(report) -> encode_user_report(report)
  }
}
