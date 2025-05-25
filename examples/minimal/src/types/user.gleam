// User-related types for the minimal inertia example

pub type User {
  User(id: Int, name: String, email: String)
}

pub type CreateUserRequest {
  CreateUserRequest(name: String, email: String, token: String)
}

pub type AppState {
  AppState(users: List(User), next_id: Int)
}
