//// User handlers for the simple demo application.
////
//// This module re-exports all user-related handlers from their individual modules.
//// Each handler is now in its own focused module for better organization and
//// single responsibility.

import handlers/users/create
import handlers/users/create_form
import handlers/users/delete
import handlers/users/edit_form
import handlers/users/index
import handlers/users/search
import handlers/users/show
import handlers/users/update
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Display list of all users (demonstrates LazyProp for expensive operations)
pub fn users_index(req: Request, db: Connection) -> Response {
  index.handler(req, db)
}

/// Show user creation form
pub fn users_create_form(req: Request, db: Connection) -> Response {
  create_form.handler(req, db)
}

/// Handle user creation (POST)
pub fn users_create(req: Request, db: Connection) -> Response {
  create.handler(req, db)
}

/// Show individual user details
pub fn users_show(req: Request, id: String, db: Connection) -> Response {
  show.handler(req, id, db)
}

/// Show user edit form
pub fn users_edit_form(req: Request, id: String, db: Connection) -> Response {
  edit_form.handler(req, id, db)
}

/// Handle user update (POST)
pub fn users_update(req: Request, id: String, db: Connection) -> Response {
  update.handler(req, id, db)
}

/// Handle user deletion (POST)
pub fn users_delete(req: Request, id: String, db: Connection) -> Response {
  delete.handler(req, id, db)
}

/// Handle user search with advanced filters
pub fn users_search(req: Request, db: Connection) -> Response {
  search.handler(req, db)
}
