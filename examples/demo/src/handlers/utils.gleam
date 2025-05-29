import gleam/int
import gleam/json
import inertia_wisp/inertia

// Common authentication and CSRF props used across all handlers
pub fn assign_common_props(context) {
  context
  |> inertia.assign_always_props([
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
