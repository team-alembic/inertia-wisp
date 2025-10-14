//// Shared user types
////
//// This module defines user types that are shared between
//// backend (Gleam) and frontend (TypeScript via Zod schemas).

import gleam/json

/// User data
pub type User {
  User(id: Int, name: String, email: String)
}

/// Encode user data to JSON
pub fn user_to_json(user: User) -> json.Json {
  let User(id:, name:, email:) = user
  json.object([
    #("id", json.int(id)),
    #("name", json.string(name)),
    #("email", json.string(email)),
  ])
}
