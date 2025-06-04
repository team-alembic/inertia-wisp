import data/users
import handlers/utils
import inertia_wisp/inertia
import sqlight
import wisp

pub fn delete_user(
  req: inertia.InertiaContext(Nil),
  id_str: String,
  db: sqlight.Connection,
) -> wisp.Response {
  use id <- utils.require_int(id_str)
  case users.find_user_by_id(db, id) {
    Ok(_user) -> handle_successful_deletion(req, id, db)
    Error(_) -> wisp.not_found()
  }
}

fn handle_successful_deletion(
  req: inertia.InertiaContext(Nil),
  id: Int,
  db: sqlight.Connection,
) -> wisp.Response {
  case users.delete_user(db, id) {
    Ok(_) -> inertia.redirect(req.request, "/users")
    Error(_) -> wisp.internal_server_error()
  }
}
