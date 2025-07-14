//// User deletion handler for the simple demo application.
////
//// This module handles DELETE/POST requests to remove users from the system.
//// It demonstrates proper ID validation, user existence checking, and database
//// deletion with appropriate error handling using the Error component.

import data/users
import gleam/dict
import gleam/int
import gleam/result
import inertia_wisp/inertia
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user deletion (POST)
///
/// This demonstrates proper error handling for delete operations:
/// 1. Parse and validate user ID
/// 2. Check if user exists before deletion
/// 3. Handle database errors gracefully
/// 4. Show Error component for failures, redirect for success
pub fn handler(req: Request, id: String, db: Connection) -> Response {
  let result = {
    use user_id <- result.try(parse_user_id(id))
    use _ <- result.try(delete_user(db, user_id))
    Ok(Nil)
  }

  case result {
    Ok(_) -> wisp.redirect("/users")
    Error(errors_dict) -> {
      req
      |> inertia.response_builder("Error")
      |> inertia.errors(errors_dict)
      |> inertia.response()
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

/// Delete user from database or return error dict
fn delete_user(
  db: Connection,
  user_id: Int,
) -> Result(Nil, dict.Dict(String, String)) {
  case users.delete_user(db, user_id) {
    Ok(_) -> Ok(Nil)
    Error(_) ->
      Error(
        dict.from_list([
          #("message", "Failed to delete user. Please try again later."),
        ]),
      )
  }
}
