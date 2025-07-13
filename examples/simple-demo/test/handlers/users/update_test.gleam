//// Tests for users update handler.
////
//// This module contains all tests related to the users update handler,
//// including both integration (routing) and unit (business logic) tests.

import data/users
import gleam/dynamic/decode
import gleam/json
import handlers/users as user_handlers
import inertia_wisp/testing
import sqlight

/// Test successful user update
pub fn users_update_success_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  // Create POST request with updated data
  let json_data =
    json.object([
      #("name", json.string("Updated Name")),
      #("email", json.string("updated@example.com")),
    ])
  let req = testing.inertia_post("/users/1", json_data)
  let response = user_handlers.users_update(req, "1", db)

  // Should redirect on success (303 status code)
  assert response.status == 303
}

/// Test users update route integration with valid data
pub fn users_update_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let data =
    json.object([
      #("name", json.string("Updated User")),
      #("email", json.string("updated@example.com")),
    ])
  let req = testing.inertia_post("/users/1", data)
  let response = user_handlers.users_update(req, "1", db)

  assert response.status == 303
}

/// Test user update with validation errors
pub fn users_update_validation_errors_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  // Create POST request with invalid data
  let json_data =
    json.object([#("name", json.string("")), #("email", json.string("invalid"))])
  let req = testing.inertia_post("/users/1", json_data)
  let response = user_handlers.users_update(req, "1", db)

  // Should return to edit form with errors
  assert testing.component(response) == Ok("Users/Edit")

  // Should include validation errors with specific messages
  assert testing.prop(response, "errors", decode.at(["name"], decode.string))
    == Ok("Name cannot be empty")
  assert testing.prop(response, "errors", decode.at(["email"], decode.string))
    == Ok("Email format is invalid")
}

/// Test update with invalid user ID
pub fn users_update_invalid_id_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let json_data =
    json.object([
      #("name", json.string("Valid Name")),
      #("email", json.string("valid@example.com")),
    ])
  let req = testing.inertia_post("/users/invalid", json_data)
  let response = user_handlers.users_update(req, "invalid", db)

  // Should show edit form with error message
  assert testing.component(response) == Ok("Users/Edit")
}

/// Test update with non-existent user
pub fn users_update_not_found_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let json_data =
    json.object([
      #("name", json.string("Valid Name")),
      #("email", json.string("valid@example.com")),
    ])
  let req = testing.inertia_post("/users/999", json_data)
  let response = user_handlers.users_update(req, "999", db)

  // Should show edit form with error message
  assert testing.component(response) == Ok("Users/Edit")
}
