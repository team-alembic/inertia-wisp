import data/users
import gleam/dict
import gleam/list
import gleam/option
import validate

// Individual validator functions
pub fn name_validator(name: String) -> Result(String, String) {
  validate.combine([validate.non_empty_string, validate.min_length(2)])(name)
}

pub fn email_validator(email: String) -> Result(String, String) {
  validate.combine([validate.non_empty_string, validate.contains("@")])(email)
}

pub fn duplicate_email_validator(
  existing_id: option.Option(Int),
) -> validate.Validator(String) {
  fn(email: String) -> Result(String, String) {
    let is_duplicate = case existing_id {
      option.Some(id) ->
        users.get_initial_state().users
        |> list.any(fn(user) { user.email == email && user.id != id })
      option.None ->
        users.get_initial_state().users
        |> list.any(fn(user) { user.email == email })
    }

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
) -> Result(Nil, dict.Dict(String, String)) {
  validate.validation_pipeline(fn() {
    use <- validate.validate_field("name", name, name_validator)
    use <- validate.validate_field("email", email, email_validator)
    use <- validate.validate_field(
      "email",
      email,
      duplicate_email_validator(existing_id),
    )
    validate.validation_valid(Nil)
  })
}
