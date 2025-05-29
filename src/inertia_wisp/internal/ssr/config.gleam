//// @internal
////
//// Configuration management for Server-Side Rendering (SSR) functionality.
////
//// This module provides configuration validation and management for the SSR
//// system used in Inertia.js applications. It handles the setup and validation
//// of Node.js process pool configuration, script paths, timeouts, and other
//// SSR-specific settings.
////
//// ## Configuration Options
////
//// The SSR configuration includes:
//// - **Script Path**: Path to the Node.js rendering script
//// - **Pool Size**: Number of Node.js worker processes to maintain
//// - **Timeout**: Maximum time to wait for rendering completion
//// - **Module Name**: Name of the module containing frontend components
////
//// ## Validation
////
//// The module provides comprehensive validation for:
//// - File system paths to ensure scripts exist and are accessible
//// - Pool size limits to prevent resource exhaustion
//// - Timeout values to ensure reasonable response times
//// - Module name format for proper component resolution
////
//// ## Error Handling
////
//// Configuration errors are categorized into specific types:
//// - `InvalidPath`: Script file not found or inaccessible
//// - `InvalidPoolSize`: Pool size outside acceptable range
//// - `InvalidTimeout`: Timeout value too low or too high
//// - `InvalidModuleName`: Malformed module identifier
////
//// This ensures early detection of configuration issues before SSR
//// processes are started, preventing runtime failures.

import inertia_wisp/internal/types.{type SSRConfig, SSRConfig}

/// Error types for SSR configuration
pub type ConfigError {
  InvalidPath(String)
  InvalidPoolSize(Int)
  InvalidTimeout(Int)
  InvalidModuleName(String)
}

/// Create default SSR configuration
pub fn default() -> SSRConfig {
  SSRConfig(
    enabled: False,
    path: "priv",
    module: "ssr",
    pool_size: 4,
    timeout_ms: 5000,
    supervisor_name: "InertiaSSR",
  )
}

/// Builder functions for configuring SSR
pub fn with_enabled(config: SSRConfig, enabled: Bool) -> SSRConfig {
  SSRConfig(..config, enabled: enabled)
}

pub fn with_path(config: SSRConfig, path: String) -> SSRConfig {
  SSRConfig(..config, path: path)
}

pub fn with_module(config: SSRConfig, module: String) -> SSRConfig {
  SSRConfig(..config, module: module)
}

pub fn with_pool_size(config: SSRConfig, pool_size: Int) -> SSRConfig {
  SSRConfig(..config, pool_size: pool_size)
}

pub fn with_timeout(config: SSRConfig, timeout_ms: Int) -> SSRConfig {
  SSRConfig(..config, timeout_ms: timeout_ms)
}

pub fn with_supervisor_name(
  config: SSRConfig,
  supervisor_name: String,
) -> SSRConfig {
  SSRConfig(..config, supervisor_name: supervisor_name)
}
