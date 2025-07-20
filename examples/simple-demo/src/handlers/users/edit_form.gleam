//// User edit form handler for the simple demo application.
////
//// This module handles GET requests to show the edit form for users.
//// Demonstrates Response Builder API with user data fetching and form population.

import data/users
import gleam/dict
import gleam/int
import gleam/option
import gleam/result
import inertia_wisp/inertia
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user edit form (GET)
///
/// This demonstrates the Response Builder API pattern with error handling:
/// 1. Parse user ID from route parameter
/// 2. Fetch user from database
/// 3. Return edit form with user data or show error page
pub fn handler(req: Request, id: String, db: Connection) -> Response {
  let result = {
    use user_id <- result.try(parse_user_id(id))
    use user <- result.try(get_user(user_id, db))
    Ok(user)
  }

  case result {
    Ok(user) -> {
      let props = [
        user_props.form_data(user.name, user.email),
        user_props.user_data(user),
      ]

      req
      |> inertia.response_builder("Users/Edit")
      |> inertia.props(props, user_props.user_prop_to_json)
      |> inertia.response(200)
    }
    Error(errors) -> {
      req
      |> inertia.response_builder("Error")
      |> inertia.errors(errors)
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

/// Get user from database or return error dict if not found
fn get_user(
  user_id: Int,
  db: Connection,
) -> Result(users.User, dict.Dict(String, String)) {
  case users.get_user_by_id(db, user_id) {
    Ok(option.Some(user)) -> Ok(user)
    Ok(option.None) ->
      Error(
        dict.from_list([
          #(
            "message",
            "User not found with ID "
              <> int.to_string(user_id)
              <> ". The user may have been deleted or the ID is incorrect.",
          ),
        ]),
      )
    Error(_) ->
      Error(
        dict.from_list([
          #(
            "message",
            "Database error occurred while fetching user. Please try again later.",
          ),
        ]),
      )
  }
}
