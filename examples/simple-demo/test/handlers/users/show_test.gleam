//// Tests for users show handler.
////
//// This module contains all tests related to the users show handler,
//// including both integration (routing) and unit (business logic) tests.

import data/users
import gleam/dynamic/decode
import gleam/result
import gleam/string
import handlers/users as user_handlers
import inertia_wisp/testing
import sqlight
import utils/test_db

/// Test user show page returns correct component and props
pub fn users_show_test() {
  let assert Ok(db) = test_db.setup_test_database()

  let req = testing.inertia_request()
  let response = user_handlers.users_show(req, "1", db)

  // Should return Users/Show component
  assert testing.component(response) == Ok("Users/Show")

  // Should include user data with specific values
  let user_name_decoder = decode.at(["name"], decode.string)
  let user_email_decoder = decode.at(["email"], decode.string)
  let user_id_decoder = decode.at(["id"], decode.int)

  assert testing.prop(response, "user", user_id_decoder) == Ok(1)
  assert testing.prop(response, "user", user_name_decoder) == Ok("Demo User 1")
  assert testing.prop(response, "user", user_email_decoder)
    == Ok("demo1@example.com")
}

/// Test user show route integration
pub fn users_show_route_test() {
  let assert Ok(db) = test_db.setup_test_database()

  let req = testing.inertia_request_to("/users/1")
  let response = user_handlers.users_show(req, "1", db)

  assert testing.component(response) == Ok("Users/Show")
  assert response.status == 200
}

/// Test user show with invalid ID
pub fn users_show_invalid_id_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = testing.inertia_request()
  let response = user_handlers.users_show(req, "invalid", db)

  // Should show error page with helpful message
  assert testing.component(response) == Ok("Error")
  assert testing.prop(response, "errors", decode.at(["message"], decode.string))
    |> result.map(string.contains(_, "Invalid user ID"))
    == Ok(True)
}

/// Test user show with non-existent user
pub fn users_show_not_found_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = testing.inertia_request()
  let response = user_handlers.users_show(req, "999", db)

  // Should show error page with helpful message
  assert testing.component(response) == Ok("Error")
  assert testing.prop(response, "errors", decode.at(["message"], decode.string))
    |> result.map(string.contains(_, "User not found"))
    == Ok(True)
}
