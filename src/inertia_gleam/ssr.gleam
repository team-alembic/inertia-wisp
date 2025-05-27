import gleam/int
import gleam/json
import inertia_gleam/ssr/config.{type SSRConfig}
import inertia_gleam/ssr/nodejs_ffi

/// Result of an SSR rendering attempt
pub type SSRResult {
  /// SSR succeeded and returned HTML
  SSRSuccess(html: String)
  /// SSR failed but should fallback to CSR gracefully
  SSRFallback(reason: String)
  /// SSR failed with an error that should be raised
  SSRError(error: String)
}

/// SSR-specific errors
pub type SSRError {
  NotInitialized
  RenderTimeout(Int)
  WorkerUnavailable
  SerializationFailed(String)
  ConfigurationInvalid(String)
}



/// Initialize SSR with the given configuration
pub fn initialize(ssr_config: SSRConfig) -> Result(Nil, SSRError) {
  case config.validate(ssr_config) {
    Ok(validated_config) -> {
      let node_config = nodejs_ffi.NodeSupervisorConfig(
        path: validated_config.path,
        pool_size: validated_config.pool_size,
        name: validated_config.supervisor_name,
      )
      
      case nodejs_ffi.start_supervisor(node_config) {
        Ok(_) -> Ok(Nil)
        Error(nodejs_ffi.SupervisorStartError(msg)) -> 
          Error(ConfigurationInvalid("Failed to start supervisor: " <> msg))
        Error(_) -> 
          Error(ConfigurationInvalid("Unknown supervisor error"))
      }
    }
    Error(config.InvalidPoolSize(size)) -> 
      Error(ConfigurationInvalid("Invalid pool size: " <> int.to_string(size)))
    Error(config.InvalidTimeout(timeout)) -> 
      Error(ConfigurationInvalid("Invalid timeout: " <> int.to_string(timeout)))
    Error(config.InvalidModuleName(name)) -> 
      Error(ConfigurationInvalid("Invalid module name: " <> name))
    Error(config.InvalidPath(path)) -> 
      Error(ConfigurationInvalid("Invalid path: " <> path))
  }
}

/// Check if SSR is enabled and available
pub fn is_enabled() -> Bool {
  // For now, return False since we don't have global state management
  // In Phase 2, this will check the supervisor state
  False
}

/// Check if the SSR supervisor is running  
pub fn is_supervisor_running() -> Bool {
  // For now, use default supervisor name
  nodejs_ffi.supervisor_running("InertiaSSR")
}

/// Render a page using SSR with explicit configuration
pub fn render_page_with_config(
  component: String,
  props: json.Json,
  url: String,
  version: String,
  ssr_config: SSRConfig
) -> SSRResult {
  case ssr_config.enabled {
    False -> SSRFallback("SSR not enabled")
    True -> {
      let page_data = create_page_data(component, props, url, version)
      
      case serialize_page_data(page_data) {
        Ok(page_json) -> {
          case nodejs_ffi.call_render(
            ssr_config.module,
            page_json,
            ssr_config.supervisor_name,
            ssr_config.timeout_ms
          ) {
            Ok(html) -> SSRSuccess(html)
            Error(nodejs_ffi.NodeCallError(msg)) -> 
              handle_render_error(msg, ssr_config.raise_on_failure)
            Error(nodejs_ffi.SerializationError(msg)) ->
              SSRFallback("Serialization failed: " <> msg)
            Error(_) ->
              SSRFallback("Unknown render error")
          }
        }
        Error(msg) -> SSRFallback("Failed to serialize page data: " <> msg)
      }
    }
  }
}

/// Render a page using SSR with default configuration
pub fn render_page(
  component: String,
  props: json.Json,
  url: String,
  version: String
) -> SSRResult {
  render_page_with_config(component, props, url, version, config.default())
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
pub fn validate_config(ssr_config: SSRConfig) -> Result(SSRConfig, SSRError) {
  case config.validate(ssr_config) {
    Ok(validated) -> Ok(validated)
    Error(_) -> Error(ConfigurationInvalid("Invalid configuration"))
  }
}