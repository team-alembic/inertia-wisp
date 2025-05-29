import data/users
import gleam/json
import gleam/list
import handlers/utils
import inertia_wisp/inertia
import types/user.{type User}
import wisp

pub fn users_page(req: inertia.InertiaContext) -> wisp.Response {
  let users_data = get_users_data()

  req
  |> utils.assign_common_props()
  |> inertia.assign_prop("users", users_data)
  |> inertia.render("Users")
}

fn get_users_data() -> json.Json {
  let users_json = list.map(users.get_initial_state().users, serialize_user)

  json.array(users_json, fn(x) { x })
}

fn serialize_user(user: User) -> json.Json {
  utils.serialize_user_data(user)
}
