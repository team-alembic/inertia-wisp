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
////   use ctx <- inertia.inertia_middleware(req, config, option.None)
////
////   case wisp.path_segments(req) {
////     [] -> home_page(ctx)
////     ["users"] -> users_page(ctx)
////     _ -> wisp.not_found()
////   }
//// }
//// ```
////
//// 3. Create Inertia responses in your route handlers:
////
//// ```gleam
//// fn home_page(ctx: inertia.InertiaContext) -> wisp.Response {
////   ctx
////   |> inertia.assign_prop("title", json.string("Welcome"))
////   |> inertia.assign_prop("user", json.object([
////     #("name", json.string("John")),
////     #("email", json.string("john@example.com"))
////   ]))
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
//// inertia.inertia_middleware(req, config, option.Some(ssr_supervisor), handler)
//// ```

import gleam/dict.{type Dict}
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
pub type InertiaContext =
  types.InertiaContext

/// Configuration for server-side rendering.
pub type SSRConfig =
  types.SSRConfig

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

/// Updates the configuration in an InertiaContext.
///
/// ## Example
///
/// ```gleam
/// let new_config = inertia.config(
///   version: "2.0.0",
///   ssr: True,
///   encrypt_history: True
/// )
///
/// let updated_ctx = inertia.set_config(ctx, new_config)
/// ```
pub fn set_config(context: types.InertiaContext, config: Config) {
  types.InertiaContext(..context, config: config)
}

// Middleware

/// The main Inertia middleware that processes requests and creates the InertiaContext.
///
/// This middleware handles:
/// - Detecting Inertia requests vs. regular page requests
/// - Processing asset version checking
/// - Setting up the context for your handlers
///
/// ## Parameters
///
/// - `req`: The incoming Wisp request
/// - `config`: Your Inertia configuration
/// - `ssr_supervisor`: Optional SSR supervisor for server-side rendering
/// - `handler`: Your route handler function that receives an InertiaContext
///
/// ## Example
///
/// ```gleam
/// import wisp
/// import inertia_wisp/inertia
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
pub fn middleware(
  req: Request,
  config: types.Config,
  ssr_supervisor: option.Option(process.Subject(types.SSRMessage)),
  handler: fn(InertiaContext) -> Response,
) -> Response {
  middleware.inertia_middleware(req, config, ssr_supervisor, handler)
}

// Controller functions

/// Assigns a regular prop that will be included in initial requests by default.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.assign_prop("title", json.string("Home Page"))
/// |> inertia.assign_prop("count", json.int(42))
/// ```
pub fn assign_prop(
  ctx: InertiaContext,
  key: String,
  value: json.Json,
) -> InertiaContext {
  controller.assign_prop(ctx, key, value)
}

/// Assigns multiple regular props at once.
///
/// ## Example
///
/// ```gleam
/// let props = [
///   #("title", json.string("User Profile")),
///   #("user_id", json.int(123)),
///   #("is_admin", json.bool(False))
/// ]
///
/// ctx |> inertia.assign_props(props)
/// ```
pub fn assign_props(
  ctx: InertiaContext,
  props: List(#(String, json.Json)),
) -> InertiaContext {
  controller.assign_props(ctx, props)
}

/// Assigns a lazy prop that is included in initial requests and only evaluated when request for partial reloads.
///
/// Lazy props are useful for expensive computations that shouldn't run on every request.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.assign_lazy_prop("expensive_data", fn() {
///   // This only runs if the prop is specifically requested in a reload
///   expensive_database_query()
///   |> json.array(json.string)
/// })
/// ```
pub fn assign_lazy_prop(
  ctx: InertiaContext,
  key: String,
  evaluator: fn() -> json.Json,
) -> InertiaContext {
  controller.assign_lazy_prop(ctx, key, evaluator)
}

/// Assigns an "always" prop that is included in every response, even partial reloads.
///
/// Use this for data that should always be available, like current user info or CSRF tokens.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.assign_always_prop("user", json.object([
///   #("id", json.int(user.id)),
///   #("name", json.string(user.name))
/// ]))
/// |> inertia.assign_always_prop("csrf_token", json.string(csrf_token))
/// ```
pub fn assign_always_prop(
  ctx: InertiaContext,
  key: String,
  value: json.Json,
) -> InertiaContext {
  controller.assign_always_prop(ctx, key, value)
}

/// Assigns multiple "always" props at once.
///
/// ## Example
///
/// ```gleam
/// let always_props = [
///   #("csrf_token", json.string(token)),
///   #("app_name", json.string("My App")),
///   #("version", json.string("1.0.0"))
/// ]
///
/// ctx |> inertia.assign_always_props(always_props)
/// ```
pub fn assign_always_props(
  ctx: InertiaContext,
  props: List(#(String, json.Json)),
) -> InertiaContext {
  controller.assign_always_props(ctx, props)
}

/// Assigns an "optional" prop that is only included when specifically requested.
///
/// Optional props are never included unless the frontend explicitly asks for them.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.assign_optional_prop("debug_info", json.object([
///   #("query_count", json.int(db_query_count)),
///   #("render_time", json.float(render_time_ms))
/// ]))
/// ```
pub fn assign_optional_prop(
  ctx: InertiaContext,
  key: String,
  value: json.Json,
) -> InertiaContext {
  controller.assign_optional_prop(ctx, key, value)
}

/// Assigns an "optional lazy" prop that is only evaluated when explicitly requested.
///
/// Combines the benefits of both lazy and optional props.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.assign_optional_lazy_prop("admin_stats", fn() {
///   // Only runs if specifically requested by the frontend
///   generate_admin_statistics()
///   |> json.object()
/// })
/// ```
pub fn assign_optional_lazy_prop(
  ctx: InertiaContext,
  key: String,
  evaluator: fn() -> json.Json,
) -> InertiaContext {
  controller.assign_optional_lazy_prop(ctx, key, evaluator)
}

/// Assigns an "always lazy" prop that is included in every response but only evaluated when needed.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.assign_always_lazy_prop("notifications", fn() {
///   get_user_notifications(user.id)
///   |> list.map(notification_to_json)
///   |> json.array(fn(x) { x })
/// })
/// ```
pub fn assign_always_lazy_prop(
  ctx: InertiaContext,
  key: String,
  evaluator: fn() -> json.Json,
) -> InertiaContext {
  controller.assign_always_lazy_prop(ctx, key, evaluator)
}

// Form handling and redirects

/// Assigns validation errors to be displayed in forms.
///
/// Errors are automatically included in responses and cleared after successful requests.
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
  ctx: InertiaContext,
  errors: Dict(String, String),
) -> InertiaContext {
  controller.assign_errors(ctx, errors)
}

/// Assigns a single validation error for a specific field.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.assign_error("username", "Username is already taken")
/// |> inertia.assign_error("email", "Invalid email format")
/// ```
pub fn assign_error(
  ctx: InertiaContext,
  field: String,
  message: String,
) -> InertiaContext {
  controller.assign_error(ctx, field, message)
}

/// Enables history encryption for the current response.
///
/// When enabled, the page data will be encrypted in the browser's history.
/// The key is stored in browser session storage, and can be cleared with the clear_history call.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.assign_prop("delivery_address", json.string("24 Evergreen Tce"))
/// |> inertia.encrypt_history()
/// |> inertia.render("PaymentForm")
/// ```
pub fn encrypt_history(ctx: InertiaContext) -> InertiaContext {
  controller.encrypt_history(ctx)
}

/// Clears the browser's history state encryption key.
///
/// Once cleared, previous history state will no longer be accessible.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.clear_history()
/// |> inertia.redirect("/logged-out")
/// ```
pub fn clear_history(ctx: InertiaContext) -> InertiaContext {
  controller.clear_history(ctx)
}

// SSR Configuration

/// Enables server-side rendering for the current context.
///
/// Use this if you want to selectively enable SSR for particular routes.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.enable_ssr()
/// |> inertia.render("HomePage")  // Will be server-side rendered
/// ```
pub fn enable_ssr(ctx: InertiaContext) -> InertiaContext {
  let new_config = types.Config(..ctx.config, ssr: True)
  types.InertiaContext(..ctx, config: new_config)
}

/// Disables server-side rendering for the current context.
///
/// ## Example
///
/// ```gleam
/// ctx
/// |> inertia.disable_ssr()
/// |> inertia.render("ClientOnlyPage")  // Will only render on client
/// ```
pub fn disable_ssr(ctx: InertiaContext) -> InertiaContext {
  let new_config = types.Config(..ctx.config, ssr: False)
  types.InertiaContext(..ctx, config: new_config)
}

/// Renders an Inertia response with the specified component.
///
/// This is the main function for returning Inertia responses. It will either
/// return a JSON response (for Inertia requests) or render the full HTML page
/// (for initial page loads).
///
/// ## Example
///
/// ```gleam
/// fn user_profile(ctx: inertia.InertiaContext, user_id: Int) -> wisp.Response {
///   let user = get_user(user_id)
///
///   ctx
///   |> inertia.assign_prop("user", user_to_json(user))
///   |> inertia.assign_prop("title", json.string("User Profile"))
///   |> inertia.render("UserProfile")
/// }
/// ```
pub fn render(ctx: InertiaContext, component: String) -> Response {
  controller.render(ctx, component)
}

/// Performs an Inertia-aware redirect to another URL within your application.
///
/// For Inertia requests, this returns a special redirect response that the
/// frontend will handle. For regular requests, it returns a standard HTTP redirect.
///
/// ## Example
///
/// ```gleam
/// fn create_user(ctx: inertia.InertiaContext) -> wisp.Response {
///   case validate_and_create_user(ctx.request) {
///     Ok(user) -> inertia.redirect(ctx, to: "/users/" <> int.to_string(user.id))
///     Error(errors) -> {
///       ctx
///       |> inertia.assign_errors(errors)
///       |> inertia.render("CreateUser")
///     }
///   }
/// }
/// ```
pub fn redirect(ctx: InertiaContext, to url: String) -> Response {
  controller.redirect(ctx.request, url)
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
