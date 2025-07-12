//// User edit form handler for the simple demo application.
////
//// This module handles displaying the user edit form page.
//// It fetches the existing user data and populates the form
//// for editing, with proper error handling for invalid IDs.

import data/users
import gleam/int
import gleam/option
import inertia_wisp/inertia
import inertia_wisp/internal/types
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Show user edit form
pub fn handler(req: Request, id: String, db: Connection) -> Response {
  case int.parse(id) {
    Error(_) -> wisp.redirect("/users")
    Ok(user_id) ->
      case users.get_user_by_id(db, user_id) {
        Error(_) -> wisp.redirect("/users")
        Ok(option.None) -> wisp.redirect("/users")
        Ok(option.Some(user)) -> {
          let props = [
            types.DefaultProp("user", user_props.UserData(user)),
            types.DefaultProp(
              "form_data",
              user_props.UserFormData(user.name, user.email),
            ),
          ]
          let page =
            inertia.eval(req, "Users/Edit", props, user_props.encode_user_prop)
          inertia.render(req, page)
        }
      }
  }
}
