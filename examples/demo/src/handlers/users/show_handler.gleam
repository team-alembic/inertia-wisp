import data/users
import handlers/utils
import inertia_wisp/inertia
import types/user.{type User}
import wisp

pub fn show_user_page(
  req: inertia.InertiaContext,
  id_str: String,
) -> wisp.Response {
  case utils.parse_user_id(id_str) {
    Ok(id) -> handle_valid_user_id(req, id)
    Error(_) -> wisp.not_found()
  }
}

fn handle_valid_user_id(req: inertia.InertiaContext, id: Int) -> wisp.Response {
  case users.find_user_by_id(id) {
    Ok(user) -> render_user_page(req, user)
    Error(_) -> wisp.not_found()
  }
}

fn render_user_page(req: inertia.InertiaContext, user: User) -> wisp.Response {
  let user_data = user.user_to_json(user)

  req
  |> utils.assign_common_props()
  |> inertia.assign_prop("user", user_data)
  |> inertia.render("ShowUser")
}
