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
    props: json.Json,
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
    #("props", page.props),
    #("url", json.string(page.url)),
    #("version", json.string(page.version)),
    #("encryptHistory", json.bool(page.encrypt_history)),
    #("clearHistory", json.bool(page.clear_history)),
  ])
}

/// Prop inclusion behavior - when should this prop be included?
pub type IncludeProp {
  /// Always included in both initial renders and partial reloads
  IncludeAlways
  /// Included in initial renders and when specifically requested in partial reloads
  IncludeDefault
  /// Only included when specifically requested in partial reloads
  IncludeOptionally
}

/// A prop transformation with inclusion behavior for typed contexts
pub type PropTransform(props) {
  PropTransform(
    name: String,
    transform: fn(props) -> props,
    include: IncludeProp,
  )
}

/// Empty props type for middleware-before-routing pattern
/// This allows middleware to create a context without knowing the specific prop types
/// that will be used by individual route handlers
pub type EmptyProps {
  EmptyProps
}

/// Encoder for EmptyProps - always produces an empty JSON object
pub fn encode_empty_props(_props: EmptyProps) -> json.Json {
  json.object([])
}



/// Configuration for the Inertia adapter
pub type Config {
  Config(version: String, ssr: Bool, encrypt_history: Bool)
}



/// Context for statically typed props
pub type InertiaContext(props) {
  InertiaContext(
    config: Config,
    request: wisp.Request,
    prop_transforms: List(PropTransform(props)),
    props_encoder: fn(props) -> json.Json,
    props_zero: props,
    errors: Dict(String, String),
    encrypt_history: Bool,
    clear_history: Bool,
    ssr_supervisor: Option(Subject(SSRMessage)),
  )
}



pub fn new_context(config, request, props_zero, props_encoder) {
  InertiaContext(
    config: config,
    request: request,
    prop_transforms: [],
    props_encoder: props_encoder,
    props_zero: props_zero,
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
