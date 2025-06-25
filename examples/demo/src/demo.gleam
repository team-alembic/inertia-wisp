import data/users as user_data
import gleam/erlang/process
import gleam/http
import gleam/list
import gleam/option
import handlers/uploads
import handlers/users
import inertia_wisp/inertia
import mist
import shared_types/about
import shared_types/auth
import shared_types/home
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
    |> mist.start

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
  ctx: inertia.InertiaContext(Nil),
  db: sqlight.Connection,
) -> wisp.Response {
  let user_count = case user_data.get_all_users(db) {
    Ok(users) -> list.length(users)
    Error(_) -> 0
  }

  ctx
  |> inertia.with_encoder(home.encode_home_page_prop)
  |> inertia.always_prop(
    "auth",
    home.Auth(auth.authenticated_user("demo_user")),
  )
  |> inertia.always_prop("csrf_token", home.CsrfToken("abc123xyz"))
  |> inertia.prop("message", home.Message("Hello from Gleam!"))
  |> inertia.prop("timestamp", home.Timestamp("2024-01-01T00:00:00Z"))
  |> inertia.prop("user_count", home.UserCount(user_count))
  |> inertia.render("Home")
}

fn about_page(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
  ctx
  |> inertia.with_encoder(about.encode_about_page_prop)
  |> inertia.always_prop(
    "auth",
    about.Auth(auth.authenticated_user("demo_user")),
  )
  |> inertia.always_prop("csrf_token", about.CsrfToken("abc123xyz"))
  |> inertia.prop("page_title", about.PageTitle("About Us"))
  |> inertia.prop(
    "description",
    about.Description("Learn more about our application"),
  )
  |> inertia.render("About")
}
