import data/users as user_data
import gleam/erlang/process
import gleam/http
import gleam/json
import gleam/list
import gleam/option
import handlers/uploads
import handlers/users
import inertia_gleam
import inertia_gleam/ssr
import inertia_gleam/types.{Config}
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  // Start SSR supervisor with graceful fallback
  let ssr_supervisor = start_ssr_supervisor()

  let assert Ok(_) =
    handle_request(_, ssr_supervisor)
    |> wisp_mist.handler("secret_key_change_me_in_production")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn start_ssr_supervisor() {
  let config =
    types.SSRConfig(
      enabled: True,
      path: "./ssr",
      module: "ssr",
      pool_size: 2,
      timeout_ms: 5000,
      raise_on_failure: False,
      supervisor_name: "InertiaSSR",
    )

  case ssr.start_supervisor(config) {
    Ok(supervisor) -> {
      wisp.log_info("SSR supervisor started successfully")
      option.Some(supervisor)
    }
    Error(error) -> {
      wisp.log_info("SSR not available, falling back to CSR: " <> error)
      option.None
    }
  }
}

fn handle_request(
  req: wisp.Request,
  ssr_supervisor: option.Option(process.Subject(types.SSRMessage)),
) -> wisp.Response {
  use <- wisp.serve_static(req, from: "./static", under: "/static")
  use ctx <- inertia_gleam.inertia_middleware(
    req,
    inertia_gleam.default_config(),
    ssr_supervisor,
  )

  case wisp.path_segments(req), req.method {
    [], http.Get -> home_page(ctx)
    ["about"], http.Get -> about_page(ctx)
    ["versioned"], http.Get -> versioned_page(ctx)
    ["users"], http.Get -> users.users_page(ctx)
    ["users", "create"], http.Get -> users.create_user_page(ctx)
    ["users"], http.Post -> users.create_user(ctx)
    ["users", id], http.Get -> users.show_user_page(ctx, id)
    ["users", id, "edit"], http.Get -> users.edit_user_page(ctx, id)
    ["users", id], http.Post -> users.update_user(ctx, id)
    ["users", id, "delete"], http.Post -> users.delete_user(ctx, id)
    ["upload"], http.Get -> uploads.upload_form_page(ctx)
    ["upload"], http.Post -> uploads.handle_upload(ctx)
    _, _ -> wisp.not_found()
  }
}

fn home_page(req: inertia_gleam.InertiaContext) -> wisp.Response {
  req
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

/// Example of using asset versioning with custom config
fn versioned_page(req: inertia_gleam.InertiaContext) -> wisp.Response {
  // Create config with custom version (in real app, this might come from build system)
  let config =
    Config(..inertia_gleam.default_config(), version: "v2.1.0-abc123")

  req
  |> inertia_gleam.set_config(config)
  |> inertia_gleam.assign_prop("title", json.string("Asset Versioning Demo"))
  |> inertia_gleam.assign_prop("version", json.string(config.version))
  |> inertia_gleam.assign_prop(
    "message",
    json.string("This page uses custom asset versioning"),
  )
  |> inertia_gleam.render("VersionedPage")
}

fn about_page(req: inertia_gleam.InertiaContext) -> wisp.Response {
  req
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
