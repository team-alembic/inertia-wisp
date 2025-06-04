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
