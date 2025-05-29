import data/users
import gleam/list
import gleam/option
import types/user
import validate

// Individual validator functions
pub fn name_validator(name: String) -> Result(String, String) {
  name
  |> validate.combine([validate.non_empty_string, validate.min_length(2)])
}

pub fn email_validator(email: String) -> Result(String, String) {
  email
  |> validate.combine([validate.non_empty_string, validate.contains("@")])
}

pub fn duplicate_email_validator(
  existing_id: option.Option(Int),
) -> validate.Validator(String) {
  fn(email: String) -> Result(String, String) {
    let matching_user = fn(user: user.User) {
      user.email == email && option.Some(user.id) != existing_id
    }

    let is_duplicate =
      users.get_initial_state().users
      |> list.any(matching_user)

    case is_duplicate {
      True -> Error("already exists")
      False -> Ok(email)
    }
  }
}

// Declarative validation function using the new API - exactly as requested
pub fn validate_user_input(
  name: String,
  email: String,
  existing_id: option.Option(Int),
) -> validate.ValidationResult {
  use <- validate.field("name", name, name_validator)
  use <- validate.field("email", email, email_validator)
  use <- validate.field("email", email, duplicate_email_validator(existing_id))
  validate.Valid
}
