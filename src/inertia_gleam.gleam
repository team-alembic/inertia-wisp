import gleam/dict.{type Dict}
import gleam/json
import inertia_gleam/controller
import inertia_gleam/json as inertia_json
import inertia_gleam/middleware
import inertia_gleam/types
import wisp.{type Request, type Response}

// Re-export main types
pub type Config =
  types.Config

pub type Page =
  types.Page

pub type InertiaContext =
  controller.InertiaContext

// Configuration
pub fn default_config() -> Config {
  types.default_config()
}

pub fn config(version: String, ssr: Bool) -> Config {
  types.Config(version: version, ssr: ssr, always_props: dict.new())
}

// Middleware
pub fn inertia_middleware(
  req: Request,
  handler: fn(Request) -> Response,
) -> Response {
  middleware.inertia_middleware(req, handler)
}

// Controller functions
pub fn render_inertia(req: Request, component: String) -> Response {
  controller.render_inertia(req, component)
}

pub fn render_inertia_with_props(
  req: Request,
  component: String,
  props: Dict(String, json.Json),
) -> Response {
  controller.render_inertia_with_props(req, component, props)
}

// Context-based API for pipe-friendly prop assignment
pub fn context(req: Request) -> InertiaContext {
  controller.context(req)
}

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

pub fn assign_always_lazy_prop(
  ctx: InertiaContext,
  key: String,
  evaluator: fn() -> json.Json,
) -> InertiaContext {
  controller.assign_always_lazy_prop(ctx, key, evaluator)
}

pub fn render(ctx: InertiaContext, component: String) -> Response {
  controller.render(ctx, component)
}

pub fn is_inertia_request(req: Request) -> Bool {
  controller.is_inertia_request(req)
}

// Prop helpers
pub fn string_prop(value: String) -> json.Json {
  controller.string_prop(value)
}

pub fn int_prop(value: Int) -> json.Json {
  controller.int_prop(value)
}

pub fn bool_prop(value: Bool) -> json.Json {
  controller.bool_prop(value)
}

pub fn props_from_list(
  props: List(#(String, json.Json)),
) -> Dict(String, json.Json) {
  controller.props_from_list(props)
}

// JSON helpers for convenience
pub fn string_to_json(value: String) -> json.Json {
  inertia_json.string_to_json(value)
}

pub fn int_to_json(value: Int) -> json.Json {
  inertia_json.int_to_json(value)
}

pub fn bool_to_json(value: Bool) -> json.Json {
  inertia_json.bool_to_json(value)
}

pub fn string_list_to_json(values: List(String)) -> json.Json {
  inertia_json.string_list_to_json(values)
}

pub fn int_list_to_json(values: List(Int)) -> json.Json {
  inertia_json.int_list_to_json(values)
}
