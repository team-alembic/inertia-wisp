import gleeunit
import gleeunit/should
import inertia_gleam/ssr/config
import inertia_gleam/ssr/nodejs_ffi
import inertia_gleam/ssr
import gleam/json

pub fn main() {
  gleeunit.main()
}

pub fn default_config_test() {
  let default_config = config.default()
  
  default_config.enabled
  |> should.equal(False)
  
  default_config.path
  |> should.equal("priv")
  
  default_config.module
  |> should.equal("ssr")
  
  default_config.pool_size
  |> should.equal(4)
  
  default_config.timeout_ms
  |> should.equal(5000)
  
  default_config.supervisor_name
  |> should.equal("InertiaSSR")
}

pub fn development_config_test() {
  let dev_config = config.development()
  
  dev_config.enabled
  |> should.equal(True)
  
  dev_config.raise_on_failure
  |> should.equal(True)
  
  dev_config.timeout_ms
  |> should.equal(10_000)
}

pub fn production_config_test() {
  let prod_config = config.production()
  
  prod_config.enabled
  |> should.equal(True)
  
  prod_config.raise_on_failure
  |> should.equal(False)
  
  prod_config.pool_size
  |> should.equal(8)
  
  prod_config.timeout_ms
  |> should.equal(3000)
}

pub fn config_validation_valid_test() {
  let valid_config = config.default()
  
  config.validate(valid_config)
  |> should.be_ok()
}

pub fn config_validation_invalid_pool_size_test() {
  let invalid_config = config.SSRConfig(
    ..config.default(),
    pool_size: 0
  )
  
  config.validate(invalid_config)
  |> should.be_error()
}

pub fn config_validation_invalid_timeout_test() {
  let invalid_config = config.SSRConfig(
    ..config.default(),
    timeout_ms: -1
  )
  
  config.validate(invalid_config)
  |> should.be_error()
}

pub fn config_validation_invalid_module_name_test() {
  let invalid_config = config.SSRConfig(
    ..config.default(),
    module: ""
  )
  
  config.validate(invalid_config)
  |> should.be_error()
}

pub fn config_builder_functions_test() {
  let base_config = config.default()
  
  let updated_config = 
    base_config
    |> config.with_enabled(True)
    |> config.with_pool_size(8)
    |> config.with_timeout(10_000)
    |> config.with_module("custom_ssr")
    |> config.with_path("/custom/path")
  
  updated_config.enabled
  |> should.equal(True)
  
  updated_config.pool_size
  |> should.equal(8)
  
  updated_config.timeout_ms
  |> should.equal(10_000)
  
  updated_config.module
  |> should.equal("custom_ssr")
  
  updated_config.path
  |> should.equal("/custom/path")
}

pub fn string_to_atom_test() {
  // This test just verifies the function exists and doesn't crash
  let _atom = nodejs_ffi.string_to_atom("test")
  
  // We can't easily test the actual atom value without more FFI helpers
  True
  |> should.equal(True)
}

pub fn node_supervisor_config_creation_test() {
  let node_config = nodejs_ffi.NodeSupervisorConfig(
    path: "/test/path",
    pool_size: 4,
    name: "TestSupervisor"
  )
  
  node_config.path
  |> should.equal("/test/path")
  
  node_config.pool_size
  |> should.equal(4)
  
  node_config.name
  |> should.equal("TestSupervisor")
}

pub fn ssr_not_enabled_by_default_test() {
  ssr.is_enabled()
  |> should.equal(False)
}

pub fn ssr_supervisor_not_running_initially_test() {
  ssr.is_supervisor_running()
  |> should.equal(False)
}

pub fn ssr_render_page_when_disabled_test() {
  let props = json.object([
    #("message", json.string("Hello, World!"))
  ])
  
  let result = ssr.render_page("TestComponent", props, "/test", "1.0")
  
  case result {
    ssr.SSRFallback(reason) -> {
      reason
      |> should.equal("SSR not enabled")
    }
    _ -> should.fail()
  }
}

pub fn get_default_config_test() {
  let current_config = ssr.get_default_config()
  
  current_config.enabled
  |> should.equal(False)
  
  current_config.module
  |> should.equal("ssr")
}