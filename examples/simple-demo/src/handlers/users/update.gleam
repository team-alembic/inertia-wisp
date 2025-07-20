//// User update handler for the simple demo application.
////
//// This module handles PUT/PATCH requests to update existing users.
//// Demonstrates Response Builder API with validation and error handling.

import data/users
import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/int
import gleam/list

import gleam/result
import inertia_wisp/inertia

import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user update (PUT/PATCH)
///
/// This demonstrates the Response Builder API pattern with:
/// 1. Parse user ID from route parameter
/// 2. Decode JSON data from request
/// 3. Validate the data and user existence
/// 4. Update user in database
/// 5. On success: redirect to user show page
/// 6. On error: return to edit form with errors
pub fn handler(req: Request, id: String, db: Connection) -> Response {
  use request <- decode_request(req, id)
  let update_result = {
    use validated_request <- result.try(validate_request(db, request))
    update_user(db, validated_request)
  }

  case update_result {
    Ok(_user) -> {
      wisp.redirect("/users/" <> id)
    }
    Error(errors_dict) -> {
      // Inertia.js preserves form state, just send errors
      req
      |> inertia.response_builder("Users/Edit")
      |> inertia.errors(errors_dict)
      |> inertia.response(200)
    }
  }
}

/// Parse user ID or return error dict
fn parse_user_id(id: String) -> Result(Int, dict.Dict(String, String)) {
  case int.parse(id) {
    Ok(user_id) -> Ok(user_id)
    Error(_) ->
      Error(
        dict.from_list([
          #(
            "message",
            "Invalid user ID: '"
              <> id
              <> "'. Please check the URL and try again.",
          ),
        ]),
      )
  }
}

/// Require JSON and decode user update request, showing errors in Users/Edit
fn decode_request(
  req: Request,
  id: String,
  cont: fn(users.UpdateUserRequest) -> Response,
) -> Response {
  case parse_user_id(id) {
    Error(errors_dict) -> {
      req
      |> inertia.response_builder("Users/Edit")
      |> inertia.errors(errors_dict)
      |> inertia.response(200)
    }
    Ok(user_id) -> {
      use json_data <- wisp.require_json(req)

      case decode_update_user_request(json_data, user_id) {
        Error(_) -> {
          req
          |> inertia.response_builder("Users/Edit")
          |> inertia.errors(
            dict.from_list([
              #("message", "Invalid JSON format in request body."),
            ]),
          )
          |> inertia.response(200)
        }
        Ok(request) -> cont(request)
      }
    }
  }
}

/// Decode update user request from JSON
fn decode_update_user_request(
  json_data: dynamic.Dynamic,
  user_id: Int,
) -> Result(users.UpdateUserRequest, List(decode.DecodeError)) {
  let decoder = {
    use name <- decode.field("name", decode.string)
    use email <- decode.field("email", decode.string)
    decode.success(users.UpdateUserRequest(
      id: user_id,
      name: name,
      email: email,
    ))
  }

  decode.run(json_data, decoder)
}

fn validate_request(
  db: Connection,
  request: users.UpdateUserRequest,
) -> Result(users.UpdateUserRequest, dict.Dict(String, String)) {
  case users.validate_update_user(db, request) {
    Ok(validated_request) -> Ok(validated_request)
    Error(errors) -> {
      // Check if UserNotFound is in the errors - treat as system error
      case list.contains(errors, users.UserNotFound) {
        True ->
          Error(
            dict.from_list([
              #("message", "User not found. The user may have been deleted."),
            ]),
          )
        False -> Error(validation_errors_to_dict(errors))
      }
    }
  }
}

fn update_user(
  db: Connection,
  validated_request: users.UpdateUserRequest,
) -> Result(users.User, dict.Dict(String, String)) {
  users.update_user(db, validated_request)
  |> result.map_error(fn(_) {
    dict.from_list([#("general", "Failed to update user")])
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
