//// Integration tests for user management routes.
////
//// This module tests that all the user management routes are properly
//// configured and return the expected responses.

import data/users
import gleam/bit_array
import gleam/dynamic/decode
import gleam/http
import gleam/json
import handlers/users as user_handlers
import inertia_wisp/testing
import sqlight
import wisp/testing as wisp_testing

/// Test users index route returns the correct component
pub fn users_index_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = testing.inertia_request_to("/users")
  let response = user_handlers.users_index(req, db)

  assert testing.component(response) == Ok("Users/Index")
  assert response.status == 200
}

/// Test users create form route returns the correct component
pub fn users_create_form_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let req = testing.inertia_request_to("/users/create")
  let response = user_handlers.users_create_form(req, db)

  assert testing.component(response) == Ok("Users/Create")
  assert response.status == 200
}

/// Test users create POST route with valid data redirects
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

/// Test users show route returns the correct component
pub fn users_show_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = testing.inertia_request_to("/users/1")
  let response = user_handlers.users_show(req, "1", db)

  assert testing.component(response) == Ok("Users/Show")
  assert response.status == 200
}

/// Test users edit form route returns the correct component
pub fn users_edit_form_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = testing.inertia_request_to("/users/1/edit")
  let response = user_handlers.users_edit_form(req, "1", db)

  assert testing.component(response) == Ok("Users/Edit")
  assert response.status == 200
}

/// Test users update route with valid data redirects
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

/// Test users delete route redirects to users index
pub fn users_delete_route_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req =
    wisp_testing.request(http.Delete, "/users/1", [], bit_array.from_string(""))
  let response = user_handlers.users_delete(req, "1", db)

  assert response.status == 303
}

/// Test invalid user ID routes redirect appropriately
pub fn invalid_user_id_routes_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  // Test show with invalid ID
  let req = testing.inertia_request_to("/users/999")
  let response = user_handlers.users_show(req, "999", db)
  assert response.status == 303

  // Test edit with invalid ID
  let req = testing.inertia_request_to("/users/999/edit")
  let response = user_handlers.users_edit_form(req, "999", db)
  assert response.status == 303
}

/// Test users index with search query
pub fn users_index_search_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let req = testing.inertia_request_to("/users?search=Demo")
  let response = user_handlers.users_index(req, db)

  assert testing.component(response) == Ok("Users/Index")
  assert testing.prop(response, "search_query", decode.string) == Ok("Demo")
}
