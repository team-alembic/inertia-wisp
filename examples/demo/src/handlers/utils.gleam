import gleam/int
import gleam/json
import inertia_wisp
import types/user.{type User}

// Common authentication and CSRF props used across all handlers
pub fn assign_common_props(context) {
  context
  |> inertia_wisp.assign_always_props([
    #(
      "auth",
      json.object([
        #("authenticated", json.bool(True)),
        #("user", json.string("demo_user")),
      ]),
    ),
    #("csrf_token", json.string("abc123xyz")),
  ])
}

// Parse user ID from string with consistent error handling
pub fn parse_user_id(id_str: String) -> Result(Int, Nil) {
  int.parse(id_str)
}

// Serialize user data to JSON consistently across handlers
pub fn serialize_user_data(user: User) -> json.Json {
  json.object([
    #("id", json.int(user.id)),
    #("name", json.string(user.name)),
    #("email", json.string(user.email)),
  ])
}
