import gleam/dict
import gleam/dynamic/decode
import gleam/option
import shared_types/users
import sqlight
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

// Declarative validation function using the new API - exactly as requested
pub fn validate_user_input(
  name: String,
  email: String,
) -> validate.ValidationResult {
  use <- validate.field("name", name, name_validator)
  use <- validate.field("email", email, email_validator)
  validate.Valid
}

pub fn validate_create_request(
  create_request: users.CreateUserRequest,
  db: sqlight.Connection,
) -> validate.ValidationResult {
  validate.accumulate_errors([
    validate_user_input(create_request.name, create_request.email),
    validate_unique_email(option.None, create_request.email, db),
  ])
}

pub fn validate_update_request(
  user: users.User,
  update_request: users.EditUserRequest,
  db: sqlight.Connection,
) -> validate.ValidationResult {
  validate.accumulate_errors([
    validate_user_input(update_request.name, update_request.email),
    validate_unique_email(option.Some(user.id), update_request.email, db),
  ])
}

fn validate_unique_email(id: option.Option(Int), email, db) {
  let #(sql, params) = case id {
    option.None -> #("SELECT 1 FROM users WHERE email = $1", [
      sqlight.text(email),
    ])
    option.Some(id) -> #("SELECT 1 FROM users WHERE email = $1 AND id != $2", [
      sqlight.text(email),
      sqlight.int(id),
    ])
  }
  let result =
    sqlight.query(
      sql,
      on: db,
      with: params,
      expecting: decode.at([0], decode.int),
    )

  case result {
    Ok([]) -> validate.Valid
    _ -> validate.Invalid(dict.from_list([#("email", "is already taken")]))
  }
}
