//// User create form handler for the simple demo application.
////
//// This module handles GET requests to show the create form for new users.
//// It demonstrates the Response Builder API with empty form data.

import inertia_wisp/inertia
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user create form (GET)
///
/// This demonstrates the Response Builder API pattern:
/// 1. Create a response builder with component name
/// 2. Add props using the props() method
/// 3. Generate the response using the response() method
///
/// Shows an empty form for creating new users.
pub fn handler(req: Request, _db: Connection) -> Response {
  let props = [user_props.form_data("", "")]

  req
  |> inertia.response_builder("Users/Create")
  |> inertia.props(props, user_props.user_prop_to_json)
  |> inertia.response(200)
}
