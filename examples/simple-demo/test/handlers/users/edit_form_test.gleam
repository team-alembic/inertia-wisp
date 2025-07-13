//// Tests for users edit form handler.
////
//// This module contains all tests related to the users edit form handler,
//// including both integration (routing) and unit (business logic) tests.

import data/users
import gleam/dynamic/decode
import handlers/users as user_handlers
import inertia_wisp/testing
import sqlight

/// Test user edit form returns correct component and props
pub fn users_edit_form_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = testing.inertia_request()
  let response = user_handlers.users_edit_form(req, "1", db)

  // Should return Users/Edit component
  assert testing.component(response) == Ok("Users/Edit")

  // Should include user data in form
  let form_name_decoder = decode.at(["name"], decode.string)
  let form_email_decoder = decode.at(["email"], decode.string)

  assert testing.prop(response, "form_data", form_name_decoder)
    == Ok("Demo User 1")
  assert testing.prop(response, "form_data", form_email_decoder)
    == Ok("demo1@example.com")

  // Should include user ID
  let user_id_decoder = decode.at(["id"], decode.int)
  assert testing.prop(response, "user", user_id_decoder) == Ok(1)
}

/// Test users edit form route integration
pub fn users_edit_form_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = testing.inertia_request_to("/users/1/edit")
  let response = user_handlers.users_edit_form(req, "1", db)

  assert testing.component(response) == Ok("Users/Edit")
  assert response.status == 200
}

/// Test edit form with invalid user ID
pub fn users_edit_form_invalid_id_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = testing.inertia_request()
  let response = user_handlers.users_edit_form(req, "invalid", db)

  // Should show error page with helpful message
  assert testing.component(response) == Ok("Error")
}

/// Test edit form with non-existent user
pub fn users_edit_form_not_found_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = testing.inertia_request()
  let response = user_handlers.users_edit_form(req, "999", db)

  // Should show error page with helpful message
  assert testing.component(response) == Ok("Error")
}
