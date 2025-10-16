//// Shared form validation logic
////
//// This module contains validation functions that can be used
//// by both backend (Gleam) and frontend (compiled to JavaScript).

import gleam/list
import gleam/string

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
