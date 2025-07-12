//// Home page handler for the simple demo application.
////
//// This module demonstrates the new inertia.eval API design with basic page rendering
//// using DefaultProp and AlwaysProp types. The handler showcases how to construct
//// Page objects directly without using the InertiaContext type.

import inertia_wisp/inertia
import inertia_wisp/internal/types
import props/home_props
import wisp.{type Request, type Response}

/// Handle requests to the home page
///
/// This demonstrates the new API pattern:
/// 1. Create a list of props with different types
/// 2. Use inertia.eval() to construct a Page object
/// 3. Use inertia.render() to generate the response
///
/// Example props used:
/// - AlwaysProp: Navigation items (always included)
/// - DefaultProp: Welcome message (included on standard visits)
/// - AlwaysProp: CSRF token (always included for security)
/// - DefaultProp: App version (included on standard visits)
pub fn home_page(req: Request) -> Response {
  let props = build_home_page_props()
  let page = inertia.eval(req, "Home", props, home_props.encode_home_prop)
  inertia.render(req, page)
}

/// Build the complete props list for the home page
fn build_home_page_props() -> List(types.Prop(home_props.HomeProp)) {
  let #(user_name, user_email) = get_current_user()
  [
    types.DefaultProp(
      "welcome_message",
      home_props.WelcomeMessage("Welcome to Simple Demo"),
    ),
    types.AlwaysProp(
      "navigation",
      home_props.NavigationItems(get_navigation_items()),
    ),
    types.AlwaysProp("csrf_token", home_props.CsrfToken(generate_csrf_token())),
    types.DefaultProp("app_version", home_props.AppVersion(get_app_version())),
    types.DefaultProp(
      "current_user",
      home_props.CurrentUser(user_name, user_email),
    ),
  ]
}

/// Get navigation items for the application
fn get_navigation_items() -> List(home_props.NavigationItem) {
  [
    home_props.NavigationItem("Home", "/", True),
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
