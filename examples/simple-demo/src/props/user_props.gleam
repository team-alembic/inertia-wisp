//// User page prop types for the simple demo application.
////
//// This module defines the prop types that will be passed to user-related components.
//// It demonstrates LazyProp usage for expensive operations like user listing and
//// showcases dynamic data handling with database integration.

import data/users
import gleam/json

/// Represents the different types of props that can be sent to user pages
pub type UserProp {
  /// List of users (expensive operation, good for LazyProp)
  UserList(List(users.User))
  /// Total user count (expensive operation)
  UserCount(Int)
  /// Individual user data
  UserData(users.User)
  /// Form data for user creation/editing
  UserFormData(name: String, email: String)
  /// Search query for user filtering
  SearchQuery(String)
  /// Pagination information
  PaginationInfo(current_page: Int, total_pages: Int, per_page: Int)
  /// Loading state for expensive operations
  LoadingState(is_loading: Bool)
}

/// Encode a UserProp to a name/JSON pair for Inertia
pub fn encode_user_prop(prop: UserProp) -> #(String, json.Json) {
  case prop {
    UserList(users) -> #("users", encode_user_list(users))
    UserCount(count) -> #("user_count", json.int(count))
    UserData(user) -> #("user", encode_user(user))
    UserFormData(name, email) -> #(
      "form_data",
      json.object([#("name", json.string(name)), #("email", json.string(email))]),
    )
    SearchQuery(query) -> #("search_query", json.string(query))
    PaginationInfo(current, total, per_page) -> #(
      "pagination",
      encode_pagination(current, total, per_page),
    )
    LoadingState(is_loading) -> #("is_loading", json.bool(is_loading))
  }
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
