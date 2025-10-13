//// Shared form types
////
//// This module defines form data types that are shared between
//// backend (Gleam) and frontend (TypeScript via JavaScript compilation).

import gleam/json
import gleam/list
import gleam/string

/// Contact form submission data
pub type ContactFormData {
  ContactFormData(name: String, email: String, message: String)
}

/// Encode contact form data to JSON
pub fn contact_form_data_to_json(data: ContactFormData) -> json.Json {
  let ContactFormData(name:, email:, message:) = data
  json.object([
    #("name", json.string(name)),
    #("email", json.string(email)),
    #("message", json.string(message)),
  ])
}

/// Validate a name field
/// Returns Ok(trimmed_name) if valid, Error(message) if invalid
pub fn validate_name(name: String) -> Result(String, String) {
  case string.trim(name) {
    "" -> Error("Name is required")
    trimmed -> {
      case string.length(trimmed) < 2 {
        True -> Error("Name must be at least 2 characters")
        False -> {
          // Check if all characters are valid (letters, spaces, hyphens, apostrophes)
          let valid_chars =
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -'"
          case
            string.to_graphemes(trimmed)
            |> list.all(fn(char) { string.contains(valid_chars, char) })
          {
            True -> Ok(trimmed)
            False ->
              Error(
                "Name can only contain letters, spaces, hyphens, and apostrophes",
              )
          }
        }
      }
    }
  }
}
