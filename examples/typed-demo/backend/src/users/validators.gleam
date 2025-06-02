import gleam/list
import gleam/option
import gleam/string
import shared/validation

// ===== USER-SPECIFIC VALIDATION =====

pub fn validate_user_name(name: String) -> Result(Nil, #(String, String)) {
  validation.validate_name(name)
}

pub fn validate_user_email(email: String) -> Result(Nil, #(String, String)) {
  validation.validate_email(email)
}

pub fn validate_bio_optional(bio: option.Option(String)) -> Result(Nil, #(String, String)) {
  case bio {
    option.Some(bio_text) -> 
      case string.length(bio_text) <= 500 {
        True -> Ok(Nil)
        False -> Error(#("bio", "Bio must be 500 characters or less"))
      }
    option.None -> Ok(Nil)
  }
}

pub fn validate_bio_required(bio: String) -> Result(Nil, #(String, String)) {
  case string.length(bio) >= 1 && string.length(bio) <= 500 {
    True -> Ok(Nil)
    False -> Error(#("bio", "Bio is required and must be 500 characters or less"))
  }
}

pub fn validate_interests(interests: List(String)) -> Result(Nil, #(String, String)) {
  case list.length(interests) > 0 {
    True -> Ok(Nil)
    False -> Error(#("interests", "At least one interest is required"))
  }
}

// Validate complete create user request
pub fn validate_create_user_request(name: String, email: String, bio: option.Option(String)) -> validation.ValidationErrors {
  validation.collect_validation_errors([
    validate_user_name(name),
    validate_user_email(email),
    validate_bio_optional(bio),
  ])
}

// Validate complete update profile request
pub fn validate_update_profile_request(name: String, bio: String, interests: List(String)) -> validation.ValidationErrors {
  validation.collect_validation_errors([
    validate_user_name(name),
    validate_bio_required(bio),
    validate_interests(interests),
  ])
}