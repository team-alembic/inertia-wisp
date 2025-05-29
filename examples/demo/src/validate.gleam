import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option}
import gleam/string

/// A validator function that takes a value and returns either success or an error message
pub type Validator(a) =
  fn(a) -> Result(a, String)

/// A validation result type that accumulates errors
pub type ValidationResult {
  Valid
  Invalid(Dict(String, String))
}

/// Simple validate function that works with use syntax
/// Usage: use <- validate_field("field_name", value, validator)
pub fn field(
  field_name: String,
  value: a,
  validator: Validator(a),
  continue: fn() -> ValidationResult,
) -> ValidationResult {
  case validator(value) {
    Ok(_) -> continue()
    Error(message) -> {
      case continue() {
        Valid -> Invalid(dict.from_list([#(field_name, message)]))
        Invalid(existing_errors) ->
          Invalid(dict.insert(existing_errors, field_name, message))
      }
    }
  }
}

/// Validate an optional value using use syntax
/// Usage: use <- validate_optional_field("field_name", maybe_value, validator)
pub fn optional_field(
  field_name: String,
  value: Option(a),
  validator: Validator(a),
  continue: fn() -> ValidationResult,
) -> ValidationResult {
  case value {
    option.None -> continue()
    option.Some(val) -> {
      field(field_name, val, validator, continue)
    }
  }
}

/// Create a valid result
pub fn valid() -> ValidationResult {
  Valid
}

/// Accumulate errors from multiple validation results
pub fn accumulate_errors(results: List(ValidationResult)) -> ValidationResult {
  let all_errors =
    list.fold(results, dict.new(), fn(errors, result) {
      case result {
        Valid -> errors
        Invalid(new_errors) -> dict.merge(errors, new_errors)
      }
    })

  case dict.is_empty(all_errors) {
    True -> Valid
    _ -> Invalid(all_errors)
  }
}

/// Common validators
/// Validate that a string is not empty
pub fn non_empty_string(value: String) -> Result(String, String) {
  let trimmed = string.trim(value)
  case trimmed {
    "" -> Error("is required")
    _ -> Ok(trimmed)
  }
}

/// Validate minimum length for a string
pub fn min_length(min: Int) -> Validator(String) {
  fn(value: String) -> Result(String, String) {
    case string.length(value) >= min {
      True -> Ok(value)
      False ->
        Error("must be at least " <> string.inspect(min) <> " characters")
    }
  }
}

/// Validate maximum length for a string
pub fn max_length(max: Int) -> Validator(String) {
  fn(value: String) -> Result(String, String) {
    case string.length(value) <= max {
      True -> Ok(value)
      False -> Error("must be at most " <> string.inspect(max) <> " characters")
    }
  }
}

/// Validate that a string contains a substring
pub fn contains(substring: String) -> Validator(String) {
  fn(value: String) -> Result(String, String) {
    case string.contains(value, substring) {
      True -> Ok(value)
      False -> Error("must contain '" <> substring <> "'")
    }
  }
}

/// Combine multiple validators into a single validator
pub fn combine(validators: List(Validator(a))) -> Validator(a) {
  fn(value: a) -> Result(a, String) {
    validators
    |> list.try_fold(value, fn(acc, validator) { validator(acc) })
  }
}
