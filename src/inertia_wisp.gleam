import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/json
import gleam/option
import inertia_wisp/controller
import inertia_wisp/middleware

import inertia_wisp/types

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
  ssr_supervisor: option.Option(process.Subject(types.SSRMessage)),
  handler: fn(InertiaContext) -> Response,
) -> Response {
  middleware.inertia_middleware(req, config, ssr_supervisor, handler)
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

// SSR Configuration
pub fn with_ssr_supervisor(
  ctx: InertiaContext,
  supervisor: Subject(types.SSRMessage),
) -> InertiaContext {
  types.InertiaContext(..ctx, ssr_supervisor: option.Some(supervisor))
}

pub fn enable_ssr(ctx: InertiaContext) -> InertiaContext {
  let new_config = types.Config(..ctx.config, ssr: True)
  types.InertiaContext(..ctx, config: new_config)
}

pub fn disable_ssr(ctx: InertiaContext) -> InertiaContext {
  let new_config = types.Config(..ctx.config, ssr: False)
  types.InertiaContext(..ctx, config: new_config)
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
