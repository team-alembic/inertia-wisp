//// Tests for users create handler.
////
//// This module contains all tests related to the users create handler,
//// including both integration (routing) and unit (business logic) tests.

import data/users
import gleam/json
import gleam/list
import gleam/string
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

  // Should redirect back to create form (303 status)
  assert response.status == 303

  // Should redirect to the create form
  assert list.key_find(response.headers, "location") == Ok("/users/create")

  // Should include validation errors in session cookie
  let assert Ok(cookie) = list.key_find(response.headers, "set-cookie")
  assert string.contains(cookie, "inertia_errors=")
}
