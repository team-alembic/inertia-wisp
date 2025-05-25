// User handlers module - aggregates all user-related request handlers
import handlers/users/create_handler
import handlers/users/delete_handler
import handlers/users/edit_handler
import handlers/users/list_handler
import handlers/users/show_handler
import wisp

// Re-export all user handler functions for easy importing
pub fn users_page(req: wisp.Request) -> wisp.Response {
  list_handler.users_page(req)
}

pub fn create_user_page(req: wisp.Request) -> wisp.Response {
  create_handler.create_user_page(req)
}

pub fn create_user(req: wisp.Request) -> wisp.Response {
  create_handler.create_user(req)
}

pub fn show_user_page(req: wisp.Request, id: String) -> wisp.Response {
  show_handler.show_user_page(req, id)
}

pub fn edit_user_page(req: wisp.Request, id: String) -> wisp.Response {
  edit_handler.edit_user_page(req, id)
}

pub fn update_user(req: wisp.Request, id: String) -> wisp.Response {
  edit_handler.update_user(req, id)
}

pub fn delete_user(req: wisp.Request, id: String) -> wisp.Response {
  delete_handler.delete_user(req, id)
}
