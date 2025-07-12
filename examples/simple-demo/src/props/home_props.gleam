//// Home page prop types for the simple demo application.
////
//// This module defines the prop types that will be passed to the Home component.
//// Each prop type represents a different piece of data that the frontend will receive.

import gleam/json

/// Represents the different types of props that can be sent to the Home page
pub type HomeProp {
  /// Welcome message displayed on the home page
  WelcomeMessage(String)
  /// Current user information
  CurrentUser(name: String, email: String)
  /// Application version information
  AppVersion(String)
  /// Navigation items for the header
  NavigationItems(List(NavigationItem))
  /// CSRF token for form security
  CsrfToken(String)
}

/// Navigation item structure
pub type NavigationItem {
  NavigationItem(name: String, url: String, active: Bool)
}

/// Encode a HomeProp to a name/JSON pair for Inertia
pub fn encode_home_prop(prop: HomeProp) -> #(String, json.Json) {
  case prop {
    WelcomeMessage(message) -> encode_welcome_message(message)
    NavigationItems(items) -> encode_navigation_items(items)
    CsrfToken(token) -> encode_csrf_token(token)
    AppVersion(version) -> encode_app_version(version)
    CurrentUser(name, email) -> encode_current_user(name, email)
  }
}

/// Helper function to get default navigation items
pub fn get_default_navigation() -> List(NavigationItem) {
  [
    NavigationItem("Home", "/", True),
    NavigationItem("About", "/about", False),
    NavigationItem("Contact", "/contact", False),
  ]
}

/// Encode welcome message prop
fn encode_welcome_message(message: String) -> #(String, json.Json) {
  #("welcome_message", json.string(message))
}

/// Encode navigation items prop
fn encode_navigation_items(items: List(NavigationItem)) -> #(String, json.Json) {
  #("navigation", json.array(items, encode_navigation_item))
}

/// Encode CSRF token prop
fn encode_csrf_token(token: String) -> #(String, json.Json) {
  #("csrf_token", json.string(token))
}

/// Encode app version prop
fn encode_app_version(version: String) -> #(String, json.Json) {
  #("app_version", json.string(version))
}

/// Encode current user prop
fn encode_current_user(name: String, email: String) -> #(String, json.Json) {
  #(
    "current_user",
    json.object([#("name", json.string(name)), #("email", json.string(email))]),
  )
}

/// Encode a single navigation item to JSON
fn encode_navigation_item(item: NavigationItem) -> json.Json {
  json.object([
    #("name", json.string(item.name)),
    #("url", json.string(item.url)),
    #("active", json.bool(item.active)),
  ])
}
