//// User update handler for the simple demo application.
////
//// This module handles PUT/POST requests to update existing users, including
//// JSON decoding, validation, and error handling. It demonstrates proper
//// form processing with validation errors in Inertia.js.

import data/users
import gleam/dict
import gleam/list
import handlers/users/utils
import inertia_wisp/inertia
import inertia_wisp/internal/types
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user update (POST)
pub fn handler(req: Request, id: String, db: Connection) -> Response {
  use json_data <- wisp.require_json(req)
  use user_id <- utils.parse_user_id_or_404(id)
  use request <- utils.decode_update_user_request(json_data, user_id, fn() {
    wisp.redirect("/users/" <> id <> "/edit")
  })
  use validated_request <- utils.validate_update_user_request(
    req,
    request,
    db,
    render_edit_form_with_validation_errors,
  )
  utils.update_user_in_database(
    validated_request,
    db,
    fn() { wisp.redirect("/users/" <> id <> "/edit") },
    fn() { wisp.redirect("/users/" <> id) },
  )
}

/// Helper to render edit form with validation errors
fn render_edit_form_with_validation_errors(
  req: Request,
  request: users.UpdateUserRequest,
  validation_errors: List(users.UserValidationError),
) -> Response {
  let props = [
    types.DefaultProp(
      "form_data",
      user_props.UserFormData(request.name, request.email),
    ),
  ]
  let page =
    inertia.eval(req, "Users/Edit", props, user_props.encode_user_prop)
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
