import gleam/dynamic
import gleam/dynamic/decode
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/json
import inertia_gleam/ssr/config
import inertia_gleam/ssr/supervisor
import inertia_gleam/types.{type SSRConfig, type SSRMessage}

/// Start the SSR supervisor with the given configuration
pub fn start_supervisor(
  ssr_config: SSRConfig,
) -> Result(Subject(SSRMessage), String) {
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
        Error(ssr_error) -> {
          echo ssr_error
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
