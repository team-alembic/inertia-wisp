//// Simple demo application showcasing the new inertia.eval API design.
////
//// This application demonstrates how to use the new Inertia API without
//// the InertiaContext type, instead constructing Page objects directly
//// and using regular Wisp functionality.

import data/users as data_users
import gleam/erlang/process
import gleam/http
import gleam/result
import handlers/home
import handlers/users
import mist
import sqlight
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let _ = start_server()
  process.sleep_forever()
}

/// Start the web server
fn start_server() {
  let assert Ok(_) =
    handle_request
    |> wisp_mist.handler(get_secret_key())
    |> mist.new
    |> mist.port(get_server_port())
    |> mist.start
}

/// Handle incoming HTTP requests
fn handle_request(req: wisp.Request) -> wisp.Response {
  use <- wisp.serve_static(req, from: get_static_path(), under: "/static")
  route_request(req)
}

/// Route requests to appropriate handlers
fn route_request(req: wisp.Request) -> wisp.Response {
  let assert Ok(db) = sqlight.open("simple_demo.db")
  let assert Ok(_) = ensure_database_setup(db)

  case wisp.path_segments(req), req.method {
    [], http.Get -> home.home_page(req)
    ["users"], http.Get -> users.users_index(req, db)
    ["users", "create"], http.Get -> users.users_create_form(req, db)
    ["users"], http.Post -> users.users_create(req, db)
    ["users", id], http.Get -> users.users_show(req, id, db)
    ["users", id, "edit"], http.Get -> users.users_edit_form(req, id, db)
    ["users", id], http.Put -> users.users_update(req, id, db)
    ["users", id], http.Post -> users.users_update(req, id, db)
    ["users", id], http.Delete -> users.users_delete(req, id, db)
    _, _ -> wisp.not_found()
  }
}

/// Get the secret key for session management
fn get_secret_key() -> String {
  "secret_key_change_me_in_production"
}

/// Get the server port
fn get_server_port() -> Int {
  8001
}

/// Get the static files path
fn get_static_path() -> String {
  "./static"
}

/// Create and initialize the database with sample data
fn ensure_database_setup(db: sqlight.Connection) -> Result(Nil, sqlight.Error) {
  use _ <- result.try(data_users.create_users_table(db))
  // Only initialize sample data if table is empty
  case data_users.get_user_count(db) {
    Ok(0) -> data_users.init_sample_data(db)
    Ok(_) -> Ok(Nil)
    // Data already exists, don't reinitialize
    Error(_) -> data_users.init_sample_data(db)
    // Error checking, so initialize
  }
}
