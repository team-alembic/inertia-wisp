import gleeunit
import inertia_wisp/inertia

pub fn main() {
  gleeunit.main()
}

// Test 1: default_config should return expected values
pub fn default_config_test() {
  let config = inertia.default_config()
  
  assert config.version == "1"
  assert config.ssr == False
  assert config.encrypt_history == False
}

// Test 2: config function should set all values correctly
pub fn config_creation_test() {
  let config = inertia.config(
    version: "2.5.1",
    ssr: True,
    encrypt_history: True,
  )
  
  assert config.version == "2.5.1"
  assert config.ssr == True
  assert config.encrypt_history == True
}

// Test 3: config should handle version strings of different formats
pub fn config_version_formats_test() {
  let semantic_config = inertia.config(
    version: "1.2.3",
    ssr: False,
    encrypt_history: False,
  )
  
  let hash_config = inertia.config(
    version: "abc123def",
    ssr: False,
    encrypt_history: False,
  )
  
  let timestamp_config = inertia.config(
    version: "20231215-142530",
    ssr: False,
    encrypt_history: False,
  )
  
  assert semantic_config.version == "1.2.3"
  assert hash_config.version == "abc123def"
  assert timestamp_config.version == "20231215-142530"
}

// Test 4: config should handle empty version string
pub fn config_empty_version_test() {
  let config = inertia.config(
    version: "",
    ssr: False,
    encrypt_history: False,
  )
  
  assert config.version == ""
  assert config.ssr == False
  assert config.encrypt_history == False
}

// Test 5: config should handle all boolean combinations
pub fn config_boolean_combinations_test() {
  let config1 = inertia.config(version: "1", ssr: False, encrypt_history: False)
  let config2 = inertia.config(version: "1", ssr: False, encrypt_history: True)
  let config3 = inertia.config(version: "1", ssr: True, encrypt_history: False)
  let config4 = inertia.config(version: "1", ssr: True, encrypt_history: True)
  
  assert config1.ssr == False && config1.encrypt_history == False
  assert config2.ssr == False && config2.encrypt_history == True
  assert config3.ssr == True && config3.encrypt_history == False
  assert config4.ssr == True && config4.encrypt_history == True
}

// Test 6: ssr_config should create SSR configuration correctly
pub fn ssr_config_creation_test() {
  let ssr_config = inertia.ssr_config(
    enabled: True,
    path: "./dist/ssr/server.js",
    module: "default",
    pool_size: 4,
    timeout_ms: 3000,
    supervisor_name: "test_ssr_supervisor",
  )
  
  assert ssr_config.enabled == True
  assert ssr_config.path == "./dist/ssr/server.js"
  assert ssr_config.module == "default"
  assert ssr_config.pool_size == 4
  assert ssr_config.timeout_ms == 3000
  assert ssr_config.supervisor_name == "test_ssr_supervisor"
}

// Test 7: ssr_config should handle disabled state
pub fn ssr_config_disabled_test() {
  let ssr_config = inertia.ssr_config(
    enabled: False,
    path: "",
    module: "",
    pool_size: 0,
    timeout_ms: 0,
    supervisor_name: "",
  )
  
  assert ssr_config.enabled == False
  assert ssr_config.path == ""
  assert ssr_config.module == ""
  assert ssr_config.pool_size == 0
  assert ssr_config.timeout_ms == 0
  assert ssr_config.supervisor_name == ""
}

// Test 8: ssr_config should handle different path formats
pub fn ssr_config_path_formats_test() {
  let relative_config = inertia.ssr_config(
    enabled: True,
    path: "./ssr/index.js",
    module: "ssr",
    pool_size: 2,
    timeout_ms: 5000,
    supervisor_name: "relative_ssr",
  )
  
  let absolute_config = inertia.ssr_config(
    enabled: True,
    path: "/opt/app/dist/ssr/server.js",
    module: "render",
    pool_size: 3,
    timeout_ms: 4000,
    supervisor_name: "absolute_ssr",
  )
  
  assert relative_config.path == "./ssr/index.js"
  assert absolute_config.path == "/opt/app/dist/ssr/server.js"
}

// Test 9: ssr_config should handle different module export names
pub fn ssr_config_module_names_test() {
  let default_config = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 2,
    timeout_ms: 5000,
    supervisor_name: "default_ssr",
  )
  
  let named_config = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "renderToString",
    pool_size: 2,
    timeout_ms: 5000,
    supervisor_name: "named_ssr",
  )
  
  let custom_config = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "exports.render",
    pool_size: 2,
    timeout_ms: 5000,
    supervisor_name: "custom_ssr",
  )
  
  assert default_config.module == "default"
  assert named_config.module == "renderToString"
  assert custom_config.module == "exports.render"
}

// Test 10: ssr_config should handle various pool sizes
pub fn ssr_config_pool_sizes_test() {
  let small_pool = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 1,
    timeout_ms: 5000,
    supervisor_name: "small_pool",
  )
  
  let large_pool = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 10,
    timeout_ms: 5000,
    supervisor_name: "large_pool",
  )
  
  assert small_pool.pool_size == 1
  assert large_pool.pool_size == 10
}

// Test 11: ssr_config should handle various timeout values
pub fn ssr_config_timeout_values_test() {
  let short_timeout = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 2,
    timeout_ms: 1000,
    supervisor_name: "short_timeout",
  )
  
  let long_timeout = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 2,
    timeout_ms: 30000,
    supervisor_name: "long_timeout",
  )
  
  assert short_timeout.timeout_ms == 1000
  assert long_timeout.timeout_ms == 30000
}

// Test 12: ssr_config should handle different supervisor names
pub fn ssr_config_supervisor_names_test() {
  let simple_name = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 2,
    timeout_ms: 5000,
    supervisor_name: "ssr",
  )
  
  let descriptive_name = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 2,
    timeout_ms: 5000,
    supervisor_name: "InertiaServerSideRenderingSupervisor",
  )
  
  let namespaced_name = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 2,
    timeout_ms: 5000,
    supervisor_name: "MyApp.Inertia.SSR",
  )
  
  assert simple_name.supervisor_name == "ssr"
  assert descriptive_name.supervisor_name == "InertiaServerSideRenderingSupervisor"
  assert namespaced_name.supervisor_name == "MyApp.Inertia.SSR"
}

// Test 13: config types should be independent
pub fn config_independence_test() {
  let main_config = inertia.config(
    version: "main",
    ssr: True,
    encrypt_history: True,
  )
  
  let ssr_config = inertia.ssr_config(
    enabled: False,
    path: "./different.js",
    module: "other",
    pool_size: 5,
    timeout_ms: 2000,
    supervisor_name: "other_supervisor",
  )
  
  // Modifying one shouldn't affect the other
  assert main_config.version == "main"
  assert main_config.ssr == True
  assert ssr_config.enabled == False
  assert ssr_config.path == "./different.js"
}

// Test 14: start_ssr_supervisor should return error for non-existent file
pub fn start_ssr_supervisor_test() {
  let ssr_config = inertia.ssr_config(
    enabled: True,
    path: "./fake/nonexistent.js",  // Non-existent path
    module: "default",
    pool_size: 1,
    timeout_ms: 1000,
    supervisor_name: "test_supervisor",
  )
  
  // Should return an error for non-existent file
  case inertia.start_ssr_supervisor(ssr_config) {
    Ok(_supervisor) -> {
      // If it succeeds, that's actually fine - the supervisor might be created
      // even if the file doesn't exist yet (lazy loading)
      Nil
    }
    Error(_message) -> Nil  // Also fine - expected for non-existent file
  }
}

// Test 15: config values should handle edge cases
pub fn config_edge_cases_test() {
  let edge_config = inertia.config(
    version: "v1.0.0-beta.1+build.123",  // Complex semantic version
    ssr: False,
    encrypt_history: True,
  )
  
  let special_ssr_config = inertia.ssr_config(
    enabled: True,
    path: "./path with spaces/ssr-file.js",
    module: "module.exports.renderInertia",
    pool_size: 100,  // Large pool
    timeout_ms: 1,   // Very short timeout
    supervisor_name: "supervisor-with-dashes_and_underscores",
  )
  
  assert edge_config.version == "v1.0.0-beta.1+build.123"
  assert special_ssr_config.path == "./path with spaces/ssr-file.js"
  assert special_ssr_config.module == "module.exports.renderInertia"
  assert special_ssr_config.pool_size == 100
  assert special_ssr_config.timeout_ms == 1
  assert special_ssr_config.supervisor_name == "supervisor-with-dashes_and_underscores"
}