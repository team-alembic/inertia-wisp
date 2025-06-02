import data/users as user_data
import gleam/erlang/process
import gleam/http
import gleam/json
import gleam/list
import gleam/option
import handlers/uploads
import handlers/users
import inertia_wisp/inertia

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
    ["demo-features"], http.Get -> demo_features_page(ctx)
    _, _ -> wisp.not_found()
  }
}

fn home_page(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  db: sqlight.Connection,
) -> wisp.Response {
  let user_count = case user_data.get_all_users(db) {
    Ok(users) -> list.length(users)
    Error(_) -> 0
  }

  // Create initial props
  let initial_props =
    props.HomeProps(
      auth: props.unauthenticated_user(),
      csrf_token: "",
      message: "",
      timestamp: "",
      user_count: 0,
    )

  // Transform to typed context
  ctx
  |> inertia.set_props(initial_props, props.encode_home_props)
  |> inertia.always_prop(props.home_auth(props.authenticated_user("demo_user")))
  |> inertia.always_prop(props.home_csrf_token("abc123xyz"))
  |> inertia.prop(props.home_message("Hello from Gleam!"))
  |> inertia.prop(props.home_timestamp("2024-01-01T00:00:00Z"))
  |> inertia.prop(props.home_user_count(user_count))
  |> inertia.render("Home")
}

/// Example of using asset versioning with custom config
fn versioned_page(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  // Create initial props
  let initial_props =
    props.VersionedProps(
      auth: props.unauthenticated_user(),
      csrf_token: "",
      version: "",
      build_info: "",
    )

  // Transform to typed context and assign props
  ctx
  |> inertia.set_props(initial_props, props.encode_versioned_props)
  |> inertia.always_prop(
    props.versioned_auth(props.authenticated_user("demo_user")),
  )
  |> inertia.always_prop(props.versioned_csrf_token("abc123xyz"))
  |> inertia.prop(props.versioned_version("v2.1.0-abc123"))
  |> inertia.prop(props.versioned_build_info(
    "This page uses custom asset versioning",
  ))
  |> inertia.render("VersionedPage")
}

fn about_page(ctx: inertia.InertiaContext(inertia.EmptyProps)) -> wisp.Response {
  // Create initial props
  let initial_props =
    props.AboutProps(
      auth: props.unauthenticated_user(),
      csrf_token: "",
      page_title: "",
      description: "",
    )

  // Transform to typed context and assign props
  ctx
  |> inertia.set_props(initial_props, props.encode_about_props)
  |> inertia.always_prop(
    props.about_auth(props.authenticated_user("demo_user")),
  )
  |> inertia.always_prop(props.about_csrf_token("abc123xyz"))
  |> inertia.prop(props.about_page_title("About Us"))
  |> inertia.prop(props.about_description("Learn more about our application"))
  |> inertia.render("About")
}

/// Demo page showcasing different prop inclusion strategies
fn demo_features_page(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> wisp.Response {
  // Create initial props for demonstration
  let initial_props =
    props.DemoFeaturesProps(
      auth: props.unauthenticated_user(),
      csrf_token: "",
      title: "",
      description: "",
      expensive_data: json.null(),
      performance_info: json.null(),
    )

  // Transform to typed context and demonstrate different inclusion strategies
  // Simulate expensive computation that should only run when needed
  let expensive_result = fn() {
    json.object([
      #("computed_at", json.string("2024-01-01T00:00:00Z")),
      #(
        "large_dataset",
        json.array(
          [
            json.string("This would be"),
            json.string("a large dataset"),
            json.string("that takes time"),
            json.string("to compute"),
          ],
          fn(x) { x },
        ),
      ),
      #(
        "database_stats",
        json.object([
          #("total_users", json.int(1000)),
          #("active_sessions", json.int(42)),
          #("cache_hit_rate", json.float(0.95)),
        ]),
      ),
    ])
  }

  let performance_info =
    json.object([
      #("request_time", json.string("2024-01-01T00:00:00Z")),
      #("render_mode", json.string("CSR")),
      #("props_included", json.string("default")),
    ])

  ctx
  |> inertia.set_props(initial_props, props.encode_demo_features_props)
  // ALWAYS props - included in all requests (initial + partial)
  |> inertia.always_prop(props.demo_auth(props.authenticated_user("demo_user")))
  |> inertia.always_prop(props.demo_csrf_token("abc123xyz"))
  // DEFAULT props - included in initial requests and when specifically requested
  |> inertia.prop(props.demo_title("Feature Demo: Prop Inclusion Strategies"))
  |> inertia.prop(props.demo_description(
    "This page demonstrates different prop inclusion behaviors. Check the network tab to see how partial requests include only the props they need.",
  ))
  |> inertia.prop(props.demo_performance_info(performance_info))
  // OPTIONAL props - only included when specifically requested in partial reloads
  |> inertia.optional_prop(props.demo_expensive_data(expensive_result))
  |> inertia.render("DemoFeatures")
}
