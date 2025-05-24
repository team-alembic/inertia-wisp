import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist
import inertia_gleam

pub fn main() {
  wisp.configure_logger()
  
  let config = inertia_gleam.default_config()
  
  let assert Ok(_) =
    fn(req) { handle_request(req, config) }
    |> wisp_mist.handler("secret_key_change_me")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn handle_request(req: wisp.Request, config: inertia_gleam.Config) -> wisp.Response {
  use _req <- inertia_gleam.inertia_middleware(req, config)
  
  case wisp.path_segments(req) {
    [] -> home_page(req)
    ["about"] -> about_page(req)
    _ -> wisp.not_found()
  }
}

fn home_page(req: wisp.Request) -> wisp.Response {
  let props = inertia_gleam.props_from_list([
    #("message", inertia_gleam.string_prop("Hello from Gleam!")),
    #("timestamp", inertia_gleam.int_prop(1234567890)),
  ])
  
  inertia_gleam.render_inertia_with_props(req, "Home", props)
}

fn about_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.render_inertia(req, "About")
}