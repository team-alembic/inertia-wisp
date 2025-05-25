import gleam/list
import types/user.{type User, User, type AppState, AppState}

// Global state for the demo (in a real app, use a proper database)
pub fn get_initial_state() -> AppState {
  AppState(
    users: [
      User(id: 1, name: "Alice", email: "alice@example.com"),
      User(id: 2, name: "Bob", email: "bob@example.com"),
    ],
    next_id: 3,
  )
}

pub fn find_user_by_id(id: Int) -> Result(User, Nil) {
  get_initial_state().users
  |> list.find(fn(user) { user.id == id })
}