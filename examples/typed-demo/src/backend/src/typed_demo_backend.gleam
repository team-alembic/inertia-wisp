import gleam/erlang/process
import gleam/http
import gleam/int
import gleam/option
import form_handlers
import handlers
import inertia_wisp/inertia
import mist
import types.{HomePageProps, encode_home_page_props}
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
  use ctx <- inertia.empty_middleware(req, inertia.default_config(), ssr_supervisor)
  
  case wisp.path_segments(req), req.method {
    [], http.Get -> home_page(ctx)
    ["user", user_id], http.Get -> handlers.user_profile_handler(ctx, parse_int(user_id))
    ["blog", post_id], http.Get -> handlers.blog_post_handler(ctx, parse_int(post_id))
    ["dashboard"], http.Get -> handlers.dashboard_handler(ctx)
    
    // Form submission routes
    ["users"], http.Post -> form_handlers.create_user_handler(ctx, req)
    ["users", user_id], http.Put -> form_handlers.update_profile_handler(ctx, req, user_id)
    ["users", user_id], http.Patch -> form_handlers.update_profile_handler(ctx, req, user_id)
    ["login"], http.Post -> form_handlers.login_handler(ctx, req)
    ["contact"], http.Post -> form_handlers.contact_form_handler(ctx, req)
    
    // Form page routes (GET)
    ["users", "create"], http.Get -> handlers.create_user_page_handler(ctx)
    ["users", user_id, "edit"], http.Get -> handlers.edit_profile_page_handler(ctx, user_id)
    ["login"], http.Get -> handlers.login_page_handler(ctx)
    ["contact"], http.Get -> handlers.contact_page_handler(ctx)
    
    _, _ -> wisp.not_found()
  }
}

fn parse_int(s: String) -> Int {
  case int.parse(s) {
    Ok(i) -> i
    Error(_) -> 1
  }
}

fn home_page(ctx: inertia.InertiaContext(inertia.EmptyProps)) -> wisp.Response {
  let typed_ctx = ctx
    |> inertia.set_props(
      HomePageProps("", "", []), // zero value
      encode_home_page_props,
    )

  typed_ctx
  // Always included - essential app info that should always be available
  |> inertia.assign_always_prop("title", fn(props) { HomePageProps(..props, title: "Typed Props Demo") })
  // Default inclusion - main content included in initial load and when requested
  |> inertia.assign_prop("message", fn(props) { HomePageProps(..props, message: "Welcome to the statically typed props demo!") })
  // Default inclusion - features list is core content for home page
  |> inertia.assign_prop("features", fn(props) { HomePageProps(..props, features: [
    "🔒 Compile-time type safety across full stack",
    "📝 Shared Gleam/TypeScript types with single source of truth",
    "🔄 Transformation-based props with immutable updates", 
    "⚡ Partial reload support with selective prop loading",
    "🎯 Zero runtime overhead - all type checking at compile time",
    "🛡️ Prevents runtime errors from type mismatches"
  ]) })
  |> inertia.render("Home")
}