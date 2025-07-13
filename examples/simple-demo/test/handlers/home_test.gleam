//// Tests for home handler.
////
//// This module contains all tests related to the home handler,
//// including both integration (routing) and unit (business logic) tests.

import handlers/home
import inertia_wisp/testing

/// Test home page returns correct component
pub fn home_page_test() {
  let req = testing.inertia_request()
  let response = home.home_page(req)

  // Should return Home component
  assert testing.component(response) == Ok("Home")
  assert response.status == 200
}

/// Test home route integration
pub fn home_route_test() {
  let req = testing.inertia_request_to("/")
  let response = home.home_page(req)

  assert testing.component(response) == Ok("Home")
  assert response.status == 200
}
