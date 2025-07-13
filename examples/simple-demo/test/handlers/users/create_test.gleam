//// Tests for users create handler.
////
//// This module contains all tests related to the users create handler,
//// including both integration (routing) and unit (business logic) tests.

import data/users
import gleam/dynamic/decode
import gleam/json
import handlers/users as user_handlers
import inertia_wisp/testing
import sqlight

/// Test successful user creation
pub fn users_create_success_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  // Create POST request with form data
  let json_data =
    json.object([
      #("name", json.string("John Doe")),
      #("email", json.string("john@example.com")),
    ])
  let req = testing.inertia_post("/users", json_data)
  let response = user_handlers.users_create(req, db)

  // Should redirect to users index (303 status code)
  assert response.status == 303
}

/// Test users create POST route integration with valid data
pub fn users_create_post_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let data =
    json.object([
      #("name", json.string("Test User")),
      #("email", json.string("test@example.com")),
    ])
  let req = testing.inertia_post("/users", data)
  let response = user_handlers.users_create(req, db)

  assert response.status == 303
}

/// Test user creation with validation errors
pub fn users_create_validation_errors_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  // Create POST request with invalid data
  let json_data =
    json.object([
      #("name", json.string("A")),
      #("email", json.string("invalid-email")),
    ])
  let req = testing.inertia_post("/users", json_data)
  let response = user_handlers.users_create(req, db)

  // Should return to create form with errors
  assert testing.component(response) == Ok("Users/Create")

  // Should include validation errors with specific messages (no form data needed)
  assert testing.prop(response, "errors", decode.at(["name"], decode.string))
    == Ok("Name is too short")
  assert testing.prop(response, "errors", decode.at(["email"], decode.string))
    == Ok("Email format is invalid")
}
