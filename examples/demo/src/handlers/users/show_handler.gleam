import data/users
import gleam/json
import handlers/utils
import inertia_wisp/inertia
import props
import sqlight
import types/user.{type User}
import wisp

pub fn show_user_page(
  req: inertia.InertiaContext(inertia.EmptyProps),
  id_str: String,
  db: sqlight.Connection,
) -> wisp.Response {
  use id <- utils.require_int(id_str)
  case users.find_user_by_id(db, id) {
    Ok(user) -> render_user_page(req, user)
    Error(_) -> wisp.not_found()
  }
}

fn render_user_page(req: inertia.InertiaContext(inertia.EmptyProps), user: User) -> wisp.Response {
  let user_data = user.user_to_json(user)

  // Create initial props
  let initial_props = props.UserProps(
    auth: props.unauthenticated_user(),
    csrf_token: "",
    users: [],
    pagination: json.null(),
    user: json.null(),
    success: "",
    errors: json.null(),
  )

  // Transform to typed context
  req
  |> inertia.set_props(initial_props, props.encode_user_props)
  |> utils.assign_user_common_props()
  |> inertia.prop(props.user_user(user_data))
  |> inertia.render("ShowUser")
}
