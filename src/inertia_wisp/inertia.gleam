//// Inertia.js adapter for the Gleam Wisp web framework.
////
//// This library provides a server-side adapter for Inertia.js, allowing you to build
//// modern single-page applications using Gleam and your favorite frontend framework.
////
//// ## Quick Start
////
//// 1. Set up your Inertia configuration:
////
//// ```gleam
//// import inertia_wisp/inertia
////
//// let config = inertia.config(
////   version: "1.0.0",
////   ssr: False,
////   encrypt_history: False
//// )
//// ```
////
//// 2. Use the middleware in your request handler:
////
//// ```gleam
//// import wisp
//// import inertia_wisp/inertia
////
//// pub fn handle_request(req: wisp.Request) -> wisp.Response {
////   use ctx <- inertia.middleware(req, config, option.None)
////
////   case wisp.path_segments(req) {
////     [] -> home_page(ctx)
////     ["users"] -> users_page(ctx)
////     _ -> wisp.not_found()
////   }
//// }
//// ```
////
//// 3. Define your page props type and to_json function:
////
//// ```gleam
//// pub type User {
////   User(name: String, email: String)
//// }
////
//// pub type HomePageProps {
////   HomePageProps(title: String, user: User)
//// }
////
//// fn title_prop(title: String) { #("title", fn(p){ HomePageProps(..p, title: title) }) }
//// fn user_prop(user: User) { #("user", fn(p){ HomePageProps(..p, user: user) }) }
////
//// pub const init_home_page_props = HomePageProps(title: "", user: User(name: "", email: ""))
////
//// pub fn home_page_props_to_json(props: HomePageProps) -> json.Json {
////   json.object([
////     #("title", json.string(props.title)),
////     #("user", json.object([
////       #("name", json.string(props.user.name)),
////       #("email", json.string(props.user.email))
////     ]))
////   ])
//// }
//// ```
////
//// 4. Create Inertia responses in your route handlers:
////
//// ```gleam
//// fn home_page(ctx: inertia.InertiaContext(inertia.EmptyProps)) -> wisp.Response {
////   ctx
////   |> inertia.set_props(init_home_page_props, home_page_props_to_json)
////   |> inertia.assign_prop_t(title_prop("Welcome"))
////   |> inertia.assign_prop_t(user_prop(User(name: "John", email: "john@example.com"))
////   |> inertia.render("Home")
//// }
//// ```
////
//// ## Server-Side Rendering (SSR)
////
//// To enable SSR, you'll need to set up an SSR supervisor:
////
//// ```gleam
//// import inertia_wisp/inertia
////
//// let ssr_config = inertia.ssr_config(
////   enabled: True,
////   path: "./static/js",
////   module: "ssr",
////   pool_size: 2,
////   timeout_ms: 5000,
////   supervisor_name: "InertiaSSR",
//// )
////
//// let assert Ok(ssr_supervisor) = inertia.start_ssr_supervisor(ssr_config)
////
//// // Use the supervisor in your middleware
//// inertia.middleware(req, config, option.Some(ssr_supervisor), handler)
//// ```

import gleam/dict
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/json
import gleam/option
import inertia_wisp/internal/controller
import inertia_wisp/internal/middleware
import inertia_wisp/internal/ssr
import inertia_wisp/internal/types

import wisp.{type Request, type Response}

// Re-export main types

/// Configuration for the Inertia adapter.
pub type Config =
  types.Config

/// The context object passed to route handlers, containing request data and configuration.
pub type InertiaContext(props) =
  types.InertiaContext(props)

/// Configuration for server-side rendering.
pub type SSRConfig =
  types.SSRConfig

/// Empty props type for middleware-before-routing pattern.
/// This allows middleware to create a context without knowing the specific prop types
/// that will be used by individual route handlers.
pub type EmptyProps =
  types.EmptyProps

// New typed context functions

/// Creates a new typed context with statically typed props.
/// Creates a new context for building up props with type safety.
///
/// This creates a context that enforces type safety for props at compile time.
/// You provide an initial props object and an encoder function that converts
/// the props to JSON.
///
/// ## Example
///
/// ```gleam
/// type UserPageProps {
///   UserPageProps(name: String, email: String, id: Int)
/// }
///
/// fn encode_user_props(props: UserPageProps) -> json.Json {
///   json.object([
///     #("name", json.string(props.name)),
///     #("email", json.string(props.email)),
///     #("id", json.int(props.id)),
///   ])
/// }
///
/// let ctx = inertia.new_context(
///   config,
///   request,
///   UserPageProps(name: "", email: "", id: 0),  // Initial/zero value
///   encode_user_props
/// )
/// ```
pub fn new_context(
  config: Config,
  request: Request,
  props_zero: props,
  props_encoder: fn(props) -> json.Json,
) -> InertiaContext(props) {
  types.new_context(config, request, props_zero, props_encoder)
}

/// Creates an empty context for middleware-before-routing pattern.
/// Returns an InertiaContext(EmptyProps) that can be transformed to specific prop types
/// using `set_props()` in individual route handlers.
///
/// ## Example
///
/// ```gleam
/// // In middleware (before routing)
/// let empty_ctx = inertia.empty_context(config, request)
///
/// // In route handler
/// let typed_ctx = empty_ctx |> inertia.set_props(HomeProps(...))
/// ```
pub fn empty_context(
  config: Config,
  request: Request,
) -> InertiaContext(types.EmptyProps) {
  types.new_context(config, request, types.EmptyProps, types.encode_empty_props)
}

/// Transforms an InertiaContext(EmptyProps) to InertiaContext(SpecificProps).
/// This allows the middleware-before-routing pattern while maintaining type safety.
///
/// ## Example
///
/// ```gleam
/// fn home_page(ctx: InertiaContext(EmptyProps)) -> Response {
///   let home_props = HomeProps(title: "", user_count: 0)
///
///   ctx
///   |> inertia.set_props(home_props, encode_home_props)
///   |> inertia.assign_prop("title", fn(props) { HomeProps(..props, title: "Welcome") })
///   |> inertia.render("Home")
/// }
/// ```
pub fn set_props(
  ctx: InertiaContext(types.EmptyProps),
  props_zero: props,
  props_encoder: fn(props) -> json.Json,
) -> InertiaContext(props) {
  types.InertiaContext(
    config: ctx.config,
    request: ctx.request,
    prop_transforms: [],
    props_encoder: props_encoder,
    props_zero: props_zero,
    errors: ctx.errors,
    encrypt_history: ctx.encrypt_history,
    clear_history: ctx.clear_history,
    ssr_supervisor: ctx.ssr_supervisor,
  )
}

/// Assigns a prop transformation to a typed context.
fn assign_prop_with_include(
  ctx: InertiaContext(props),
  key: String,
  transformer: fn(props) -> props,
  include: types.IncludeProp,
) -> InertiaContext(props) {
  let prop_transform =
    types.PropTransform(name: key, transform: transformer, include: include)
  types.InertiaContext(..ctx, prop_transforms: [
    prop_transform,
    ..ctx.prop_transforms
  ])
}

/// Assign a prop with default inclusion behavior.
/// The prop will be included in initial renders and when specifically requested in partial reloads.
///
/// ## Examples
///
/// ```gleam
/// ctx
/// |> inertia.assign_prop("name", UserPageProps(_, name: "Alice"))
/// |> inertia.assign_prop("id", UserPageProps(_, id: 42))
/// ```
pub fn assign_prop(
  ctx: InertiaContext(props),
  key: String,
  transformer: fn(props) -> props,
) -> InertiaContext(props) {
  assign_prop_with_include(ctx, key, transformer, types.IncludeDefault)
}

/// Assign a prop that is always included in renders.
/// The prop will be included in both initial renders and all partial reloads.
///
/// ## Examples
///
/// ```gleam
/// ctx
/// |> inertia.assign_always_prop("csrf_token", UserPageProps(_, csrf_token: token))
/// |> inertia.assign_always_prop("user", UserPageProps(_, user: current_user))
/// ```
pub fn assign_always_prop(
  ctx: InertiaContext(props),
  key: String,
  transformer: fn(props) -> props,
) -> InertiaContext(props) {
  assign_prop_with_include(ctx, key, transformer, types.IncludeAlways)
}

/// Assign a prop that is only included when specifically requested.
/// The prop will be excluded from initial renders and only included in partial reloads
/// when explicitly requested via the X-Inertia-Partial-Data header.
///
/// ## Examples
///
/// ```gleam
/// ctx
/// |> inertia.assign_optional_prop("expensive_data", UserPageProps(_, expensive_data: compute_expensive_data()))
/// |> inertia.assign_optional_prop("debug_info", UserPageProps(_, debug_info: get_debug_info()))
/// ```
pub fn assign_optional_prop(
  ctx: InertiaContext(props),
  key: String,
  transformer: fn(props) -> props,
) -> InertiaContext(props) {
  assign_prop_with_include(ctx, key, transformer, types.IncludeOptionally)
}

pub fn assign_prop_t(ctx: InertiaContext(t), name_and_fn: #(String, fn(t) -> t)) {
  let #(name, func) = name_and_fn
  assign_prop(ctx, name, func)
}

/// Assigns validation errors to be displayed in forms.
///
/// Errors are automatically included in responses and cleared after successful requests.
/// The errors should be provided as a Dict(String, String) where keys are field names
/// and values are error messages.
///
/// ## Example
///
/// ```gleam
/// import gleam/dict
///
/// let errors = dict.from_list([
///   #("email", "Email is required"),
///   #("password", "Password must be at least 8 characters"),
/// ])
///
/// ctx |> inertia.assign_errors(errors)
/// ```
pub fn assign_errors(
  ctx: InertiaContext(props),
  errors: dict.Dict(String, String),
) -> InertiaContext(props) {
  types.InertiaContext(..ctx, errors: errors)
}

/// Messages sent to the SSR supervisor.
pub type SSRMessage =
  types.SSRMessage

/// Result type for SSR operations.
pub type SSRResult =
  types.SSRResult

/// Response from SSR rendering.
pub type SSRResponse =
  types.SSRResponse

/// Error types for SSR operations.
pub type SSRError =
  types.SSRError

/// Status of SSR operations.
pub type SSRStatus =
  types.SSRStatus

// Configuration

/// Returns the default Inertia configuration.
///
/// ## Example
///
/// ```gleam
/// let config = inertia.default_config()
/// // Config(version: "1", ssr: False, encrypt_history: False)
/// ```
pub fn default_config() -> Config {
  types.Config(version: "1", ssr: False, encrypt_history: False)
}

// Middleware

/// Middleware for typed Inertia contexts with version checking and SSR support.
///
/// This middleware handles version checking, SSR setup, and proper response headers
/// for the typed prop system.
///
/// ## Parameters
///
/// - `req`: The incoming Wisp request
/// - `config`: Your Inertia configuration
/// - `ssr_supervisor`: Optional SSR supervisor for server-side rendering
/// - `props_zero`: Initial/zero value for your props type
/// - `props_encoder`: Function to encode your props to JSON
/// - `handler`: Your route handler function that receives a typed InertiaContext
///
/// ## Example
///
/// ```gleam
/// import wisp
/// import inertia_wisp/inertia
///
/// type HomeProps {
///   HomeProps(title: String, count: Int)
/// }
///
/// fn encode_home_props(props: HomeProps) -> json.Json {
///   json.object([
///     #("title", json.string(props.title)),
///     #("count", json.int(props.count)),
///   ])
/// }
///
/// pub fn handle_request(req: wisp.Request) -> wisp.Response {
///   let config = inertia.config(
///     version: "1.0.0",
///     ssr: False,
///     encrypt_history: False
///   )
///
///   use ctx <- inertia.middleware(req, config, option.None)
///
///   case wisp.path_segments(req) {
///     [] -> home_page(ctx)
///     ["about"] -> about_page(ctx)
///     _ -> wisp.not_found()
///   }
/// }
/// ```
/// Inertia middleware for the elegant middleware-before-routing pattern.
/// Creates an InertiaContext(EmptyProps) and passes it to your handler.
/// Use set_props() in your route handlers to assign typed props.
///
/// ## Example
///
/// ```gleam
/// pub fn handle_request(req: wisp.Request) -> wisp.Response {
///   use ctx <- inertia.middleware(req, config, ssr_supervisor)
///
///   case wisp.path_segments(req) {
///     [] -> home_page(ctx)         // ctx |> set_props(HomeProps(...))
///     ["users"] -> users_page(ctx) // ctx |> set_props(UserProps(...))
///     _ -> wisp.not_found()
///   }
/// }
/// ```
pub fn middleware(
  req: Request,
  config: types.Config,
  ssr_supervisor: option.Option(process.Subject(types.SSRMessage)),
  handler: fn(InertiaContext(types.EmptyProps)) -> Response,
) -> Response {
  middleware.middleware(
    req,
    config,
    ssr_supervisor,
    types.EmptyProps,
    types.encode_empty_props,
    handler,
  )
}

/// Enables server-side rendering for the current context.
///
/// Use this if you want to selectively enable SSR for particular routes.
/// Disables server-side rendering for the current context.
/// Renders an Inertia response with the specified component.
///
/// This is the main function for returning Inertia responses. It will either
/// return a JSON response (for Inertia requests) or render the full HTML page
/// (for initial page loads).
/// Renders an Inertia response with the specified component.
///
/// This function works with the statically typed props system, evaluating
/// prop transformations based on whether it's a partial reload request.
///
/// ## Example
///
/// ```gleam
/// type UserPageProps {
///   UserPageProps(name: String, email: String, id: Int)
/// }
///
/// fn user_profile(ctx: inertia.InertiaContext(UserPageProps), user_id: Int) -> wisp.Response {
///   let user = get_user(user_id)
///
///   ctx
///   |> inertia.assign_prop("name", UserPageProps(_, name: user.name))
///   |> inertia.assign_prop("email", UserPageProps(_, email: user.email))
///   |> inertia.assign_prop("id", UserPageProps(_, id: user.id))
///   |> inertia.render("UserProfile")
/// }
/// ```
pub fn render(ctx: InertiaContext(props), component: String) -> Response {
  controller.render_typed(ctx, component)
}

/// Performs an Inertia-aware redirect to another URL within your application.
///
/// For Inertia requests, this returns a special redirect response that the
/// frontend will handle. For regular requests, it returns a standard HTTP redirect.
pub fn redirect(request: Request, to url: String) -> Response {
  controller.redirect(request, url)
}

/// Performs an external redirect that forces a full page reload.
///
/// Use this when redirecting to external sites or when you need to break out
/// of the Inertia request cycle.
///
/// ## Example
///
/// ```gleam
/// fn oauth_redirect() -> wisp.Response {
///   inertia.external_redirect(to: "https://github.com/login/oauth/authorize?...")
/// }
/// ```
pub fn external_redirect(to url: String) -> Response {
  controller.external_redirect(url)
}

/// A utility function for handling JSON request bodies with automatic decoding.
///
/// This function extracts JSON data from the request body, attempts to decode it
/// using the provided decoder, and either continues with the decoded value or
/// returns a bad request response on failure.
///
/// ## Example
///
/// ```gleam
/// import gleam/dynamic/decode
/// import inertia_wisp/inertia
///
/// pub fn create_user(ctx: inertia.InertiaContext(inertia.EmptyProps)) -> wisp.Response {
///   use user_data <- inertia.require_json(ctx, user_decoder())
///   // user_data is now the decoded user struct
///   // ... handle the user creation logic
/// }
/// ```
pub fn require_json(
  ctx: InertiaContext(props),
  decoder: decode.Decoder(a),
  cont: fn(a) -> Response,
) -> Response {
  use json_data <- wisp.require_json(ctx.request)
  let result = decode.run(json_data, decoder)
  case result {
    Ok(value) -> cont(value)
    Error(_) -> wisp.bad_request()
  }
}

// SSR functions

/// Starts an SSR supervisor process for server-side rendering.
///
/// The supervisor manages a pool of Node.js processes that handle SSR requests.
/// You typically call this once at application startup.
///
/// ## Example
///
/// ```gleam
/// import inertia_wisp/inertia
///
/// pub fn main() {
///   let ssr_config = inertia.ssr_config(
///     enabled: True,
///     path: "./ssr/server.js",
///     module: "default",
///     pool_size: 5,
///     timeout_ms: 5000,
///     supervisor_name: "inertia_ssr"
///   )
///
///   let ssr_supervisor = inertia.start_ssr_supervisor(ssr_config) |> option.from_result()
///
///   // Use ssr_supervisor in your middleware
///   your_app_handler(_, ssr_supervisor)
///   |> wisp_mist.handler("secret_key_change_me_in_production")
///   |> mist.new
///   |> mist.port(8000)
///   |> mist.start_http
///
///   process.sleep_forever()
/// }
/// ```
pub fn start_ssr_supervisor(
  ssr_config: SSRConfig,
) -> Result(process.Subject(SSRMessage), String) {
  ssr.start_supervisor(ssr_config)
}

/// Creates an Inertia configuration.
///
/// ## Parameters
///
/// - `version`: Asset version string used for keeping client and server code in sync. Change this when your assets change to trigger a full page load.
/// - `ssr`: Whether to enable server-side rendering globally.
/// - `encrypt_history`: Whether to encrypt history state by default.
///
/// ## Example
///
/// ```gleam
/// let config = inertia.config(
///   version: "1.2.3",
///   ssr: True,
///   encrypt_history: False
/// )
/// ```
pub fn config(
  version version: String,
  ssr ssr: Bool,
  encrypt_history encrypt_history: Bool,
) -> Config {
  types.Config(version: version, ssr: ssr, encrypt_history: encrypt_history)
}

/// Creates an SSR configuration for server-side rendering.
///
/// ## Parameters
///
/// - `enabled`: Whether SSR is enabled
/// - `path`: Path to your SSR JavaScript file
/// - `module`: The module export to use (usually "ssr")
/// - `pool_size`: Number of Node.js processes in the pool
/// - `timeout_ms`: Timeout for SSR requests in milliseconds
/// - `supervisor_name`: Name for the supervisor process
///
/// ## Example
///
/// ```gleam
/// let ssr_config = inertia.ssr_config(
///   enabled: True,
///   path: "./dist/ssr/server.js",
///   module: "default",
///   pool_size: 3,
///   timeout_ms: 3000,
///   supervisor_name: "my_app_ssr"
/// )
/// ```
pub fn ssr_config(
  enabled enabled: Bool,
  path path: String,
  module module: String,
  pool_size pool_size: Int,
  timeout_ms timeout_ms: Int,
  supervisor_name supervisor_name: String,
) -> SSRConfig {
  types.SSRConfig(
    enabled: enabled,
    path: path,
    module: module,
    pool_size: pool_size,
    timeout_ms: timeout_ms,
    supervisor_name: supervisor_name,
  )
}
