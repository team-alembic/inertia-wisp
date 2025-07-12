//// User show handler for the simple demo application.
////
//// This module handles displaying individual user details.
//// It demonstrates fetching a single user by ID and handling
//// not found cases with proper redirects.

import handlers/users/utils
import inertia_wisp/inertia
import inertia_wisp/internal/types
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Show individual user details
pub fn handler(req: Request, id: String, db: Connection) -> Response {
  use user_id <- utils.parse_user_id(id)
  use user <- utils.get_user_or_redirect(user_id, db, "/users")
  let props = [types.DefaultProp("user", user_props.UserData(user))]
  let page = inertia.eval(req, "Users/Show", props, user_props.encode_user_prop)
  inertia.render(req, page)
}
