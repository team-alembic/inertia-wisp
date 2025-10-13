//// Tests for forms handler
////
//// Integration tests for contact form using inertia_wisp/testing

import gleam/dict
import gleam/dynamic/decode
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import gleeunit
import handlers/forms
import inertia_wisp/testing
import wisp.{type Response}

pub fn main() {
  gleeunit.main()
}

// Form display tests

pub fn show_contact_form_returns_correct_component_test() {
  let req = testing.inertia_request_to("/forms/contact")
  let response = forms.show_contact_form(req)

  let assert Ok("ContactForm") = testing.component(response)
}

// Valid form submission tests

pub fn valid_form_submission_succeeds_test() {
  let form_data =
    json.object([
      #("name", json.string("John Doe")),
      #("email", json.string("john@example.com")),
      #("message", json.string("Hello, this is a test message!")),
    ])

  let req = testing.inertia_post("/forms/contact", form_data)
  let response = forms.submit_contact_form(req)

  // Should redirect on success (status 303)
  assert response.status == 303
}

// Invalid form submission tests - name validation

pub fn empty_name_returns_error_test() {
  let form_data =
    json.object([
      #("name", json.string("")),
      #("email", json.string("john@example.com")),
      #("message", json.string("Valid message here")),
    ])

  let req = testing.inertia_post("/forms/contact", form_data)
  let redirect_response = forms.submit_contact_form(req)

  // Step 1: Should redirect with errors in cookie
  assert redirect_response.status == 303
  let cookie_value = extract_cookie_value(redirect_response)

  // Step 2: Make second request with cookie to see errors
  let form_request =
    testing.inertia_request_to("/forms/contact")
    |> request.set_header("cookie", "inertia_errors=" <> cookie_value)

  let form_response = forms.show_contact_form(form_request)

  let errors_decoder = decode.dict(decode.string, decode.string)
  let assert Ok(errors) = testing.prop(form_response, "errors", errors_decoder)
  let assert Ok(name_error) = dict.get(errors, "name")
  assert name_error == "Name is required"
}

pub fn name_too_short_returns_error_test() {
  let form_data =
    json.object([
      #("name", json.string("J")),
      #("email", json.string("john@example.com")),
      #("message", json.string("Valid message here")),
    ])

  let req = testing.inertia_post("/forms/contact", form_data)
  let redirect_response = forms.submit_contact_form(req)

  assert redirect_response.status == 303
  let cookie_value = extract_cookie_value(redirect_response)

  let form_request =
    testing.inertia_request_to("/forms/contact")
    |> request.set_header("cookie", "inertia_errors=" <> cookie_value)

  let form_response = forms.show_contact_form(form_request)

  let errors_decoder = decode.dict(decode.string, decode.string)
  let assert Ok(errors) = testing.prop(form_response, "errors", errors_decoder)
  let assert Ok(name_error) = dict.get(errors, "name")
  assert name_error == "Name must be at least 2 characters"
}

// Helper function to extract cookie value from redirect response
fn extract_cookie_value(redirect_response: Response) -> String {
  let assert Ok(cookie_header) =
    response.get_header(redirect_response, "set-cookie")

  string.replace(cookie_header, "inertia_errors=", "")
  |> string.split(";")
  |> list.first()
  |> result.unwrap("")
}
