//// Tests for prop factory functions.
////
//// This module contains tests for the factory functions used to create props.
//// We test the actual behavior of props in real handler scenarios.

import gleam/dynamic/decode
import handlers/users as user_handlers
import inertia_wisp/testing
import utils/test_db

/// Test user list prop factory works correctly in index handler
pub fn user_list_prop_integration_test() {
  let assert Ok(db) = test_db.setup_test_database()

  let req = testing.inertia_request()
  let response = user_handlers.users_index(req, db)

  // Verify the user list prop contains actual user data
  let user_list_decoder = decode.list(decode.at(["name"], decode.string))
  let assert Ok(user_names) = testing.prop(response, "users", user_list_decoder)

  // Should contain the demo users we inserted
  assert user_names == ["Demo User 1", "Demo User 2", "Demo User 3"]
}

/// Test form data prop factory works correctly in create form handler
pub fn form_data_prop_integration_test() {
  let assert Ok(db) = test_db.setup_empty_test_database()
  let req = testing.inertia_request()
  let response = user_handlers.users_create_form(req, db)

  // Verify form data prop contains empty initial values
  let form_name_decoder = decode.at(["name"], decode.string)
  let form_email_decoder = decode.at(["email"], decode.string)

  assert testing.prop(response, "form_data", form_name_decoder) == Ok("")
  assert testing.prop(response, "form_data", form_email_decoder) == Ok("")
}

/// Test search query prop factory works correctly with URL parameters
pub fn search_query_prop_integration_test() {
  let assert Ok(db) = test_db.setup_test_database()

  let req = testing.inertia_request_to("/users?search=Demo")
  let response = user_handlers.users_index(req, db)

  // Verify search query prop contains the URL parameter value
  assert testing.prop(response, "search_query", decode.string) == Ok("Demo")
}
