import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/erlang/process.{type Subject}
import gleam/json
import gleam/option.{type Option}
import wisp

/// Represents an Inertia.js page object
/// Page data to be sent to the client
pub type Page {
  Page(
    component: String,
    props: Dict(String, json.Json),
    url: String,
    version: String,
    encrypt_history: Bool,
    clear_history: Bool,
  )
}

/// Encode a Page object to JSON
pub fn encode_page(page: Page) -> json.Json {
  json.object([
    #("component", json.string(page.component)),
    #("props", json.object(dict.to_list(page.props))),
    #("url", json.string(page.url)),
    #("version", json.string(page.version)),
    #("encryptHistory", json.bool(page.encrypt_history)),
    #("clearHistory", json.bool(page.clear_history)),
  ])
}

/// Prop value that can be either eager or lazy
pub type PropValue {
  EagerProp(value: json.Json)
  LazyProp(evaluate: fn() -> json.Json)
}

/// Configuration for the Inertia adapter
pub type Config {
  Config(
    version: String,
    ssr: Bool,
    always_props: Dict(String, PropValue),
    encrypt_history: Bool,
  )
}

/// Default configuration
pub fn default_config() -> Config {
  Config(
    version: "1",
    ssr: False,
    always_props: dict.new(),
    encrypt_history: False,
  )
}

/// Context wrapper for building up props before rendering
pub type InertiaContext {
  InertiaContext(
    config: Config,
    request: wisp.Request,
    props: Dict(String, PropValue),
    always_props: Dict(String, PropValue),
    encrypt_history: Bool,
    clear_history: Bool,
    ssr_supervisor: Option(Subject(SSRMessage)),
  )
}

pub fn new_context(config, request) {
  InertiaContext(
    config: config,
    request: request,
    props: dict.new(),
    always_props: dict.new(),
    encrypt_history: config.encrypt_history,
    clear_history: False,
    ssr_supervisor: option.None,
  )
}

/// SSR response from Node.js
pub type SSRResponse {
  SSRResponse(head: List(String), body: String)
}

/// Result of an SSR rendering attempt
pub type SSRResult {
  /// SSR succeeded and returned rendered content
  SSRSuccess(response: SSRResponse)
  /// SSR failed but should fallback to CSR gracefully
  SSRFallback(reason: String)
  /// SSR failed with an error that should be raised
  SSRError(error: String)
}

/// Messages that the SSR supervisor can handle
pub type SSRMessage {
  StartNodeJS(reply_with: Subject(Result(Nil, SSRError)))
  StopNodeJS(reply_with: Subject(Result(Nil, SSRError)))
  GetStatus(reply_with: Subject(SSRStatus))
  UpdateConfig(SSRConfig, reply_with: Subject(Result(Nil, SSRError)))
  RenderPage(
    dynamic.Dynamic,
    String,
    reply_with: Subject(Result(SSRResponse, SSRError)),
  )
}

/// Current status of the SSR system
pub type SSRStatus {
  SSRStatus(enabled: Bool, supervisor_running: Bool, config: SSRConfig)
}

/// SSR supervisor errors
pub type SSRError {
  SupervisorNotStarted
  NodeJSStartFailed(String)
  NodeJSStopFailed(String)
  ConfigurationError(String)
  RenderError(String)
}

/// SSR configuration settings
pub type SSRConfig {
  SSRConfig(
    /// Whether SSR is enabled globally
    enabled: Bool,
    /// Path to directory containing the ssr.js file
    path: String,
    /// Name of the Node.js module (without .js extension)
    module: String,
    /// Number of Node.js worker processes in the pool
    pool_size: Int,
    /// Timeout for SSR renders in milliseconds
    timeout_ms: Int,
    /// Whether to raise exceptions on SSR failure or fallback to CSR
    raise_on_failure: Bool,
    /// Name for the supervisor process
    supervisor_name: String,
  )
}
