//// Simple demo application showcasing the new inertia.eval API design.
////
//// This application demonstrates how to use the new Inertia API without
//// the InertiaContext type, instead constructing Page objects directly
//// and using regular Wisp functionality.

import gleam/erlang/process
import gleam/http
import handlers/home
import mist
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
  case wisp.path_segments(req), req.method {
    [], http.Get -> home.home_page(req)
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
