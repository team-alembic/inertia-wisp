import gleam/int
import gleam/json
import gleam/erlang/process.{type Subject}
import inertia_gleam/ssr/config.{type SSRConfig}
import inertia_gleam/ssr/supervisor.{type Message}

/// Result of an SSR rendering attempt
pub type SSRResult {
  /// SSR succeeded and returned HTML
  SSRSuccess(html: String)
  /// SSR failed but should fallback to CSR gracefully
  SSRFallback(reason: String)
  /// SSR failed with an error that should be raised
  SSRError(error: String)
}




/// Start the SSR supervisor with the given configuration
pub fn start_supervisor(ssr_config: SSRConfig) -> Result(Subject(Message), String) {
  case config.validate(ssr_config) {
    Ok(validated_config) -> {
      case supervisor.start_link(validated_config) {
        Ok(sup) -> {
          // Start the Node.js workers
          case supervisor.start_nodejs(sup) {
            Ok(_) -> Ok(sup)
            Error(_) -> Error("Failed to start Node.js workers")
          }
        }
        Error(_) -> Error("Failed to start supervisor")
      }
    }
    Error(config.InvalidPoolSize(size)) -> 
      Error("Invalid pool size: " <> int.to_string(size))
    Error(config.InvalidTimeout(timeout)) -> 
      Error("Invalid timeout: " <> int.to_string(timeout))
    Error(config.InvalidModuleName(name)) -> 
      Error("Invalid module name: " <> name)
    Error(config.InvalidPath(path)) -> 
      Error("Invalid path: " <> path)
  }
}

/// Check if SSR is enabled and available
pub fn is_enabled(supervisor: Subject(Message)) -> Bool {
  let status = supervisor.get_status(supervisor)
  status.enabled && status.supervisor_running
}

/// Check if the SSR supervisor is running  
pub fn is_supervisor_running(supervisor: Subject(Message)) -> Bool {
  let status = supervisor.get_status(supervisor)
  status.supervisor_running
}

/// Render a page using SSR with explicit supervisor
pub fn render_page_with_supervisor(
  supervisor: Subject(Message),
  component: String,
  props: json.Json,
  url: String,
  version: String
) -> SSRResult {
  let status = supervisor.get_status(supervisor)
  case status.enabled {
    False -> SSRFallback("SSR not enabled")
    True -> {
      let page_data = create_page_data(component, props, url, version)
      
      case serialize_page_data(page_data) {
        Ok(page_json) -> {
          case supervisor.render_page(supervisor, page_json, component) {
            Ok(html) -> SSRSuccess(html)
            Error(_) -> 
              handle_render_error("Render failed", status.config.raise_on_failure)
          }
        }
        Error(msg) -> SSRFallback("Failed to serialize page data: " <> msg)
      }
    }
  }
}

/// Render a page using SSR - requires explicit supervisor
/// For convenience, use render_page_with_supervisor instead
pub fn render_page(
  supervisor: Subject(Message),
  component: String,
  props: json.Json,
  url: String,
  version: String
) -> SSRResult {
  render_page_with_supervisor(supervisor, component, props, url, version)
}

/// Create page data structure expected by Inertia.js SSR
fn create_page_data(
  component: String,
  props: json.Json,
  url: String,
  version: String
) -> json.Json {
  json.object([
    #("component", json.string(component)),
    #("props", props),
    #("url", json.string(url)),
    #("version", json.string(version))
  ])
}

/// Serialize page data to JSON string
fn serialize_page_data(page_data: json.Json) -> Result(String, String) {
  Ok(json.to_string(page_data))
}

/// Handle render errors based on configuration
fn handle_render_error(error_msg: String, raise_on_failure: Bool) -> SSRResult {
  case raise_on_failure {
    True -> SSRError("SSR render failed: " <> error_msg)
    False -> SSRFallback("SSR render failed: " <> error_msg)
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
pub fn get_status(supervisor: Subject(Message)) -> supervisor.SSRStatus {
  supervisor.get_status(supervisor)
}

/// Update SSR configuration
pub fn update_config(supervisor: Subject(Message), new_config: SSRConfig) -> Result(Nil, String) {
  case supervisor.update_config(supervisor, new_config) {
    Ok(result) -> Ok(result)
    Error(_) -> Error("Failed to update configuration")
  }
}

/// Stop SSR supervisor
pub fn stop(supervisor: Subject(Message)) -> Result(Nil, String) {
  case supervisor.stop_nodejs(supervisor) {
    Ok(result) -> Ok(result)
    Error(_) -> Error("Failed to stop Node.js workers")
  }
}