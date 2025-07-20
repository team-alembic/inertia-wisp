//// User show handler for the simple demo application.
////
//// This module handles GET requests to show individual users.
//// It demonstrates the Response Builder API with user data fetching.

import data/users
import gleam/dict
import gleam/int
import gleam/option
import inertia_wisp/inertia
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user show (GET)
///
/// This demonstrates the Response Builder API pattern with error handling:
/// 1. Parse user ID from route parameter
/// 2. Fetch user from database
/// 3. Return user data or show error page with helpful message
pub fn handler(req: Request, id: String, db: Connection) -> Response {
  use user_id <- parse_user_id_or_error(req, id)
  use user <- get_user_or_error(req, user_id, db)

  let props = [user_props.user_data(user)]

  req
  |> inertia.response_builder("Users/Show")
  |> inertia.props(props, user_props.user_prop_to_json)
  |> inertia.response(200)
}

/// Parse user ID or show error page
fn parse_user_id_or_error(
  req: Request,
  id: String,
  cont: fn(Int) -> Response,
) -> Response {
  case int.parse(id) {
    Ok(user_id) -> cont(user_id)
    Error(_) -> {
      req
      |> inertia.response_builder("Error")
      |> inertia.errors(
        dict.from_list([
          #(
            "message",
            "Invalid user ID: '"
              <> id
              <> "'. Please check the URL and try again.",
          ),
        ]),
      )
      |> inertia.response(200)
    }
  }
}

/// Get user from database or show error page if not found
fn get_user_or_error(
  req: Request,
  user_id: Int,
  db: Connection,
  cont: fn(users.User) -> Response,
) -> Response {
  case users.get_user_by_id(db, user_id) {
    Ok(option.Some(user)) -> cont(user)
    Ok(option.None) -> {
      req
      |> inertia.response_builder("Error")
      |> inertia.errors(
        dict.from_list([
          #(
            "message",
            "User not found with ID "
              <> int.to_string(user_id)
              <> ". The user may have been deleted or the ID is incorrect.",
          ),
        ]),
      )
      |> inertia.response(200)
    }
    Error(_) -> {
      req
      |> inertia.response_builder("Error")
      |> inertia.errors(
        dict.from_list([
          #(
            "message",
            "Database error occurred while fetching user. Please try again later.",
          ),
        ]),
      )
      |> inertia.response(200)
    }
  }
}
