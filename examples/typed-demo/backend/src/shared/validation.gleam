import gleam/dict
import gleam/list
import gleam/string

// ===== VALIDATION UTILITIES =====

pub type ValidationErrors =
  dict.Dict(String, String)

// Helper to collect validation errors from a list of validation results
pub fn collect_validation_errors(validations: List(Result(Nil, #(String, String)))) -> ValidationErrors {
  validations
  |> list.filter_map(fn(result) {
    case result {
      Ok(_) -> Error(Nil)
      Error(pair) -> Ok(pair)
    }
  })
  |> dict.from_list
}

// ===== COMMON VALIDATION FUNCTIONS =====

pub fn validate_name(name: String) -> Result(Nil, #(String, String)) {
  case string.length(name) >= 2 {
    True -> Ok(Nil)
    False -> Error(#("name", "Name must be at least 2 characters long"))
  }
}

pub fn validate_email(email: String) -> Result(Nil, #(String, String)) {
  case string.contains(email, "@") && string.length(email) > 3 {
    True -> Ok(Nil)
    False -> Error(#("email", "Please enter a valid email address"))
  }
}

pub fn validate_password(password: String) -> Result(Nil, #(String, String)) {
  case string.length(password) >= 6 {
    True -> Ok(Nil)
    False -> Error(#("password", "Password must be at least 6 characters long"))
  }
}

pub fn validate_required_text(field_name: String, text: String, min_length: Int, max_length: Int) -> Result(Nil, #(String, String)) {
  let length = string.length(text)
  case length >= min_length && length <= max_length {
    True -> Ok(Nil)
    False -> {
      let message = case min_length == max_length {
        True -> field_name <> " must be exactly " <> string.inspect(min_length) <> " characters"
        False -> field_name <> " must be between " <> string.inspect(min_length) <> " and " <> string.inspect(max_length) <> " characters"
      }
      Error(#(string.lowercase(field_name), message))
    }
  }
}

pub fn validate_non_empty_list(field_name: String, items: List(a)) -> Result(Nil, #(String, String)) {
  case list.length(items) > 0 {
    True -> Ok(Nil)
    False -> Error(#(string.lowercase(field_name), field_name <> " cannot be empty"))
  }
}