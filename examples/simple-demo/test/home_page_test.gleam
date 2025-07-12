//// Tests for home page functionality using the new inertia.eval API.
////
//// This test module follows TDD principles and tests the home page handler
//// to ensure it correctly demonstrates:
//// - Component name is "Home"
//// - URL path construction
//// - Static props are included (DefaultProp and AlwaysProp)
//// - Prop encoding/decoding works correctly
//// - Response format is valid for both JSON and HTML requests

import gleam/dynamic/decode
import gleam/list
import gleam/string
import handlers/home
import inertia_wisp/testing
import props/home_props
import wisp/testing as wisp_testing

/// Test that home page returns correct component name
pub fn home_page_component_name_test() {
  let req = testing.inertia_request()
  let response = home.home_page(req)

  assert testing.component(response) == Ok("Home")
}

/// Test that home page constructs URL correctly for root path
pub fn home_page_url_construction_test() {
  let req = testing.inertia_request()
  let response = home.home_page(req)

  assert testing.url(response) == Ok("/")
}

/// Test that home page includes welcome message prop
pub fn home_page_welcome_message_prop_test() {
  let req = testing.inertia_request()
  let response = home.home_page(req)

  // Should include welcome message as a DefaultProp
  assert testing.prop(response, "welcome_message", decode.string)
    == Ok("Welcome to Simple Demo")
}

/// Test that home page includes navigation items as AlwaysProp
pub fn home_page_navigation_always_included_test() {
  let req = testing.inertia_request()
  let response = home.home_page(req)

  // Navigation should always be included
  let nav_decoder = decode.list(decode.at(["name"], decode.string))
  let result = testing.prop(response, "navigation", nav_decoder)

  assert result == Ok(["Home", "About", "Contact"])
}

/// Test that home page includes CSRF token as AlwaysProp
pub fn home_page_csrf_token_always_included_test() {
  let req = testing.inertia_request()
  let response = home.home_page(req)

  // CSRF token should always be included for security
  let result = testing.prop(response, "csrf_token", decode.string)

  // Should be a non-empty string
  let assert Ok(token) = result
  assert token != ""
  assert string.length(token) > 10
}

/// Test that home page includes app version as DefaultProp
pub fn home_page_app_version_prop_test() {
  let req = testing.inertia_request()
  let response = home.home_page(req)

  // Should include app version
  assert testing.prop(response, "app_version", decode.string) == Ok("1.0.0")
}

/// Test that home page includes current user information
pub fn home_page_current_user_prop_test() {
  let req = testing.inertia_request()
  let response = home.home_page(req)

  // Should include current user info
  let user_name_decoder = decode.at(["name"], decode.string)
  let user_email_decoder = decode.at(["email"], decode.string)

  assert testing.prop(response, "current_user", user_name_decoder)
    == Ok("Demo User")
  assert testing.prop(response, "current_user", user_email_decoder)
    == Ok("demo@example.com")
}

/// Test response format for non-Inertia request (HTML response)
pub fn home_page_html_response_test() {
  let req = wisp_testing.get("/", [])
  // No Inertia headers
  let response = home.home_page(req)

  // Should still return valid component name when extracted from HTML
  assert testing.component(response) == Ok("Home")

  // Should include props in HTML data-page attribute
  assert testing.prop(response, "welcome_message", decode.string)
    == Ok("Welcome to Simple Demo")
}

/// Test that all expected props are present in response
pub fn home_page_all_props_present_test() {
  let req = testing.inertia_request()
  let response = home.home_page(req)

  // Test string props
  let string_props = ["welcome_message", "csrf_token", "app_version"]
  list.each(string_props, fn(prop_name) {
    let assert Ok(_) = testing.prop(response, prop_name, decode.string)
  })

  // Test navigation prop separately (it's a list)
  let assert Ok(_) =
    testing.prop(
      response,
      "navigation",
      decode.list(decode.at(["name"], decode.string)),
    )

  // Test current_user prop separately (it's an object)
  let assert Ok(_) =
    testing.prop(response, "current_user", decode.at(["name"], decode.string))
}

/// Test response version and other metadata
pub fn home_page_response_metadata_test() {
  let req = testing.inertia_request()
  let response = home.home_page(req)

  // Test Inertia metadata
  assert testing.version(response) == Ok("1")
  assert testing.encrypt_history(response) == Ok(False)
  assert testing.clear_history(response) == Ok(False)
}

/// Test that prop encoding produces valid JSON structure
pub fn home_page_prop_encoding_test() {
  let welcome_prop = home_props.WelcomeMessage("Test Message")
  let navigation_items = home_props.get_default_navigation()
  let nav_prop = home_props.NavigationItems(navigation_items)

  // Test individual prop encoding
  let #(welcome_name, _welcome_json) = home_props.encode_home_prop(welcome_prop)
  let #(nav_name, _nav_json) = home_props.encode_home_prop(nav_prop)

  assert welcome_name == "welcome_message"
  assert nav_name == "navigation"
  // JSON should be valid (this will fail until we implement the encoder)
  // We can't test the exact JSON structure yet, but we can test the names
}
