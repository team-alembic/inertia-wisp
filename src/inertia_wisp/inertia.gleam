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
//// 3. Define your page props as a union type and encoder function:
////
//// ```gleam
//// pub type HomePageProp {
////   Title(title: String)
////   User(user: String)
////   Count(count: Int)
//// }
////
//// fn encode_home_page_prop(prop: HomePageProp) -> json.Json {
////   case prop {
////     Title(title) -> json.string(title)
////     User(user) -> json.string(user)
////     Count(count) -> json.int(count)
////   }
//// }
//// ```
////
//// 4. Create Inertia responses in your route handlers:
////
//// ```gleam
//// fn home_page(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
////   ctx
////   |> inertia.with_encoder(encode_home_page_prop)
////   |> inertia.prop("title", Title("Welcome"))
////   |> inertia.prop("user", User("John"))
////   |> inertia.prop("count", Count(42))
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
////   path: "./static/js/ssr.js",
////   module: "render",
////   pool_size: 4,
////   timeout_ms: 5000,
////   supervisor_name: "InertiaSSR",
//// )
////
//// let assert Ok(ssr_supervisor) = inertia.start_ssr_supervisor(ssr_config)
////
//// // Use the supervisor in your middleware
//// use ctx <- inertia.middleware(req, config, option.Some(ssr_supervisor))
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

/// Converts an InertiaContext(Nil) to a typed InertiaContext(prop) with a prop encoder.
///
/// This function is essential for the typed props system. It takes a context from
/// the middleware (which has type Nil) and converts it to work with your specific
/// prop type, providing the encoder function that will serialize your props to JSON.
///
/// ## Example
///
/// ```gleam
/// pub type HomePageProp {
///   Title(title: String)
///   Message(message: String)
/// }
///
/// fn encode_home_page_prop(prop: HomePageProp) -> json.Json {
///   case prop {
///     Title(title) -> json.string(title)
///     Message(message) -> json.string(message)
///   }
/// }
///
/// fn home_page(ctx: InertiaContext(Nil)) -> wisp.Response {
///   ctx
///   |> inertia.with_encoder(encode_home_page_prop)
///   |> inertia.prop("title", Title("Welcome"))
///   |> inertia.prop("message", Message("Hello World!"))
///   |> inertia.render("Home")
/// }
/// ```
pub fn with_encoder(
  ctx: types.InertiaContext(Nil),
  encoder: fn(prop) -> json.Json,
) -> InertiaContext(prop) {
  types.InertiaContext(
    config: ctx.config,
    request: ctx.request,
    props: dict.new(),
    prop_encoder: encoder,
    errors: ctx.errors,
    encrypt_history: ctx.encrypt_history,
    clear_history: ctx.clear_history,
    ssr_supervisor: ctx.ssr_supervisor,
  )
}

/// Assign a prop with default inclusion behavior.
/// The prop will be included in initial renders and partial reloads unless
/// specifically excluded via the X-Inertia-Partial-Data header.
///
/// ## Example
///
/// ```gleam
/// pub type HomePageProp {
///   Title(title: String)
///   Message(message: String)
/// }
///
/// ctx
/// |> inertia.prop("title", Title("Welcome"))
/// |> inertia.prop("message", Message("Hello!"))
/// ```
pub fn prop(ctx: InertiaContext(p), key: String, prop: p) {
  types.InertiaContext(
    ..ctx,
    props: dict.insert(
      ctx.props,
      key,
      types.Prop(fn() { prop }, types.IncludeDefault),
    ),
  )
}

/// Assign a prop that is always included in renders.
/// The prop will be included in both initial renders and all partial reloads.
///
/// ## Examples
///
/// ```gleam
/// ctx
/// |> inertia.always_prop("auth", current_user)
/// ```
pub fn always_prop(ctx: InertiaContext(t), key: String, prop: t) {
  types.InertiaContext(
    ..ctx,
    props: dict.insert(
      ctx.props,
      key,
      types.Prop(fn() { prop }, types.IncludeAlways),
    ),
  )
}

/// Assign a prop that is only included when specifically requested.
/// The prop will be excluded from initial renders and only included in partial reloads
/// when explicitly requested via the X-Inertia-Partial-Data header.
///
/// ## Examples
///
/// ```gleam
/// ctx
/// |> inertia.optional_prop("expensive_data", fn() { compute_expensive_data() })
/// |> inertia.optional_prop("debug_info", fn() { get_debug_info() })
/// ```
pub fn optional_prop(ctx: InertiaContext(t), key: String, func: fn() -> t) {
  types.InertiaContext(
    ..ctx,
    props: dict.insert(
      ctx.props,
      key,
      types.Prop(func, types.IncludeOptionally),
    ),
  )
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
/// ctx |> inertia.errors(errors)
/// ```
pub fn errors(
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
/// Inertia middleware for handling requests with the Inertia protocol.
/// Creates an InertiaContext(Nil) and passes it to your handler.
/// Use with_encoder() and prop functions in your route handlers to assign typed props.
///
/// ## Example
///
/// ```gleam
/// pub fn handle_request(req: wisp.Request) -> wisp.Response {
///   use ctx <- inertia.middleware(req, config, option.None)
///
///   case wisp.path_segments(req) {
///     [] -> home_page(ctx)     // ctx |> with_encoder(...) |> prop(...)
///     ["users"] -> users_page(ctx)
///     _ -> wisp.not_found()
///   }
/// }
/// ```
pub fn middleware(
  req: Request,
  config: types.Config,
  ssr_supervisor: option.Option(process.Subject(types.SSRMessage)),
  handler: fn(InertiaContext(Nil)) -> Response,
) -> Response {
  middleware.middleware(req, config, ssr_supervisor, handler)
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
///
/// ## Example
///
/// ```gleam
/// pub type UserPageProp {
///   Name(name: String)
///   Email(email: String)
///   Id(id: Int)
/// }
///
/// fn user_profile(ctx: inertia.InertiaContext(Nil), user_id: Int) -> wisp.Response {
///   let user = get_user(user_id)
///
///   ctx
///   |> inertia.with_encoder(encode_user_page_prop)
///   |> inertia.prop("name", Name(user.name))
///   |> inertia.prop("email", Email(user.email))
///   |> inertia.prop("id", Id(user.id))
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
/// pub fn create_user(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
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
///     path: "./static/js/ssr.js",
///     module: "render",
///     pool_size: 4,
///     timeout_ms: 5000,
///     supervisor_name: "InertiaSSR"
///   )
///
///   let ssr_supervisor = case inertia.start_ssr_supervisor(ssr_config) {
///     Ok(supervisor) -> option.Some(supervisor)
///     Error(_) -> option.None
///   }
///
///   // Use ssr_supervisor in your middleware
///   fn(req) { handle_request(req, ssr_supervisor) }
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
///   path: "./static/js/ssr.js",
///   module: "render",
///   pool_size: 4,
///   timeout_ms: 5000,
///   supervisor_name: "InertiaSSR"
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
