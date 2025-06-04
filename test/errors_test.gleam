import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option
import gleeunit
import inertia_wisp/inertia
import inertia_wisp/internal/types
import inertia_wisp/testing
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Test prop type for error tests
pub type ErrorProp {
  Title(title: String)
  Message(message: String)
}

fn encode_error_prop(prop: ErrorProp) -> json.Json {
  case prop {
    Title(title) -> json.string(title)
    Message(message) -> json.string(message)
  }
}

// Helper to create context
fn create_test_context() -> types.InertiaContext(ErrorProp) {
  let config = inertia.default_config()
  let req = testing.inertia_request()
  
  types.InertiaContext(
    config: config,
    request: req,
    props: dict.new(),
    prop_encoder: encode_error_prop,
    errors: dict.new(),
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: option.None,
  )
}

// Test 1: errors() should set validation errors correctly
pub fn errors_function_test() {
  let validation_errors = dict.from_list([
    #("name", "Name is required"),
    #("email", "Email format is invalid"),
    #("password", "Password must be at least 8 characters"),
  ])
  
  let ctx = create_test_context()
    |> inertia.errors(validation_errors)
  
  assert dict.get(ctx.errors, "name") == Ok("Name is required")
  assert dict.get(ctx.errors, "email") == Ok("Email format is invalid")
  assert dict.get(ctx.errors, "password") == Ok("Password must be at least 8 characters")
  assert dict.size(ctx.errors) == 3
}

// Test 2: errors() should overwrite existing errors
pub fn errors_overwrite_test() {
  let initial_errors = dict.from_list([
    #("old_field", "Old error"),
    #("another_field", "Another error"),
  ])
  
  let new_errors = dict.from_list([
    #("name", "Name is required"),
    #("email", "Email is invalid"),
  ])
  
  let ctx = types.InertiaContext(
    config: inertia.default_config(),
    request: testing.inertia_request(),
    props: dict.new(),
    prop_encoder: encode_error_prop,
    errors: initial_errors,
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: option.None,
  )
    |> inertia.errors(new_errors)
  
  // Should have new errors, not old ones
  assert dict.get(ctx.errors, "name") == Ok("Name is required")
  assert dict.get(ctx.errors, "email") == Ok("Email is invalid")
  assert dict.size(ctx.errors) == 2
  
  // Old errors should be gone
  case dict.get(ctx.errors, "old_field") {
    Error(_) -> Nil  // Expected
    Ok(_) -> panic as "Old errors should be overwritten"
  }
}

// Test 3: errors() should handle empty error dict
pub fn errors_empty_dict_test() {
  let empty_errors = dict.new()
  
  let ctx = create_test_context()
    |> inertia.errors(empty_errors)
  
  assert dict.is_empty(ctx.errors)
  assert dict.size(ctx.errors) == 0
}

// Test 4: errors should be included in rendered response
pub fn errors_in_response_test() {
  let validation_errors = dict.from_list([
    #("username", "Username already exists"),
    #("password", "Password too weak"),
  ])
  
  let ctx = create_test_context()
    |> inertia.prop("title", Title("Registration Form"))
    |> inertia.errors(validation_errors)
  
  let response = inertia.render(ctx, "RegistrationForm")
  
  assert testing.component(response) == Ok("RegistrationForm")
  assert testing.prop(response, "title", decode.string) == Ok("Registration Form")
  
  // Check that errors are included
  assert testing.prop(response, "errors", decode.at(["username"], decode.string)) == Ok("Username already exists")
  assert testing.prop(response, "errors", decode.at(["password"], decode.string)) == Ok("Password too weak")
}

// Test 5: render should work without errors (no errors field in response)
pub fn render_without_errors_test() {
  let ctx = create_test_context()
    |> inertia.prop("title", Title("Clean Form"))
  
  let response = inertia.render(ctx, "CleanForm")
  
  assert testing.component(response) == Ok("CleanForm")
  assert testing.prop(response, "title", decode.string) == Ok("Clean Form")
  
  // Should not have errors field when no errors
  case testing.prop(response, "errors", decode.dynamic) {
    Error(_) -> Nil  // Expected - no errors field
    Ok(_) -> panic as "Should not have errors field when no errors set"
  }
}

// Test 6: errors should persist through prop additions
pub fn errors_persist_through_props_test() {
  let validation_errors = dict.from_list([
    #("field1", "Error 1"),
    #("field2", "Error 2"),
  ])
  
  let ctx = create_test_context()
    |> inertia.errors(validation_errors)
    |> inertia.prop("title", Title("Form with Errors"))
    |> inertia.prop("message", Message("Please fix the errors below"))
  
  // Errors should still be there
  assert dict.get(ctx.errors, "field1") == Ok("Error 1")
  assert dict.get(ctx.errors, "field2") == Ok("Error 2")
  assert dict.size(ctx.errors) == 2
  
  // Props should be there too
  assert dict.size(ctx.props) == 2
}

// Test 7: multiple errors() calls should overwrite, not accumulate
pub fn multiple_errors_calls_test() {
  let first_errors = dict.from_list([
    #("name", "First error"),
    #("email", "First email error"),
  ])
  
  let second_errors = dict.from_list([
    #("name", "Second error"),
    #("password", "Password error"),
  ])
  
  let ctx = create_test_context()
    |> inertia.errors(first_errors)
    |> inertia.errors(second_errors)
  
  // Should have second errors
  assert dict.get(ctx.errors, "name") == Ok("Second error")
  assert dict.get(ctx.errors, "password") == Ok("Password error")
  assert dict.size(ctx.errors) == 2
  
  // Should not have first email error
  case dict.get(ctx.errors, "email") {
    Error(_) -> Nil  // Expected
    Ok(_) -> panic as "Should not have first email error"
  }
}

// Test 8: errors should work with complex validation scenarios
pub fn errors_complex_validation_test() {
  let complex_errors = dict.from_list([
    #("user.name", "User name is required"),
    #("user.email", "User email format is invalid"),
    #("billing.address", "Billing address is required"),
    #("billing.zip", "Invalid ZIP code format"),
    #("terms", "You must accept terms and conditions"),
  ])
  
  let ctx = create_test_context()
    |> inertia.prop("title", Title("Complex Form"))
    |> inertia.errors(complex_errors)
  
  let response = inertia.render(ctx, "ComplexForm")
  
  assert testing.component(response) == Ok("ComplexForm")
  
  // Check nested field errors
  assert testing.prop(response, "errors", decode.at(["user.name"], decode.string)) == Ok("User name is required")
  assert testing.prop(response, "errors", decode.at(["user.email"], decode.string)) == Ok("User email format is invalid")
  assert testing.prop(response, "errors", decode.at(["billing.address"], decode.string)) == Ok("Billing address is required")
  assert testing.prop(response, "errors", decode.at(["billing.zip"], decode.string)) == Ok("Invalid ZIP code format")
  assert testing.prop(response, "errors", decode.at(["terms"], decode.string)) == Ok("You must accept terms and conditions")
}

// Test 9: errors should work with partial reload
pub fn errors_with_partial_reload_test() {
  let validation_errors = dict.from_list([
    #("name", "Name validation failed"),
    #("email", "Email validation failed"),
  ])
  
  let req = testing.inertia_request()
    |> testing.partial_data(["title"])
    |> testing.partial_component("PartialForm")
  
  let ctx = types.InertiaContext(
    config: inertia.default_config(),
    request: req,
    props: dict.new(),
    prop_encoder: encode_error_prop,
    errors: dict.new(),
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: option.None,
  )
    |> inertia.prop("title", Title("Partial Form"))
    |> inertia.prop("message", Message("Not requested"))
    |> inertia.errors(validation_errors)
  
  let response = inertia.render(ctx, "PartialForm")
  
  // Should include requested prop
  assert testing.prop(response, "title", decode.string) == Ok("Partial Form")
  
  // Should NOT include non-requested prop
  case testing.prop(response, "message", decode.string) {
    Error(_) -> Nil  // Expected
    Ok(_) -> panic as "Should not include non-requested prop in partial reload"
  }
  
  // Should ALWAYS include errors (even in partial reload)
  assert testing.prop(response, "errors", decode.at(["name"], decode.string)) == Ok("Name validation failed")
  assert testing.prop(response, "errors", decode.at(["email"], decode.string)) == Ok("Email validation failed")
}

// Test 10: errors should handle special characters and unicode
pub fn errors_special_characters_test() {
  let special_errors = dict.from_list([
    #("field-with-dash", "Error with dash"),
    #("field_with_underscore", "Error with underscore"),
    #("field.with.dots", "Error with dots"),
    #("unicode_field", "Error with émojis 🚫 and unicode ñ"),
    #("quotes\"field", "Error with \"quotes\" inside"),
  ])
  
  let ctx = create_test_context()
    |> inertia.errors(special_errors)
  
  let response = inertia.render(ctx, "SpecialForm")
  
  assert testing.prop(response, "errors", decode.at(["field-with-dash"], decode.string)) == Ok("Error with dash")
  assert testing.prop(response, "errors", decode.at(["field_with_underscore"], decode.string)) == Ok("Error with underscore")
  assert testing.prop(response, "errors", decode.at(["field.with.dots"], decode.string)) == Ok("Error with dots")
  assert testing.prop(response, "errors", decode.at(["unicode_field"], decode.string)) == Ok("Error with émojis 🚫 and unicode ñ")
  assert testing.prop(response, "errors", decode.at(["quotes\"field"], decode.string)) == Ok("Error with \"quotes\" inside")
}

// Test 11: errors should work with always and optional props
pub fn errors_with_different_prop_types_test() {
  let validation_errors = dict.from_list([
    #("general", "General validation error"),
  ])
  
  let ctx = create_test_context()
    |> inertia.prop("title", Title("Mixed Props Form"))
    |> inertia.always_prop("message", Message("Always visible"))
    |> inertia.optional_prop("debug", fn() { Message("Debug info") })
    |> inertia.errors(validation_errors)
  
  let response = inertia.render(ctx, "MixedPropsForm")
  
  // Should have all props
  assert testing.prop(response, "title", decode.string) == Ok("Mixed Props Form")
  assert testing.prop(response, "message", decode.string) == Ok("Always visible")
  
  // Should not have optional prop
  case testing.prop(response, "debug", decode.string) {
    Error(_) -> Nil  // Expected
    Ok(_) -> panic as "Should not have optional prop in regular render"
  }
  
  // Should have errors
  assert testing.prop(response, "errors", decode.at(["general"], decode.string)) == Ok("General validation error")
}

// Test 12: errors should work with non-Inertia requests (HTML responses)
pub fn errors_with_html_response_test() {
  let validation_errors = dict.from_list([
    #("form_field", "HTML form error"),
  ])
  
  let req = wisp_testing.get("/", [])  // Non-Inertia request
  let ctx = types.InertiaContext(
    config: inertia.default_config(),
    request: req,
    props: dict.new(),
    prop_encoder: encode_error_prop,
    errors: dict.new(),
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: option.None,
  )
    |> inertia.prop("title", Title("HTML Form"))
    |> inertia.errors(validation_errors)
  
  let response = inertia.render(ctx, "HTMLForm")
  
  // Should be HTML response but still have component and props accessible
  assert testing.component(response) == Ok("HTMLForm")
  assert testing.prop(response, "title", decode.string) == Ok("HTML Form")
  assert testing.prop(response, "errors", decode.at(["form_field"], decode.string)) == Ok("HTML form error")
}