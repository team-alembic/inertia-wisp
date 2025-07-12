//// User creation handler for the simple demo application.
////
//// This module handles POST requests to create new users, including
//// JSON decoding, validation, and error handling. It demonstrates
//// proper form processing with Inertia.js.

import data/users
import gleam/dict
import gleam/list
import handlers/users/utils
import inertia_wisp/inertia
import inertia_wisp/internal/types
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user creation (POST)
pub fn handler(req: Request, db: Connection) -> Response {
  use json_data <- wisp.require_json(req)
  use request <- utils.decode_create_user_request(json_data, fn() {
    render_create_form_with_empty_data(req)
  })
  use validated_request <- utils.validate_create_user_request(
    req,
    request,
    db,
    render_create_form_with_validation_errors,
  )
  utils.create_user_in_database(
    validated_request,
    db,
    fn(failed_request) {
      render_create_form_with_data(
        req,
        failed_request.name,
        failed_request.email,
      )
    },
    fn() { wisp.redirect("/users") },
  )
}

/// Helper to render the create form with empty data
fn render_create_form_with_empty_data(req: Request) -> Response {
  let props = [types.DefaultProp("form_data", user_props.UserFormData("", ""))]
  let page =
    inertia.eval(req, "Users/Create", props, user_props.encode_user_prop)
  inertia.render(req, page)
}

/// Helper to render form with existing data (no errors shown)
fn render_create_form_with_data(
  req: Request,
  name: String,
  email: String,
) -> Response {
  let props = [
    types.DefaultProp("form_data", user_props.UserFormData(name, email)),
  ]
  let page =
    inertia.eval(req, "Users/Create", props, user_props.encode_user_prop)
  inertia.render(req, page)
}

/// Helper to render form with validation errors
fn render_create_form_with_validation_errors(
  req: Request,
  request: users.CreateUserRequest,
  validation_errors: List(users.UserValidationError),
) -> Response {
  let props = [
    types.DefaultProp(
      "form_data",
      user_props.UserFormData(request.name, request.email),
    ),
  ]
  let page =
    inertia.eval(req, "Users/Create", props, user_props.encode_user_prop)
    |> inertia.errors(validation_errors_to_dict(validation_errors))
  inertia.render(req, page)
}

/// Convert validation errors to error dict for Inertia
fn validation_errors_to_dict(
  errors: List(users.UserValidationError),
) -> dict.Dict(String, String) {
  errors
  |> list.map(fn(error) {
    case error {
      users.NameEmpty -> #("name", "Name cannot be empty")
      users.NameTooShort -> #("name", "Name is too short")
      users.NameTooLong -> #("name", "Name is too long")
      users.EmailInvalid -> #("email", "Email format is invalid")
      users.EmailAlreadyExists -> #("email", "Email already exists")
      users.UserNotFound -> #("id", "User not found")
    }
  })
  |> dict.from_list
}
