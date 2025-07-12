//// User-specific utilities for user handlers using continuation-passing style.
////
//// This module provides reusable utility functions that encapsulate common
//// patterns in user request handling, such as ID parsing, user fetching,
//// and JSON decoding with proper error handling using continuations.

import data/users
import gleam/dynamic
import gleam/dynamic/decode
import gleam/int
import gleam/option
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Parse a string ID to integer with continuation-passing style.
/// On error, redirects to /users. On success, calls continuation with parsed ID.
pub fn parse_user_id(id: String, cont: fn(Int) -> Response) -> Response {
  case int.parse(id) {
    Error(_) -> wisp.redirect("/users")
    Ok(user_id) -> cont(user_id)
  }
}

/// Parse a string ID to integer with 404 error on failure.
/// Used for operations that should return 404 for invalid IDs.
pub fn parse_user_id_or_404(id: String, cont: fn(Int) -> Response) -> Response {
  case int.parse(id) {
    Error(_) -> wisp.not_found()
    Ok(user_id) -> cont(user_id)
  }
}

/// Fetch user by ID with continuation-passing style.
/// On error or not found, redirects to specified location. On success, calls continuation with user.
pub fn get_user_or_redirect(
  user_id: Int,
  db: Connection,
  redirect_to: String,
  cont: fn(users.User) -> Response,
) -> Response {
  case users.get_user_by_id(db, user_id) {
    Ok(option.Some(user)) -> cont(user)
    _ -> wisp.redirect(redirect_to)
  }
}

/// Decode JSON into CreateUserRequest with continuation-passing style.
/// On error, calls error handler. On success, calls continuation with request.
pub fn decode_create_user_request(
  json_data: dynamic.Dynamic,
  on_error: fn() -> Response,
  cont: fn(users.CreateUserRequest) -> Response,
) -> Response {
  let decoder = {
    use name <- decode.field("name", decode.string)
    use email <- decode.field("email", decode.string)
    decode.success(users.CreateUserRequest(name, email))
  }

  case decode.run(json_data, decoder) {
    Error(_) -> on_error()
    Ok(request) -> cont(request)
  }
}

/// Decode JSON into UpdateUserRequest with continuation-passing style.
/// On error, calls error handler. On success, calls continuation with request.
pub fn decode_update_user_request(
  json_data: dynamic.Dynamic,
  user_id: Int,
  on_error: fn() -> Response,
  cont: fn(users.UpdateUserRequest) -> Response,
) -> Response {
  let decoder = {
    use name <- decode.field("name", decode.string)
    use email <- decode.field("email", decode.string)
    decode.success(users.UpdateUserRequest(user_id, name, email))
  }

  case decode.run(json_data, decoder) {
    Error(_) -> on_error()
    Ok(request) -> cont(request)
  }
}

/// Validate CreateUserRequest with continuation-passing style.
/// On validation error, calls error handler. On success, calls continuation.
pub fn validate_create_user_request(
  req: Request,
  request: users.CreateUserRequest,
  db: Connection,
  on_validation_error: fn(
    Request,
    users.CreateUserRequest,
    List(users.UserValidationError),
  ) ->
    Response,
  cont: fn(users.CreateUserRequest) -> Response,
) -> Response {
  case users.validate_create_user(db, request) {
    Error(validation_errors) ->
      on_validation_error(req, request, validation_errors)
    Ok(validated_request) -> cont(validated_request)
  }
}

/// Validate UpdateUserRequest with continuation-passing style.
/// On validation error, calls error handler. On success, calls continuation.
pub fn validate_update_user_request(
  req: Request,
  request: users.UpdateUserRequest,
  db: Connection,
  on_validation_error: fn(
    Request,
    users.UpdateUserRequest,
    List(users.UserValidationError),
  ) ->
    Response,
  cont: fn(users.UpdateUserRequest) -> Response,
) -> Response {
  case users.validate_update_user(db, request) {
    Error(validation_errors) ->
      on_validation_error(req, request, validation_errors)
    Ok(validated_request) -> cont(validated_request)
  }
}

/// Create user in database with continuation-passing style.
/// On database error, calls error handler. On success, calls continuation.
pub fn create_user_in_database(
  validated_request: users.CreateUserRequest,
  db: Connection,
  on_db_error: fn(users.CreateUserRequest) -> Response,
  on_success: fn() -> Response,
) -> Response {
  case users.create_user(db, validated_request) {
    Error(_) -> on_db_error(validated_request)
    Ok(_) -> on_success()
  }
}

/// Update user in database with continuation-passing style.
/// On database error, calls error handler. On success, calls continuation.
pub fn update_user_in_database(
  validated_request: users.UpdateUserRequest,
  db: Connection,
  on_db_error: fn() -> Response,
  on_success: fn() -> Response,
) -> Response {
  case users.update_user(db, validated_request) {
    Error(_) -> on_db_error()
    Ok(_) -> on_success()
  }
}
