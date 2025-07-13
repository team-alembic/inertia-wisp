//// User-specific utilities for user handlers using continuation-passing style.
////
//// This module provides reusable utility functions that encapsulate common
//// patterns in user request handling, such as ID parsing, user fetching,
//// and JSON decoding with proper error handling using continuations.

import data/users

import gleam/int
import gleam/option
import sqlight.{type Connection}
import wisp.{type Response}

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
