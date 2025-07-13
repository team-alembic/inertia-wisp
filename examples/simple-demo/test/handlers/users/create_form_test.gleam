//// Tests for users create form handler.
////
//// This module contains all tests related to the users create form handler,
//// including both integration (routing) and unit (business logic) tests.

import data/users
import gleam/dynamic/decode
import handlers/users as user_handlers
import inertia_wisp/testing
import sqlight

/// Test user creation form page returns correct component and props
pub fn users_create_form_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let req = testing.inertia_request()
  let response = user_handlers.users_create_form(req, db)

  // Should return Users/Create component
  assert testing.component(response) == Ok("Users/Create")

  // Should include empty form data
  let form_name_decoder = decode.at(["name"], decode.string)
  let form_email_decoder = decode.at(["email"], decode.string)

  assert testing.prop(response, "form_data", form_name_decoder) == Ok("")
  assert testing.prop(response, "form_data", form_email_decoder) == Ok("")
}

/// Test users create form route integration
pub fn users_create_form_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = testing.inertia_request_to("/users/create")
  let response = user_handlers.users_create_form(req, db)

  assert testing.component(response) == Ok("Users/Create")
  assert response.status == 200
}
