//// Home page prop types for the simple demo application.
////
//// This module defines the prop types that will be passed to the Home component.
//// Each prop type represents a different piece of data that the frontend will receive.

import gleam/json
import inertia_wisp/prop.{type Prop, AlwaysProp, DefaultProp}

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
    WelcomeMessage(message) -> #("welcome_message", json.string(message))
    NavigationItems(items) -> #(
      "navigation",
      json.array(items, encode_navigation_item),
    )
    CsrfToken(token) -> #("csrf_token", json.string(token))
    AppVersion(version) -> #("app_version", json.string(version))
    CurrentUser(name, email) -> #(
      "current_user",
      json.object([#("name", json.string(name)), #("email", json.string(email))]),
    )
  }
}

/// Encode a HomeProp to JSON only (for Response Builder API)
pub fn home_prop_to_json(prop: HomeProp) -> json.Json {
  case prop {
    WelcomeMessage(message) -> json.string(message)
    NavigationItems(items) -> json.array(items, encode_navigation_item)
    CsrfToken(token) -> json.string(token)
    AppVersion(version) -> json.string(version)
    CurrentUser(name, email) ->
      json.object([#("name", json.string(name)), #("email", json.string(email))])
  }
}

/// Helper function to get default navigation items
pub fn get_default_navigation() -> List(NavigationItem) {
  [
    NavigationItem("Home", "/", True),
    NavigationItem("Users", "/users", False),
  ]
}

/// Encode a single navigation item to JSON
fn encode_navigation_item(item: NavigationItem) -> json.Json {
  json.object([
    #("name", json.string(item.name)),
    #("url", json.string(item.url)),
    #("active", json.bool(item.active)),
  ])
}

// Factory functions for creating Prop(HomeProp) instances

/// Create a welcome message prop (DefaultProp)
pub fn welcome_message(message: String) -> Prop(HomeProp) {
  DefaultProp("welcome_message", WelcomeMessage(message))
}

/// Create a navigation items prop (AlwaysProp)
pub fn navigation_items(items: List(NavigationItem)) -> Prop(HomeProp) {
  AlwaysProp("navigation", NavigationItems(items))
}

/// Create a CSRF token prop (AlwaysProp)
pub fn csrf_token(token: String) -> Prop(HomeProp) {
  AlwaysProp("csrf_token", CsrfToken(token))
}

/// Create an app version prop (DefaultProp)
pub fn app_version(version: String) -> Prop(HomeProp) {
  DefaultProp("app_version", AppVersion(version))
}

/// Create a current user prop (DefaultProp)
pub fn current_user(name: String, email: String) -> Prop(HomeProp) {
  DefaultProp("current_user", CurrentUser(name, email))
}
