import data/users
import gleam/json
import handlers/utils
import inertia_wisp/inertia
import types/user
import wisp

pub fn users_page(req: inertia.InertiaContext) -> wisp.Response {
  let users_data = get_users_data()
  echo users_data

  req
  |> utils.assign_common_props()
  |> inertia.assign_prop("users", users_data)
  |> inertia.render("Users")
}

fn get_users_data() -> json.Json {
  json.array(users.get_initial_state().users, user.user_to_json)
}
