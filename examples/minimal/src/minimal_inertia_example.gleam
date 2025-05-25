import gleam/erlang/process
import gleam/json
import inertia_gleam
import mist
import wisp
import wisp/wisp_mist

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

fn handle_request(
  req: wisp.Request,
  config: inertia_gleam.Config,
) -> wisp.Response {
  use <- wisp.serve_static(req, from: "./static", under: "/static")
  use req <- inertia_gleam.inertia_middleware(req, config)

  case wisp.path_segments(req) {
    [] -> home_page(req)
    ["about"] -> about_page(req)
    _ -> wisp.not_found()
  }
}

// fn home_page(req: wisp.Request) -> wisp.Response {
//   // Traditional approach
//   let props =
//     inertia_gleam.props_from_list([
//       #("message", inertia_gleam.string_prop("Hello from Gleam!")),
//       #("timestamp", inertia_gleam.string_prop("2024-01-01T00:00:00Z")),
//     ])

//   inertia_gleam.render_inertia_with_props(req, "Home", props)
// }

fn home_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> inertia_gleam.assign_props([
    #("message", json.string("Hello from Gleam!")),
    #("timestamp", json.string("2024-01-01T00:00:00Z")),
    #("user_id", json.int(42)),
  ])
  |> inertia_gleam.render("Home")
}

fn about_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.render_inertia(req, "About")
}
