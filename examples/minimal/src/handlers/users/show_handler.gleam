import inertia_gleam
import wisp
import data/users
import types/user.{type User}
import handlers/utils

pub fn show_user_page(req: wisp.Request, id_str: String) -> wisp.Response {
  case utils.parse_user_id(id_str) {
    Ok(id) -> handle_valid_user_id(req, id)
    Error(_) -> wisp.not_found()
  }
}



fn handle_valid_user_id(req: wisp.Request, id: Int) -> wisp.Response {
  case users.find_user_by_id(id) {
    Ok(user) -> render_user_page(req, user)
    Error(_) -> wisp.not_found()
  }
}

fn render_user_page(req: wisp.Request, user: User) -> wisp.Response {
  let user_data = utils.serialize_user_data(user)
  
  inertia_gleam.context(req)
  |> utils.assign_common_props()
  |> inertia_gleam.assign_prop("user", user_data)
  |> inertia_gleam.render("ShowUser")
}



