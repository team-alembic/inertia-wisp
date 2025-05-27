import gleam/result

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
    raise_on_failure: False,
    supervisor_name: "InertiaSSR",
  )
}

/// Create SSR configuration for development
pub fn development() -> SSRConfig {
  SSRConfig(
    ..default(),
    enabled: True,
    raise_on_failure: True,
    timeout_ms: 10_000,
  )
}

/// Create SSR configuration for production
pub fn production() -> SSRConfig {
  SSRConfig(
    ..default(),
    enabled: True,
    raise_on_failure: False,
    pool_size: 8,
    timeout_ms: 3000,
  )
}

/// Validate SSR configuration
pub fn validate(config: SSRConfig) -> Result(SSRConfig, ConfigError) {
  use _ <- result.try(validate_pool_size(config.pool_size))
  use _ <- result.try(validate_timeout(config.timeout_ms))
  use _ <- result.try(validate_module_name(config.module))
  Ok(config)
}

fn validate_pool_size(pool_size: Int) -> Result(Nil, ConfigError) {
  case pool_size > 0 && pool_size <= 50 {
    True -> Ok(Nil)
    False -> Error(InvalidPoolSize(pool_size))
  }
}

fn validate_timeout(timeout_ms: Int) -> Result(Nil, ConfigError) {
  case timeout_ms > 0 && timeout_ms <= 60_000 {
    True -> Ok(Nil)
    False -> Error(InvalidTimeout(timeout_ms))
  }
}

fn validate_module_name(module: String) -> Result(Nil, ConfigError) {
  case module {
    "" -> Error(InvalidModuleName(module))
    _ -> Ok(Nil)
  }
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

pub fn with_raise_on_failure(config: SSRConfig, raise_on_failure: Bool) -> SSRConfig {
  SSRConfig(..config, raise_on_failure: raise_on_failure)
}

pub fn with_supervisor_name(config: SSRConfig, supervisor_name: String) -> SSRConfig {
  SSRConfig(..config, supervisor_name: supervisor_name)
}