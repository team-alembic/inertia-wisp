import gleam/erlang/process
import gleam/http
import gleam/int
import gleam/json
import gleam/option
import handlers
import inertia_wisp/inertia
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
    |> mist.port(8001)
    |> mist.start_http

  wisp.log_info("Typed Demo server started on http://localhost:8001")
  process.sleep_forever()
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
) -> wisp.Response {
  use <- wisp.serve_static(req, from: "./static", under: "/static")
  use ctx <- inertia.middleware(req, inertia.default_config(), ssr_supervisor)
  
  case wisp.path_segments(req), req.method {
    [], http.Get -> home_page(ctx)
    ["user", user_id], http.Get -> handlers.user_profile_handler(ctx.request, ctx.config, parse_int(user_id))
    ["blog", post_id], http.Get -> handlers.blog_post_handler(ctx.request, ctx.config, parse_int(post_id))
    ["dashboard"], http.Get -> handlers.dashboard_handler(ctx.request, ctx.config)
    _, _ -> wisp.not_found()
  }
}

fn parse_int(s: String) -> Int {
  case int.parse(s) {
    Ok(i) -> i
    Error(_) -> 1
  }
}

fn home_page(ctx: inertia.InertiaContext) -> wisp.Response {
  ctx
  |> inertia.assign_prop("title", json.string("Typed Props Demo"))
  |> inertia.assign_prop("message", json.string("Welcome to the statically typed props demo!"))
  |> inertia.assign_prop("features", json.array([
    json.string("Compile-time type safety"),
    json.string("Shared Gleam/TypeScript types"),
    json.string("Transformation-based props"),
    json.string("Partial reload support")
  ], fn(x) { x }))
  |> inertia.render("Home")
}