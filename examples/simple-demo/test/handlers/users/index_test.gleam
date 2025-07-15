//// Tests for users index handler.
////
//// This module contains all tests related to the users index handler,
//// including both integration (routing) and unit (business logic) tests.

import data/users
import gleam/dynamic/decode
import gleam/list
import gleam/result
import gleam/string
import handlers/users as user_handlers
import inertia_wisp/testing
import sqlight

/// Test users index page returns correct component and props
pub fn users_index_page_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = testing.inertia_request()
  let response = user_handlers.users_index(req, db)

  // Should return Users/Index component
  assert testing.component(response) == Ok("Users/Index")

  // Should include user list as LazyProp (expensive operation)
  let user_list_decoder = decode.list(decode.at(["name"], decode.string))
  let assert Ok(user_names) = testing.prop(response, "users", user_list_decoder)
  assert list.length(user_names) >= 3

  // Should include user count as LazyProp
  assert testing.prop(response, "user_count", decode.int) == Ok(3)

  // Should include search query (empty by default)
  assert testing.prop(response, "search_query", decode.string) == Ok("")
}

/// Test users index with search functionality
pub fn users_index_with_search_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  // Create request with search query
  let req = testing.inertia_request_to("/users?search=Demo")
  let response = user_handlers.users_index(req, db)

  // Should include search query in props
  assert testing.prop(response, "search_query", decode.string) == Ok("Demo")

  // Should include filtered users
  let user_list_decoder = decode.list(decode.at(["name"], decode.string))
  let assert Ok(user_names) = testing.prop(response, "users", user_list_decoder)

  // All returned users should contain "Demo"
  list.each(user_names, fn(name) {
    let name_lower = string.lowercase(name)
    assert string.contains(name_lower, "demo")
  })
}

/// Test users index route integration
pub fn users_index_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = testing.inertia_request_to("/users")
  let response = user_handlers.users_index(req, db)

  assert testing.component(response) == Ok("Users/Index")
  assert response.status == 200
}

/// Test users index with search query route integration
pub fn users_index_search_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = testing.inertia_request_to("/users?search=Demo")
  let response = user_handlers.users_index(req, db)

  assert testing.component(response) == Ok("Users/Index")
  assert testing.prop(response, "search_query", decode.string) == Ok("Demo")
}

/// Test that regular request EXCLUDES optional analytics prop
/// This demonstrates that OptionalProp is excluded by default for performance
pub fn users_index_excludes_analytics_by_default_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = testing.inertia_request()
  let response = user_handlers.users_index(req, db)

  // Should NOT include analytics in regular request (expensive computation)
  let analytics_result =
    testing.prop(response, "user_analytics", decode.dynamic)
  assert analytics_result |> result.is_error
}

/// Test that partial request with "only" parameter INCLUDES optional analytics
/// This demonstrates OptionalProp inclusion when specifically requested
pub fn users_index_includes_analytics_when_requested_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  // Create partial request that specifically asks for analytics using proper header
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user_analytics"])
    |> testing.partial_component("Users/Index")
  let response = user_handlers.users_index(req, db)

  // Should include analytics when specifically requested
  let analytics_decoder = decode.at(["total_users"], decode.int)
  let assert Ok(total_users) =
    testing.prop(response, "user_analytics", analytics_decoder)
  assert total_users == 3
}

/// Test analytics computation returns expected structure
/// This tests the actual analytics data structure and computation
pub fn users_analytics_computation_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  // Test analytics computation directly
  let assert Ok(analytics) = users.compute_user_analytics(db)

  assert analytics.total_users == 3
  assert analytics.active_users == 2
  // 80% of 3 = 2.4 -> 2
  assert analytics.growth_rate == 15.5
  assert analytics.new_users_this_month == 0
  // 12% of 3 = 0.36 -> 0
  assert analytics.average_session_duration == 8.5
}
