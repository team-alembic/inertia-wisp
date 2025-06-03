import data/users
import gleam/json
import gleam/list
import handlers/utils
import inertia_wisp/inertia
import props
import sqlight
import types/user
import wisp

pub fn users_page(
  ctx: inertia.InertiaContext(Nil),
  db: sqlight.Connection,
) -> wisp.Response {
  let users_data = get_users_data(db)

  // Create initial props
  let initial_props =
    props.UserProps(
      auth: props.unauthenticated_user(),
      csrf_token: "",
      users: [],
      pagination: json.null(),
      user: json.null(),
      success: "",
      errors: json.null(),
    )

  // Transform to typed context
  ctx
  |> inertia.set_props(initial_props, props.encode_user_props)
  |> utils.assign_user_common_props()
  |> inertia.prop(props.user_users(users_data))
  |> inertia.render("Users")
}

fn get_users_data(db: sqlight.Connection) -> List(json.Json) {
  case users.get_all_users(db) {
    Ok(user_list) -> list.map(user_list, user.user_to_json)
    Error(_) -> []
  }
}
