//// Tests for users delete handler.
////
//// This module contains all tests related to the users delete handler,
//// including both integration (routing) and unit (business logic) tests.

import data/users

import gleam/dynamic/decode
import gleam/http
import gleam/option
import gleam/result
import gleam/string
import handlers/users as user_handlers
import inertia_wisp/testing
import sqlight
import utils/test_db
import wisp/simulate as wisp_simulate

/// Test user deletion success
pub fn users_delete_test() {
  let assert Ok(db) = test_db.setup_test_database()

  let req = wisp_simulate.request(http.Post, "/users/1/delete")
  let response = user_handlers.users_delete(req, "1", db)

  // Should redirect after deletion (303 status code)
  assert response.status == 303

  // User should no longer exist
  let assert Ok(option.None) = users.get_user_by_id(db, 1)
}

/// Test users delete route integration
pub fn users_delete_route_test() {
  let assert Ok(db) = test_db.setup_test_database()

  let req = wisp_simulate.request(http.Delete, "/users/1")
  let response = user_handlers.users_delete(req, "1", db)

  assert response.status == 303
}

/// Test delete with invalid user ID
pub fn users_delete_invalid_id_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = wisp_simulate.request(http.Post, "/users/invalid/delete")
  let response = user_handlers.users_delete(req, "invalid", db)

  // Should show error component for invalid ID
  assert testing.component(response) == Ok("Error")
  assert testing.prop(response, "errors", decode.at(["message"], decode.string))
    |> result.map(string.contains(_, "Invalid user ID"))
    == Ok(True)
}

/// Test delete with non-existent user
pub fn users_delete_not_found_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = wisp_simulate.request(http.Post, "/users/999/delete")
  let response = user_handlers.users_delete(req, "999", db)

  // Should redirect (deleting non-existent user is successful no-op)
  assert response.status == 303
}
