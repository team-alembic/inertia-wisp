//// User deletion handler for the simple demo application.
////
//// This module handles DELETE/POST requests to remove users from the system.
//// It demonstrates proper ID validation and database deletion with redirect
//// handling for both successful and failed operations.

import data/users
import gleam/int
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user deletion (POST)
pub fn handler(_req: Request, id: String, db: Connection) -> Response {
  case int.parse(id) {
    Error(_) -> wisp.not_found()
    Ok(user_id) -> {
      let _ = users.delete_user(db, user_id)
      wisp.redirect("/users")
    }
  }
}
