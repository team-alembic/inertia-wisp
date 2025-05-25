import inertia_gleam
import wisp
import data/users
import handlers/utils

pub fn delete_user(req: wisp.Request, id_str: String) -> wisp.Response {
  case utils.parse_user_id(id_str) {
    Ok(id) -> handle_valid_delete_request(req, id)
    Error(_) -> wisp.not_found()
  }
}

fn handle_valid_delete_request(req: wisp.Request, id: Int) -> wisp.Response {
  case users.find_user_by_id(id) {
    Ok(_user) -> handle_successful_deletion(req)
    Error(_) -> wisp.not_found()
  }
}

fn handle_successful_deletion(req: wisp.Request) -> wisp.Response {
  inertia_gleam.redirect_after_form(req, "/users")
}

