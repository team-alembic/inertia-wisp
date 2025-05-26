import data/users
import handlers/utils
import inertia_gleam
import inertia_gleam/types
import wisp

pub fn delete_user(req: types.InertiaContext, id_str: String) -> wisp.Response {
  case utils.parse_user_id(id_str) {
    Ok(id) -> handle_valid_delete_request(req, id)
    Error(_) -> wisp.not_found()
  }
}

fn handle_valid_delete_request(
  req: types.InertiaContext,
  id: Int,
) -> wisp.Response {
  case users.find_user_by_id(id) {
    Ok(_user) -> handle_successful_deletion(req)
    Error(_) -> wisp.not_found()
  }
}

fn handle_successful_deletion(
  req: inertia_gleam.InertiaContext,
) -> wisp.Response {
  inertia_gleam.redirect(req, "/users")
}
