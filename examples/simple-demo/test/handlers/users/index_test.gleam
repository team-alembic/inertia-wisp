//// Tests for users index handler.
////
//// This module contains all tests related to the users index handler,
//// including both integration (routing) and unit (business logic) tests.

import data/users
import gleam/dynamic/decode
import gleam/list
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
