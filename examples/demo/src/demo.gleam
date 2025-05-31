import data/users as user_data
import gleam/erlang/process
import gleam/http
import gleam/json
import gleam/list
import gleam/option
import handlers/uploads
import handlers/users
import inertia_wisp/inertia
import inertia_wisp/internal/types
import mist
import props
import sqlight
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  // Open SQLite in-memory database connection
  let assert Ok(db) = sqlight.open(":memory:")
  wisp.log_info("SQLite in-memory database connection opened")

  // Create users table
  let assert Ok(_) = create_users_table(db)
  wisp.log_info("Users table created successfully")

  // Initialize with sample data
  let assert Ok(_) = user_data.init_sample_data(db)
  wisp.log_info("Sample user data initialized")

  // Start SSR supervisor with graceful fallback
  let ssr_supervisor = start_ssr_supervisor()

  let assert Ok(_) =
    handle_request(_, ssr_supervisor, db)
    |> wisp_mist.handler("secret_key_change_me_in_production")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn create_users_table(db: sqlight.Connection) -> Result(Nil, sqlight.Error) {
  let sql =
    "CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
  )"

  sqlight.exec(sql, db)
}

fn start_ssr_supervisor() {
  let config =
    inertia.ssr_config(
      enabled: True,
      path: "./static/js",
      module: "ssr",
      pool_size: 2,
      timeout_ms: 5000,
      supervisor_name: "InertiaSSR",
    )

  case inertia.start_ssr_supervisor(config) {
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
  ssr_supervisor: option.Option(process.Subject(inertia.SSRMessage)),
  db: sqlight.Connection,
) -> wisp.Response {
  use <- wisp.serve_static(req, from: "./static", under: "/static")
  use ctx <- inertia.middleware(req, inertia.default_config(), ssr_supervisor)
  case wisp.path_segments(req), req.method {
    [], http.Get -> home_page(ctx, db)
    ["about"], http.Get -> about_page(ctx)
    ["versioned"], http.Get -> versioned_page(ctx)
    ["users"], http.Get -> users.users_page(ctx, db)
    ["users", "create"], http.Get -> users.create_user_page(ctx)
    ["users"], http.Post -> users.create_user(ctx, db)
    ["users", id], http.Get -> users.show_user_page(ctx, id, db)
    ["users", id, "edit"], http.Get -> users.edit_user_page(ctx, id, db)
    ["users", id], http.Post -> users.update_user(ctx, id, db)
    ["users", id, "delete"], http.Post -> users.delete_user(ctx, id, db)
    ["upload"], http.Get -> uploads.upload_form_page(ctx)
    ["upload"], http.Post -> uploads.handle_upload(ctx)
    _, _ -> wisp.not_found()
  }
}

fn home_page(
  req: inertia.InertiaContext,
  db: sqlight.Connection,
) -> wisp.Response {
  let user_count = case user_data.get_all_users(db) {
    Ok(users) -> list.length(users)
    Error(_) -> 0
  }

  // Create initial props
  let initial_props = props.HomeProps(
    auth: json.null(),
    csrf_token: "",
    message: "",
    timestamp: "",
    user_count: 0,
  )

  // Create typed context
  let typed_ctx = inertia.new_typed_context(
    req.config,
    req.request,
    initial_props,
    props.encode_home_props,
  )

  typed_ctx
  |> inertia.assign_always_typed_prop("auth", fn(props) {
    props.HomeProps(..props, auth: json.object([
      #("authenticated", json.bool(True)),
      #("user", json.string("demo_user")),
    ]))
  })
  |> inertia.assign_always_typed_prop("csrf_token", fn(props) {
    props.HomeProps(..props, csrf_token: "abc123xyz")
  })
  |> inertia.assign_typed_prop("message", fn(props) {
    props.HomeProps(..props, message: "Hello from Gleam!")
  })
  |> inertia.assign_typed_prop("timestamp", fn(props) {
    props.HomeProps(..props, timestamp: "2024-01-01T00:00:00Z")
  })
  |> inertia.assign_typed_prop("user_count", fn(props) {
    props.HomeProps(..props, user_count: user_count)
  })
  |> inertia.render_typed("Home")
}

/// Example of using asset versioning with custom config
fn versioned_page(req: inertia.InertiaContext) -> wisp.Response {
  // Create config with custom version (in real app, this might come from build system)
  let config =
    inertia.config(
      version: "v2.1.0-abc123",
      ssr: req.config.ssr,
      encrypt_history: req.config.encrypt_history,
    )

  req
  |> inertia.set_config(config)
  |> inertia.assign_prop("title", json.string("Asset Versioning Demo"))
  |> inertia.assign_prop("version", json.string(config.version))
  |> inertia.assign_prop(
    "message",
    json.string("This page uses custom asset versioning"),
  )
  |> inertia.render("VersionedPage")
}

fn about_page(req: inertia.InertiaContext) -> wisp.Response {
  req
  |> inertia.assign_always_props([
    #(
      "auth",
      json.object([
        #("authenticated", json.bool(True)),
        #("user", json.string("demo_user")),
      ]),
    ),
    #("csrf_token", json.string("abc123xyz")),
  ])
  |> inertia.assign_prop("page_title", json.string("About Us"))
  |> inertia.render("About")
}
