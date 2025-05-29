import gleam/dynamic/decode
import gleam/json

// User-related types for the demo inertia example

pub type User {
  User(id: Int, name: String, email: String)
}

pub fn user_to_json(user: User) -> json.Json {
  let User(id:, name:, email:) = user
  json.object([
    #("id", json.int(id)),
    #("name", json.string(name)),
    #("email", json.string(email)),
  ])
}

pub type CreateUserRequest {
  CreateUserRequest(name: String, email: String, token: String)
}

pub fn create_user_request_decoder() -> decode.Decoder(CreateUserRequest) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use token <- decode.field("token", decode.string)
  decode.success(CreateUserRequest(name:, email:, token:))
}

pub type AppState {
  AppState(users: List(User), next_id: Int)
}
