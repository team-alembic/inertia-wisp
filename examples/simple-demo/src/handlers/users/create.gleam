//// User creation handler for the simple demo application.
////
//// This module handles POST requests to create new users, including
//// JSON decoding, validation, and error handling. It demonstrates
//// proper form processing with the Response Builder API.
////
//// Key insight: When validation fails, only errors need to be returned.
//// Inertia.js preserves form state on the frontend, eliminating the need
//// to echo form data back from the server.

import data/users
import gleam/dict
import gleam/list
import gleam/result
import inertia_wisp/inertia

import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user creation (POST)
///
/// This demonstrates the simplified Response Builder API pattern:
/// 1. Decode JSON data from request
/// 2. Validate the data
/// 3. Create user in database
/// 4. On success: redirect to users index
/// 5. On error: return only errors (frontend preserves form state)
pub fn handler(req: Request, db: Connection) -> Response {
  use request <- decode_request(req)
  let create_result = {
    use validated_request <- result.try(validate_request(db, request))
    create_user(db, validated_request)
  }

  case create_result {
    Ok(_user) -> {
      wisp.redirect("/users")
    }
    Error(errors_dict) -> {
      req
      |> inertia.response_builder("Users/Create")
      |> inertia.errors(errors_dict)
      |> inertia.response()
    }
  }
}

/// Require JSON and decode user request, handling errors with form response
fn decode_request(
  req: Request,
  cont: fn(users.CreateUserRequest) -> Response,
) -> Response {
  use json_data <- wisp.require_json(req)

  case users.decode_create_user_request(json_data) {
    Error(_) -> {
      // JSON decoding failed - return to form with errors only
      req
      |> inertia.response_builder("Users/Create")
      |> inertia.errors(dict.from_list([#("form", "Invalid form data")]))
      |> inertia.response()
    }
    Ok(request) -> cont(request)
  }
}

fn validate_request(
  db: Connection,
  request: users.CreateUserRequest,
) -> Result(users.CreateUserRequest, dict.Dict(String, String)) {
  users.validate_create_user(db, request)
  |> result.map_error(validation_errors_to_dict)
}

fn create_user(
  db: Connection,
  validated_request: users.CreateUserRequest,
) -> Result(users.User, dict.Dict(String, String)) {
  users.create_user(db, validated_request)
  |> result.map_error(fn(_) {
    dict.from_list([#("general", "Failed to create user")])
  })
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
