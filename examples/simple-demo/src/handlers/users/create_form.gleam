//// User creation form handler for the simple demo application.
////
//// This module handles displaying the user creation form page.
//// It provides an empty form for creating new users.

import inertia_wisp/inertia
import inertia_wisp/internal/types
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Show user creation form
pub fn handler(req: Request, _db: Connection) -> Response {
  let props = [types.DefaultProp("form_data", user_props.UserFormData("", ""))]

  let page =
    inertia.eval(req, "Users/Create", props, user_props.encode_user_prop)
  inertia.render(req, page)
}
