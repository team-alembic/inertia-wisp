import gleam/erlang/process
import gleam/option

import auth/router as auth_router
import blog/router as blog_router
import contact/router as contact_router
import dashboard/router as dashboard_router
import home/router as home_router
import inertia_wisp/inertia
import mist
import users/router as users_router
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
    |> mist.start

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
  use ctx <- inertia.middleware(
    req,
    inertia.config(version: "1", ssr: True, encrypt_history: False),
    ssr_supervisor,
  )

  case wisp.path_segments(req) {
    [] -> home_router.home_router(ctx, req)

    // Delegate to feature routers by prefix
    ["auth", ..] -> {
      auth_router.auth_router(ctx, req)
    }

    ["users", ..] -> {
      users_router.users_router(ctx, req)
    }

    ["blog", ..] -> {
      blog_router.blog_router(ctx, req)
    }

    ["dashboard", ..] -> {
      dashboard_router.dashboard_router(ctx, req)
    }

    ["contact", ..] -> {
      contact_router.contact_router(ctx, req)
    }

    // Legacy routes for backward compatibility
    ["user", _user_id] -> {
      users_router.users_router(ctx, req)
    }

    ["login"] -> {
      auth_router.auth_router(ctx, req)
    }

    _ -> wisp.not_found()
  }
}
