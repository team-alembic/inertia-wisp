//// User show handler for the simple demo application.
////
//// This module handles displaying individual user details.
//// It demonstrates fetching a single user by ID and handling
//// not found cases with proper redirects.

import data/users
import gleam/int
import gleam/option
import inertia_wisp/inertia
import inertia_wisp/internal/types
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Show individual user details
pub fn handler(req: Request, id: String, db: Connection) -> Response {
  case int.parse(id) {
    Error(_) -> wisp.redirect("/users")
    Ok(user_id) ->
      case users.get_user_by_id(db, user_id) {
        Error(_) -> wisp.redirect("/users")
        Ok(option.None) -> wisp.redirect("/users")
        Ok(option.Some(user)) -> {
          let props = [types.DefaultProp("user", user_props.UserData(user))]
          let page =
            inertia.eval(req, "Users/Show", props, user_props.encode_user_prop)
          inertia.render(req, page)
        }
      }
  }
}
