import gleam/dict
import gleam/option
import inertia_gleam/validation

// Example 1: Basic validators
pub fn name_validator(name: String) -> Result(String, String) {
  validation.combine([
    validation.non_empty_string,
    validation.min_length(2),
    validation.max_length(50),
  ])(name)
}

pub fn email_validator(email: String) -> Result(String, String) {
  validation.combine([validation.non_empty_string, validation.contains("@")])(
    email,
  )
}

pub fn age_validator(age: String) -> Result(String, String) {
  case validation.non_empty_string(age) {
    Ok(trimmed) -> {
      // You could add more specific age validation here
      Ok(trimmed)
    }
    Error(msg) -> Error(msg)
  }
}

// Example 2: Custom validator
pub fn password_validator(password: String) -> Result(String, String) {
  case validation.non_empty_string(password) {
    Ok(p) -> {
      case validation.min_length(8)(p) {
        Ok(valid_p) -> {
          // Simple check for special characters
          case validation.contains("@")(valid_p) {
            Ok(_) -> Ok(valid_p)
            Error(_) -> {
              case validation.contains("!")(valid_p) {
                Ok(_) -> Ok(valid_p)
                Error(_) -> {
                  case validation.contains("#")(valid_p) {
                    Ok(_) -> Ok(valid_p)
                    Error(_) ->
                      Error(
                        "must contain at least one special character (@, !, or #)",
                      )
                  }
                }
              }
            }
          }
        }
        Error(msg) -> Error(msg)
      }
    }
    Error(msg) -> Error(msg)
  }
}

// Example 3: Simple validation with exact syntax requested
pub fn validate(
  value: a,
  validator: validation.Validator(a),
  field_name: String,
  continue: fn() -> validation.ValidationResult(b),
) -> validation.ValidationResult(b) {
  validation.validate_as(value, validator, field_name, continue)
}

pub fn validate_id(
  value: option.Option(a),
  validator: validation.Validator(a),
  field_name: String,
  continue: fn() -> validation.ValidationResult(b),
) -> validation.ValidationResult(b) {
  validation.validate_optional_field(value, validator, field_name, continue)
}

pub fn validate_user_signup(
  name: String,
  email: String,
  password: String,
  age: option.Option(String),
) -> Result(Nil, dict.Dict(String, String)) {
  validation.validation_pipeline(fn() {
    use <- validate(name, name_validator, "name")
    use <- validate(email, email_validator, "email")
    use <- validate(password, password_validator, "password")
    use <- validate_id(age, age_validator, "age")
    validation.validation_valid(Nil)
  })
}

// Example 4: Alternative syntax using the built-in functions
pub fn validate_user_profile(
  name: String,
  email: String,
  bio: option.Option(String),
) -> Result(Nil, dict.Dict(String, String)) {
  validation.validation_pipeline(fn() {
    use <- validation.validate_as(name, name_validator, "name")
    use <- validation.validate_as(email, email_validator, "email")
    use <- validation.validate_optional_field(
      bio,
      validation.max_length(500),
      "bio",
    )
    validation.validation_valid(Nil)
  })
}

// Example 5: More complex validation with custom logic
pub fn username_validator(username: String) -> Result(String, String) {
  validation.combine([
    validation.non_empty_string,
    validation.min_length(3),
    validation.max_length(20),
  ])(username)
}

pub fn validate_account_creation(
  username: String,
  email: String,
  password: String,
  confirm_password: String,
) -> Result(Nil, dict.Dict(String, String)) {
  let password_match_validator = fn(confirm: String) -> Result(String, String) {
    case confirm == password {
      True -> Ok(confirm)
      False -> Error("passwords do not match")
    }
  }

  validation.validation_pipeline(fn() {
    use <- validation.validate_as(username, username_validator, "username")
    use <- validation.validate_as(email, email_validator, "email")
    use <- validation.validate_as(password, password_validator, "password")
    use <- validation.validate_as(
      confirm_password,
      password_match_validator,
      "confirm_password",
    )
    validation.validation_valid(Nil)
  })
}

// Example 6: Validating a complex data structure
pub type UserData {
  UserData(
    name: String,
    email: String,
    age: option.Option(Int),
    preferences: option.Option(String),
  )
}

pub fn validate_user_data(
  user: UserData,
) -> Result(UserData, dict.Dict(String, String)) {
  let age_string_validator = fn(age: Int) -> Result(Int, String) {
    case age >= 13 && age <= 120 {
      True -> Ok(age)
      False -> Error("must be between 13 and 120")
    }
  }

  validation.validation_pipeline(fn() {
    use <- validation.validate_as(user.name, name_validator, "name")
    use <- validation.validate_as(user.email, email_validator, "email")
    use <- validation.validate_optional_field(
      user.age,
      age_string_validator,
      "age",
    )
    use <- validation.validate_optional_field(
      user.preferences,
      validation.max_length(1000),
      "preferences",
    )
    validation.validation_valid(user)
  })
}

// Example 7: Usage examples

pub fn example_successful_validation() {
  let result =
    validate_user_signup(
      "John Doe",
      "john@example.com",
      "password123!",
      option.Some("25"),
    )
  // Result: Ok(Nil)
  result
}

pub fn example_validation_with_errors() {
  let result =
    validate_user_signup(
      "",
      // Empty name
      "invalid-email",
      // Invalid email
      "123",
      // Too short password
      option.Some(""),
      // Empty age
    )
  // Result: Error with multiple field errors
  result
}

pub fn example_account_creation() {
  let result =
    validate_account_creation(
      "johndoe",
      "john@example.com",
      "mypassword123!",
      "mypassword123!",
    )
  // Result: Ok(Nil)
  result
}

pub fn example_mismatched_passwords() {
  let result =
    validate_account_creation(
      "johndoe",
      "john@example.com",
      "mypassword123!",
      "differentpassword123!",
    )
  // Result: Error with password mismatch
  result
}
