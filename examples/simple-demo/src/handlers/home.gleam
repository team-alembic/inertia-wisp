//// Home page handler for the simple demo application.
////
//// This module demonstrates the Response Builder API design with basic page rendering
//// using DefaultProp and AlwaysProp types. The handler showcases how to construct
//// responses using the fluent builder pattern.

import inertia_wisp/inertia
import props/home_props
import wisp.{type Request, type Response}

/// Handle requests to the home page
///
/// This demonstrates the Response Builder API pattern:
/// 1. Create a response builder with component name
/// 2. Add props using the props() method
/// 3. Generate the response using the response() method
///
/// Example props used:
/// - AlwaysProp: Navigation items (always included)
/// - DefaultProp: Welcome message (included on standard visits)
/// - AlwaysProp: CSRF token (always included for security)
/// - DefaultProp: App version (included on standard visits)
pub fn home_page(req: Request) -> Response {
  let #(user_name, user_email) = get_current_user()
  let props = [
    home_props.welcome_message("Welcome to Simple Demo"),
    home_props.navigation_items(get_navigation_items()),
    home_props.csrf_token(generate_csrf_token()),
    home_props.app_version(get_app_version()),
    home_props.current_user(user_name, user_email),
  ]

  req
  |> inertia.response_builder("Home")
  |> inertia.props(props, home_props.home_prop_to_json)
  |> inertia.response()
}

/// Get navigation items for the application
fn get_navigation_items() -> List(home_props.NavigationItem) {
  [
    home_props.NavigationItem("Home", "/", True),
    home_props.NavigationItem("Dashboard", "/dashboard", False),
    home_props.NavigationItem("Users", "/users", False),
    home_props.NavigationItem("About", "/about", False),
    home_props.NavigationItem("Contact", "/contact", False),
  ]
}

/// Generate a CSRF token for security
fn generate_csrf_token() -> String {
  "abc123xyz789token"
}

/// Get the current application version
fn get_app_version() -> String {
  "1.0.0"
}

/// Get current user information
fn get_current_user() -> #(String, String) {
  #("Demo User", "demo@example.com")
}
