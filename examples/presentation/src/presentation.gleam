//// Presentation application using Inertia-Wisp
////
//// A presentation demo that showcases Inertia-Wisp by using it to present itself.
//// Each slide is a route, and the backend acts as a CMS providing all content
//// to generic frontend templates.

import gleam/erlang/process
import gleam/http
import handlers/slides
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let _ = start_server()
  process.sleep_forever()
}

/// Start the web server with HTTPS
fn start_server() {
  let assert Ok(priv_directory) = wisp.priv_directory("presentation")
  let cert_file = priv_directory <> "/certs/localhost.crt"
  let key_file = priv_directory <> "/certs/localhost.key"

  let assert Ok(_) =
    handle_request
    |> wisp_mist.handler(get_secret_key())
    |> mist.new
    |> mist.port(get_server_port())
    |> mist.with_tls(cert_file, key_file)
    |> mist.start
}

/// Handle incoming HTTP requests
fn handle_request(req: wisp.Request) -> wisp.Response {
  let assert Ok(priv_directory) = wisp.priv_directory("presentation")
  use <- wisp.serve_static(
    req,
    from: priv_directory <> "/static",
    under: "/static",
  )
  route_request(req)
}

/// Route requests to appropriate handlers
fn route_request(req: wisp.Request) -> wisp.Response {
  case wisp.path_segments(req), req.method {
    [], http.Get -> slides.index(req)
    ["slides", slide_num], http.Get -> slides.view_slide(req, slide_num)
    _, _ -> wisp.not_found()
  }
}

/// Get the secret key for session management
fn get_secret_key() -> String {
  "secret_key_change_me_in_production"
}

/// Get the server port (HTTPS)
fn get_server_port() -> Int {
  8444
}
