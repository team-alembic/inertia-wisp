import gleam/dict.{type Dict}
import gleam/json
import inertia_gleam/controller
import inertia_gleam/middleware
import inertia_gleam/types

import wisp.{type Request, type Response}

// Re-export main types
pub type Config =
  types.Config

pub type InertiaContext =
  types.InertiaContext

// Configuration
pub fn default_config() -> Config {
  types.default_config()
}

pub fn set_config(context: types.InertiaContext, config: Config) {
  types.InertiaContext(..context, config: config)
}

// Middleware
pub fn inertia_middleware(
  req: Request,
  config: types.Config,
  handler: fn(InertiaContext) -> Response,
) -> Response {
  middleware.inertia_middleware(req, config, handler)
}

// Controller functions
pub fn assign_prop(
  ctx: InertiaContext,
  key: String,
  value: json.Json,
) -> InertiaContext {
  controller.assign_prop(ctx, key, value)
}

pub fn assign_props(
  ctx: InertiaContext,
  props: List(#(String, json.Json)),
) -> InertiaContext {
  controller.assign_props(ctx, props)
}

pub fn assign_lazy_prop(
  ctx: InertiaContext,
  key: String,
  evaluator: fn() -> json.Json,
) -> InertiaContext {
  controller.assign_lazy_prop(ctx, key, evaluator)
}

pub fn assign_always_prop(
  ctx: InertiaContext,
  key: String,
  value: json.Json,
) -> InertiaContext {
  controller.assign_always_prop(ctx, key, value)
}

pub fn assign_always_props(
  ctx: InertiaContext,
  props: List(#(String, json.Json)),
) -> InertiaContext {
  controller.assign_always_props(ctx, props)
}

// Form handling and redirects
pub fn assign_errors(
  ctx: InertiaContext,
  errors: Dict(String, String),
) -> InertiaContext {
  controller.assign_errors(ctx, errors)
}

pub fn assign_error(
  ctx: InertiaContext,
  field: String,
  message: String,
) -> InertiaContext {
  controller.assign_error(ctx, field, message)
}

pub fn encrypt_history(ctx: InertiaContext) -> InertiaContext {
  controller.encrypt_history(ctx)
}

pub fn clear_history(ctx: InertiaContext) -> InertiaContext {
  controller.clear_history(ctx)
}

pub fn render(ctx: InertiaContext, component: String) -> Response {
  controller.render(ctx, component)
}

pub fn redirect(ctx: InertiaContext, to url: String) -> Response {
  controller.redirect(ctx.request, url)
}

pub fn external_redirect(to url: String) -> Response {
  controller.external_redirect(url)
}
