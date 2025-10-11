//// User page prop types for the simple demo application.
////
//// This module defines the prop types that will be passed to user-related components.
//// It demonstrates LazyProp usage for expensive operations like user listing and
//// showcases dynamic data handling with database integration.

import data/users
import gleam/dict
import gleam/json
import gleam/option
import gleam/result
import inertia_wisp/prop.{type Prop, DefaultProp, DeferProp, OptionalProp}

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
  // Advanced prop types
  SearchFilters(users.SearchFilters)
  SearchResults(List(users.User))
  SearchAnalytics(users.SearchAnalytics)
  ActivityFeed(users.ActivityFeed)
}

// Factory functions for creating Prop(UserProp) instances

/// Create a form data prop (DefaultProp)
pub fn form_data(name: String, email: String) -> Prop(UserProp) {
  DefaultProp("form_data", UserFormData(name, email))
}

/// Create a user data prop (DefaultProp)
pub fn user_data(user: users.User) -> Prop(UserProp) {
  DefaultProp("user", UserData(user))
}

/// Create a user list prop (DefaultProp)
pub fn user_list(users: List(users.User)) -> Prop(UserProp) {
  DefaultProp("users", UserList(users))
}

/// Create a user count prop (DefaultProp)
pub fn user_count(count: Int) -> Prop(UserProp) {
  DefaultProp("user_count", UserCount(count))
}

/// Create a search query prop (DefaultProp)
pub fn search_query(query: String) -> Prop(UserProp) {
  DefaultProp("search_query", SearchQuery(query))
}

/// Create a user analytics prop (OptionalProp)
/// This is expensive to compute and should only be included when specifically requested
pub fn user_analytics(
  analytics_fn: fn() -> Result(users.UserAnalytics, dict.Dict(String, String)),
) -> Prop(UserProp) {
  OptionalProp("user_analytics", fn() {
    result.map(analytics_fn(), UserAnalytics)
  })
}

/// Create a user report prop (DeferProp)
/// This is very expensive to compute and should be deferred until specifically requested
pub fn user_report(
  report_fn: fn() -> Result(users.UserReport, dict.Dict(String, String)),
) -> Prop(UserProp) {
  DeferProp("user_report", option.Some("reports"), fn() {
    result.map(report_fn(), UserReport)
  })
}

/// Create search filters prop (DefaultProp)
pub fn search_filters(filters: users.SearchFilters) -> Prop(UserProp) {
  DefaultProp("search_filters", SearchFilters(filters))
}

/// Create search results prop (DefaultProp)
pub fn search_results(results: List(users.User)) -> Prop(UserProp) {
  DefaultProp("search_results", SearchResults(results))
}

/// Create search analytics prop (OptionalProp)
pub fn search_analytics(
  analytics_fn: fn() -> Result(users.SearchAnalytics, dict.Dict(String, String)),
) -> Prop(UserProp) {
  OptionalProp("analytics", fn() { result.map(analytics_fn(), SearchAnalytics) })
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

/// Helper function to encode search filters
fn encode_search_filters(filters: users.SearchFilters) -> json.Json {
  let sort_by_string = case filters.sort_by {
    users.SortByName -> "name"
    users.SortByEmail -> "email"
    users.SortByDate -> "date"
  }

  json.object([
    #("query", json.string(filters.query)),
    #("category", case filters.category {
      option.Some(cat) -> json.string(cat)
      option.None -> json.null()
    }),
    #("sort_by", json.string(sort_by_string)),
  ])
}

/// Helper function to encode search analytics
fn encode_search_analytics(analytics: users.SearchAnalytics) -> json.Json {
  json.object([
    #("total_filtered", json.int(analytics.total_filtered)),
    #("matching_percentage", json.float(analytics.matching_percentage)),
    #("filter_performance_ms", json.int(analytics.filter_performance_ms)),
  ])
}

/// Helper function to encode activity feed
fn encode_activity_feed(feed: users.ActivityFeed) -> json.Json {
  let encode_activity = fn(activity: users.Activity) {
    json.object([
      #("id", json.int(activity.id)),
      #("user_name", json.string(activity.user_name)),
      #("action", json.string(activity.action)),
      #("timestamp", json.string(activity.timestamp)),
    ])
  }

  json.object([
    #("recent_activities", json.array(feed.recent_activities, encode_activity)),
    #("total_activities", json.int(feed.total_activities)),
    #("last_updated", json.string(feed.last_updated)),
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
    // Advanced prop encoders
    SearchFilters(filters) -> encode_search_filters(filters)
    SearchResults(results) -> encode_user_list(results)
    SearchAnalytics(analytics) -> encode_search_analytics(analytics)
    ActivityFeed(feed) -> encode_activity_feed(feed)
  }
}
