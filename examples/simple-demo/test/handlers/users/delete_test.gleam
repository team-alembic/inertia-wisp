//// Tests for users delete handler.
////
//// This module contains all tests related to the users delete handler,
//// including both integration (routing) and unit (business logic) tests.

import data/users
import gleam/bit_array
import gleam/http
import gleam/option
import handlers/users as user_handlers
import sqlight
import wisp/testing as wisp_testing

/// Test user deletion success
pub fn users_delete_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = wisp_testing.request(http.Post, "/users/1/delete", [], <<>>)
  let response = user_handlers.users_delete(req, "1", db)

  // Should redirect after deletion (303 status code)
  assert response.status == 303

  // User should no longer exist
  let assert Ok(option.None) = users.get_user_by_id(db, 1)
}

/// Test users delete route integration
pub fn users_delete_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req =
    wisp_testing.request(http.Delete, "/users/1", [], bit_array.from_string(""))
  let response = user_handlers.users_delete(req, "1", db)

  assert response.status == 303
}

/// Test delete with invalid user ID
pub fn users_delete_invalid_id_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = wisp_testing.request(http.Post, "/users/invalid/delete", [], <<>>)
  let response = user_handlers.users_delete(req, "invalid", db)

  // Should redirect (graceful handling of invalid ID)
  assert response.status == 303
}

/// Test delete with non-existent user
pub fn users_delete_not_found_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = wisp_testing.request(http.Post, "/users/999/delete", [], <<>>)
  let response = user_handlers.users_delete(req, "999", db)

  // Should redirect (graceful handling of non-existent user)
  assert response.status == 303
}
