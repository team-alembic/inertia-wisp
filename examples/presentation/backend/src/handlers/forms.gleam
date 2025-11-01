//// Forms handler for demonstration
////
//// Handles contact form display and submission with validation
//// Updated to use v2 API with generic props

import gleam/dict.{type Dict}
import gleam/result
import gleam/string
import inertia_wisp/inertia
import props/contact_form_props.{ContactFormProps}
import schemas/contact_form.{type ContactFormData, ContactFormData}
import shared/forms.{validate_name}
import wisp.{type Request, type Response}

/// Display the contact form page
pub fn show_contact_form(req: Request) -> Response {
  let props = ContactFormProps(name: "", email: "", message: "")

  req
  |> inertia.response_builder("ContactForm")
  |> inertia.props(props, contact_form_props.encode)
  |> inertia.response(200)
}

/// Handle contact form submission with validation
pub fn submit_contact_form(req: Request) -> Response {
  use json_data <- wisp.require_json(req)

  // Decode form data from JSON
  let ContactFormData(name:, email:, message:) =
    json_data
    |> contact_form.decode()
    |> result.unwrap(ContactFormData("", "", ""))

  // Validate
  case validate_contact_form(name, email, message) {
    Ok(_) -> {
      // Success - redirect to next slide
      wisp.redirect("/slides/16")
    }
    Error(errors) -> {
      req
      |> inertia.response_builder("ContactForm")
      |> inertia.errors(errors)
      |> inertia.redirect("/forms/contact")
    }
  }
}

/// Validate contact form data
/// Returns Ok(data) if valid, Error(errors) if invalid
pub fn validate_contact_form(
  name: String,
  email: String,
  message: String,
) -> Result(ContactFormData, Dict(String, String)) {
  let errors = dict.new()

  // Validate name using shared validation function
  let errors = case validate_name(name) {
    Ok(_) -> errors
    Error(message) -> dict.insert(errors, "name", message)
  }

  // Validate email
  let errors = case string.trim(email) {
    "" -> dict.insert(errors, "email", "Email is required")
    e ->
      case is_valid_email(e) {
        True -> errors
        False ->
          dict.insert(errors, "email", "Email must be a valid email address")
      }
  }

  // Validate message
  let errors = case string.trim(message) {
    "" -> dict.insert(errors, "message", "Message is required")
    m -> {
      case string.length(m) < 10 {
        True ->
          dict.insert(
            errors,
            "message",
            "Message must be at least 10 characters",
          )
        False -> errors
      }
    }
  }

  // Return result
  case dict.size(errors) {
    0 -> Ok(ContactFormData(name, email, message))
    _ -> Error(errors)
  }
}

/// Check if email is valid (simple check for @ and .)
fn is_valid_email(email: String) -> Bool {
  string.contains(email, "@") && string.contains(email, ".")
}
