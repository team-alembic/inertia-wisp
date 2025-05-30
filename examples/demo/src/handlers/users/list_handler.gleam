import data/users
import gleam/json
import handlers/utils
import inertia_wisp/inertia
import sqlight
import types/user
import wisp

pub fn users_page(
  req: inertia.InertiaContext,
  db: sqlight.Connection,
) -> wisp.Response {
  let users_data = get_users_data(db)
  req
  |> utils.assign_common_props()
  |> inertia.assign_prop("users", users_data)
  |> inertia.render("Users")
}

fn get_users_data(db: sqlight.Connection) -> json.Json {
  case users.get_all_users(db) {
    Ok(user_list) -> json.array(user_list, user.user_to_json)
    Error(_) -> json.array([], user.user_to_json)
  }
}
