import gleam/dict
import gleam/list
import gleam/option
import gleam/string
import data/users

pub fn validate_user_input(
  name: String,
  email: String,
  existing_id: option.Option(Int),
) -> dict.Dict(String, String) {
  let errors = dict.new()

  let trimmed_name = string.trim(name)
  let errors = case trimmed_name {
    "" -> dict.insert(errors, "name", "Name is required")
    _ -> {
      case string.length(trimmed_name) < 2 {
        True ->
          dict.insert(errors, "name", "Name must be at least 2 characters")
        False -> errors
      }
    }
  }

  let trimmed_email = string.trim(email)
  let errors = case trimmed_email {
    "" -> dict.insert(errors, "email", "Email is required")
    _ -> {
      case string.contains(trimmed_email, "@") {
        False -> dict.insert(errors, "email", "Email must contain @")
        True -> {
          // Check for duplicate email (excluding current user if editing)
          let is_duplicate = case existing_id {
            option.Some(id) ->
              users.get_initial_state().users
              |> list.any(fn(user) {
                user.email == trimmed_email && user.id != id
              })
            option.None ->
              users.get_initial_state().users
              |> list.any(fn(user) { user.email == trimmed_email })
          }

          case is_duplicate {
            True -> dict.insert(errors, "email", "Email already exists")
            False -> errors
          }
        }
      }
    }
  }

  errors
}