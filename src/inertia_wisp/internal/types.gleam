//// @internal
////
//// Core type definitions for the Inertia.js Wisp adapter.
////
//// This module defines all the essential types used throughout the Inertia.js
//// implementation, including:
////
//// - Page objects that represent the data sent to frontend components
//// - Configuration types for both general settings and SSR
//// - Context types that carry request state through the application
//// - Prop management types for lazy evaluation and performance optimization
//// - SSR (Server-Side Rendering) message and response types
////
//// ## Core Types
////
//// - `Page`: The main data structure sent to frontend components
//// - `InertiaContext`: Request context with accumulated props and configuration
//// - `Config`: Application-wide Inertia configuration
//// - `SSRConfig`: Server-side rendering configuration
//// - `Prop` and `PropValue`: Type-safe prop management with lazy evaluation
////
//// ## Design Principles
////
//// These types are designed to:
//// - Maintain type safety throughout the request lifecycle
//// - Support lazy evaluation for performance optimization
//// - Enable clean separation between always props, regular props, and lazy props
//// - Provide a foundation for both JSON responses and SSR HTML generation

import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/erlang/process.{type Subject}
import gleam/json
import gleam/option.{type Option}
import wisp

/// Represents an Inertia.js page object that will be sent to the client.
///
/// This is the core data structure that contains all the information needed
/// to render a component on the frontend, including the component name,
/// props, URL, version info, and history management flags.
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

/// Prop inclusion behavior
pub type Prop {
  DefaultProp(PropValue)
  OptionalProp(PropValue)
  AlwaysProp(PropValue)
}

/// Prop evaluation strategy
pub type PropValue {
  EagerProp(value: json.Json)
  LazyProp(evaluate: fn() -> json.Json)
}

/// Configuration for the Inertia adapter
pub type Config {
  Config(version: String, ssr: Bool, encrypt_history: Bool)
}

/// Context wrapper for building up props before rendering
pub type InertiaContext {
  InertiaContext(
    config: Config,
    request: wisp.Request,
    props: Dict(String, Prop),
    errors: Dict(String, String),
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
    errors: dict.new(),
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
  RenderError(String)
}

pub fn ssr_error_to_string(error: SSRError) -> String {
  case error {
    SupervisorNotStarted -> "SSR supervisor not started"
    NodeJSStartFailed(message) -> "Failed to start Node.js: " <> message
    RenderError(message) -> "SSR render failed: " <> message
  }
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
    /// Name for the supervisor process
    supervisor_name: String,
  )
}
