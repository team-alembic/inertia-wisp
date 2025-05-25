import data/users as user_data
import gleam/erlang/process
import gleam/http
import gleam/json
import gleam/list
import handlers/users
import inertia_gleam
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let assert Ok(_) =
    fn(req) { handle_request(req) }
    |> wisp_mist.handler("secret_key_change_me_in_production")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn handle_request(req: wisp.Request) -> wisp.Response {
  use <- wisp.serve_static(req, from: "./static", under: "/static")
  use req <- inertia_gleam.inertia_middleware(req)

  case wisp.path_segments(req), req.method {
    [], http.Get -> home_page(req)
    ["about"], http.Get -> about_page(req)
    ["users"], http.Get -> users.users_page(req)
    ["users", "create"], http.Get -> users.create_user_page(req)
    ["users"], http.Post -> users.create_user(req)
    ["users", id], http.Get -> users.show_user_page(req, id)
    ["users", id, "edit"], http.Get -> users.edit_user_page(req, id)
    ["users", id], http.Post -> users.update_user(req, id)
    ["users", id, "delete"], http.Post -> users.delete_user(req, id)
    _, _ -> wisp.not_found()
  }
}

fn home_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> inertia_gleam.assign_always_props([
    #(
      "auth",
      json.object([
        #("authenticated", json.bool(True)),
        #("user", json.string("demo_user")),
      ]),
    ),
    #("csrf_token", json.string("abc123xyz")),
  ])
  |> inertia_gleam.assign_props([
    #("message", json.string("Hello from Gleam!")),
    #("timestamp", json.string("2024-01-01T00:00:00Z")),
    #("user_count", json.int(list.length(user_data.get_initial_state().users))),
  ])
  |> inertia_gleam.render("Home")
}

fn about_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> inertia_gleam.assign_always_props([
    #(
      "auth",
      json.object([
        #("authenticated", json.bool(True)),
        #("user", json.string("demo_user")),
      ]),
    ),
    #("csrf_token", json.string("abc123xyz")),
  ])
  |> inertia_gleam.assign_prop("page_title", json.string("About Us"))
  |> inertia_gleam.render("About")
}
