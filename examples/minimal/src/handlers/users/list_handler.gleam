import data/users
import gleam/json
import gleam/list
import handlers/utils
import inertia_gleam
import types/user.{type User}
import wisp

pub fn users_page(req: wisp.Request) -> wisp.Response {
  let users_data = get_users_data()

  inertia_gleam.context(req)
  |> utils.assign_common_props()
  |> inertia_gleam.assign_prop("users", users_data)
  |> inertia_gleam.render("Users")
}

fn get_users_data() -> json.Json {
  let users_json = list.map(users.get_initial_state().users, serialize_user)

  json.array(users_json, fn(x) { x })
}

fn serialize_user(user: User) -> json.Json {
  utils.serialize_user_data(user)
}
