// User handlers module - aggregates all user-related request handlers
import handlers/users/create_handler
import handlers/users/delete_handler
import handlers/users/edit_handler
import handlers/users/list_handler
import handlers/users/show_handler
import inertia_wisp/inertia.{type InertiaContext}
import sqlight
import wisp

// Re-export all user handler functions for easy importing
pub fn users_page(req: InertiaContext(inertia.EmptyProps), db: sqlight.Connection) -> wisp.Response {
  list_handler.users_page(req, db)
}

pub fn create_user_page(req: InertiaContext(inertia.EmptyProps)) -> wisp.Response {
  create_handler.create_user_page(req)
}

pub fn create_user(req: InertiaContext(inertia.EmptyProps), db: sqlight.Connection) -> wisp.Response {
  create_handler.create_user(req, db)
}

pub fn show_user_page(
  req: InertiaContext(inertia.EmptyProps),
  id: String,
  db: sqlight.Connection,
) -> wisp.Response {
  show_handler.show_user_page(req, id, db)
}

pub fn edit_user_page(
  req: InertiaContext(inertia.EmptyProps),
  id: String,
  db: sqlight.Connection,
) -> wisp.Response {
  edit_handler.edit_user_page(req, id, db)
}

pub fn update_user(
  req: InertiaContext(inertia.EmptyProps),
  id: String,
  db: sqlight.Connection,
) -> wisp.Response {
  edit_handler.update_user(req, id, db)
}

pub fn delete_user(
  req: InertiaContext(inertia.EmptyProps),
  id: String,
  db: sqlight.Connection,
) -> wisp.Response {
  delete_handler.delete_user(req, id, db)
}
