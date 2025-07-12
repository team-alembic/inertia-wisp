//// Tests for user handlers using TDD approach for Phase 2.
////
//// This test module follows TDD principles and tests the user handlers
//// to ensure they correctly demonstrate:
//// - LazyProp evaluation for expensive database operations
//// - CRUD operations with proper Inertia responses
//// - Form validation and error handling
//// - JSON response structure for user data
//// - Integration between handlers and data layer

import data/users
import gleam/dynamic/decode
import gleam/http

import gleam/json
import gleam/list
import gleam/option

import gleam/string
import handlers/users as user_handlers
import inertia_wisp/testing
import props/user_props
import sqlight
import wisp/testing as wisp_testing

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

/// Test user creation form page
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

  // Should include original form data
  let form_name_decoder = decode.at(["name"], decode.string)
  let form_email_decoder = decode.at(["email"], decode.string)

  assert testing.prop(response, "form_data", form_name_decoder) == Ok("A")
  assert testing.prop(response, "form_data", form_email_decoder)
    == Ok("invalid-email")

  // Should include validation errors with specific messages
  assert testing.prop(response, "errors", decode.at(["name"], decode.string))
    == Ok("Name is too short")
  assert testing.prop(response, "errors", decode.at(["email"], decode.string))
    == Ok("Email format is invalid")
}

/// Test user show page
pub fn users_show_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

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

/// Test user show with invalid ID
pub fn users_show_invalid_id_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = testing.inertia_request()
  let response = user_handlers.users_show(req, "invalid", db)

  // Should redirect on invalid ID (303 status code)
  assert response.status == 303
}

/// Test user show with non-existent user
pub fn users_show_not_found_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = testing.inertia_request()
  let response = user_handlers.users_show(req, "999", db)

  // Should redirect on non-existent user (303 status code)
  assert response.status == 303
}

/// Test user edit form
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

/// Test user deletion
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

/// Test prop encoding for user data
pub fn user_prop_encoding_test() {
  let sample_user = users.User(1, "John Doe", "john@example.com", "2024-01-01")
  let user_list_prop = user_props.UserList([sample_user])
  let user_count_prop = user_props.UserCount(5)

  // Test individual prop encoding
  let #(list_name, _list_json) = user_props.encode_user_prop(user_list_prop)
  let #(count_name, _count_json) = user_props.encode_user_prop(user_count_prop)

  assert list_name == "users"
  assert count_name == "user_count"
}
