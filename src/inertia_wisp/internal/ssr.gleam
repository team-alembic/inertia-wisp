//// @internal
////
//// Server-Side Rendering (SSR) coordination for Inertia.js applications.
////
//// This module provides the core SSR functionality that enables server-side
//// rendering of Inertia.js pages for improved SEO, faster initial page loads,
//// and better user experience. It coordinates between the Gleam server and
//// a Node.js process pool that handles the actual rendering.
////
//// ## How SSR Works
////
//// 1. **Process Pool**: Manages a pool of Node.js processes for rendering
//// 2. **Message Passing**: Sends page data to Node.js processes via JSON
//// 3. **HTML Generation**: Receives rendered HTML from the frontend framework
//// 4. **Fallback Handling**: Gracefully falls back to client-side rendering on errors
////
//// ## Architecture
////
//// ```
//// Gleam Server -> SSR Supervisor -> Node.js Process Pool -> Frontend Framework
//// ```
////
//// The SSR system uses Erlang's actor model to manage:
//// - A supervisor that oversees the Node.js processes
//// - Individual worker processes for parallel rendering
//// - Message queues for handling rendering requests
//// - Timeout and error handling for reliability
////
//// ## Configuration
////
//// SSR requires configuration of:
//// - Node.js script path for rendering
//// - Process pool size for concurrency
//// - Timeout values for request handling
//// - Module names for component resolution
////
//// ## Error Handling
////
//// The SSR system is designed to be resilient:
//// - Failed renders fall back to client-side rendering
//// - Process crashes are automatically recovered
//// - Timeouts prevent hanging requests
//// - Detailed error reporting for debugging

import gleam/dynamic
import gleam/dynamic/decode
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/json
import gleam/result
import inertia_wisp/internal/ssr/config
import inertia_wisp/internal/ssr/supervisor
import inertia_wisp/internal/types.{type SSRConfig, type SSRMessage}

/// Start the SSR supervisor with the given configuration
pub fn start_supervisor(
  ssr_config: SSRConfig,
) -> Result(Subject(SSRMessage), String) {
  use validated_config <- result.try(validate_config_with_detailed_errors(
    ssr_config,
  ))
  use sup <- result.try(
    supervisor.start_link(validated_config)
    |> result.map_error(fn(_) { "Failed to start supervisor" }),
  )
  use _ <- result.try(
    supervisor.start_nodejs(sup)
    |> result.map_error(fn(_) { "Failed to start Node.js workers" }),
  )
  Ok(sup)
}

fn validate_config_with_detailed_errors(
  ssr_config: SSRConfig,
) -> Result(SSRConfig, String) {
  case config.validate(ssr_config) {
    Ok(validated_config) -> Ok(validated_config)
    Error(config.InvalidPoolSize(size)) ->
      Error("InvalidSSRMessageize: " <> int.to_string(size))
    Error(config.InvalidTimeout(timeout)) ->
      Error("Invalid timeout: " <> int.to_string(timeout))
    Error(config.InvalidModuleName(name)) ->
      Error("Invalid module name: " <> name)
    Error(config.InvalidPath(path)) -> Error("Invalid path: " <> path)
  }
}

/// Check if SSR is enabled and available
pub fn is_enabled(supervisor: Subject(SSRMessage)) -> Bool {
  let status = supervisor.get_status(supervisor)
  status.enabled && status.supervisor_running
}

/// Check if the SSR supervisor is running
pub fn is_supervisor_running(supervisor: Subject(SSRMessage)) -> Bool {
  let status = supervisor.get_status(supervisor)
  status.supervisor_running
}

/// Render a page using SSR with explicit supervisor
pub fn render_page_with_supervisor(
  supervisor: Subject(SSRMessage),
  component: String,
  props: json.Json,
  url: String,
  version: String,
) -> types.SSRResult {
  let status = supervisor.get_status(supervisor)
  case status.enabled {
    False -> types.SSRFallback("SSR not enabled")
    True -> {
      let page_data = create_page_data(component, props, url, version)
      case supervisor.render_page(supervisor, page_data, component) {
        Ok(response) -> types.SSRSuccess(response)
        Error(_ssr_error) -> {
          // echo ssr_error
          handle_render_error("Render failed: ", status.config.raise_on_failure)
        }
      }
    }
  }
}

/// Render a page using SSR - requires explicit supervisor
/// For convenience, use render_page_with_supervisor instead
pub fn render_page(
  supervisor: Subject(SSRMessage),
  component: String,
  props: json.Json,
  url: String,
  version: String,
) -> types.SSRResult {
  render_page_with_supervisor(supervisor, component, props, url, version)
}

/// Create page data structure expected by Inertia.js SSR
fn create_page_data(
  component: String,
  props: json.Json,
  url: String,
  version: String,
) -> dynamic.Dynamic {
  let assert Ok(props) = json.parse(json.to_string(props), decode.dynamic)
  dynamic.properties([
    #(dynamic.string("component"), dynamic.string(component)),
    #(dynamic.string("props"), props),
    #(dynamic.string("url"), dynamic.string(url)),
    #(dynamic.string("version"), dynamic.string(version)),
  ])
}

/// Handle render errors based on configuration
fn handle_render_error(
  error_msg: String,
  raise_on_failure: Bool,
) -> types.SSRResult {
  case raise_on_failure {
    True -> types.SSRError("SSR render failed: " <> error_msg)
    False -> types.SSRFallback("SSR render failed: " <> error_msg)
  }
}

/// Get default SSR configuration
pub fn get_default_config() -> SSRConfig {
  config.default()
}

/// Validate an SSR configuration
pub fn validate_config(ssr_config: SSRConfig) -> Result(SSRConfig, String) {
  case config.validate(ssr_config) {
    Ok(validated) -> Ok(validated)
    Error(_) -> Error("Invalid configuration")
  }
}

/// Get current SSR status
pub fn get_status(supervisor: Subject(SSRMessage)) -> types.SSRStatus {
  supervisor.get_status(supervisor)
}

/// Update SSR configuration
pub fn update_config(
  supervisor: Subject(types.SSRMessage),
  new_config: types.SSRConfig,
) -> Result(Nil, String) {
  case supervisor.update_config(supervisor, new_config) {
    Ok(result) -> Ok(result)
    Error(_) -> Error("Failed to update configuration")
  }
}

/// Stop SSR supervisorSSRMessage
pub fn stop(supervisor: Subject(types.SSRMessage)) -> Result(Nil, String) {
  case supervisor.stop_nodejs(supervisor) {
    Ok(result) -> Ok(result)
    Error(_) -> Error("Failed to stop Node.js workers")
  }
}
