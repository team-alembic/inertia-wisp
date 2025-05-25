import gleam/dict.{type Dict}
import gleam/json
import inertia_gleam/controller
import inertia_gleam/middleware
import inertia_gleam/types
import inertia_gleam/uploads
import wisp.{type Request, type Response}

// Re-export main types
pub type Config =
  types.Config

pub type Page =
  types.Page

pub type InertiaContext =
  controller.InertiaContext

pub type UploadedFile =
  uploads.UploadedFile

pub type UploadConfig =
  uploads.UploadConfig

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

pub fn redirect(req: Request, to url: String) -> Response {
  controller.redirect(req, url)
}

pub fn external_redirect(to url: String) -> Response {
  controller.external_redirect(url)
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

// File upload functions
pub fn assign_files(
  ctx: InertiaContext,
  config: UploadConfig,
) -> InertiaContext {
  controller.assign_files(ctx, config)
}

pub fn assign_files_default(ctx: InertiaContext) -> InertiaContext {
  controller.assign_files_default(ctx)
}

pub fn get_uploaded_files(
  req: Request,
  config: UploadConfig,
) -> Result(Dict(String, UploadedFile), Dict(String, String)) {
  controller.get_uploaded_files(req, config)
}

pub fn get_uploaded_files_default(
  req: Request,
) -> Result(Dict(String, UploadedFile), Dict(String, String)) {
  controller.get_uploaded_files_default(req)
}

pub fn upload_config(
  max_file_size max_size: Int,
  allowed_types types: List(String),
  max_files max: Int,
) -> UploadConfig {
  controller.upload_config(max_size, types, max)
}

pub fn default_upload_config() -> UploadConfig {
  uploads.default_upload_config()
}

pub fn file_to_json(file: UploadedFile) -> json.Json {
  controller.file_to_json(file)
}

pub fn files_to_json(files: Dict(String, UploadedFile)) -> json.Json {
  controller.files_to_json(files)
}
