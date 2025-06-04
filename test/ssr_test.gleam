import gleam/dict
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/json
import gleam/option
import gleeunit
import inertia_wisp/inertia
import inertia_wisp/internal/types
import inertia_wisp/testing
import wisp
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Test prop type for SSR tests
pub type SSRProp {
  Title(title: String)
  Content(content: String)
}

fn encode_ssr_prop(prop: SSRProp) -> json.Json {
  case prop {
    Title(title) -> json.string(title)
    Content(content) -> json.string(content)
  }
}

// Helper to create context with SSR enabled
fn create_ssr_context(
  ssr_supervisor: option.Option(process.Subject(types.SSRMessage)),
  req: wisp.Request,
) -> types.InertiaContext(SSRProp) {
  let config = inertia.config(
    version: "1",
    ssr: True,
    encrypt_history: False,
  )
  
  types.InertiaContext(
    config: config,
    request: req,
    props: dict.new(),
    prop_encoder: encode_ssr_prop,
    errors: dict.new(),
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: ssr_supervisor,
  )
}

// Test 1: ssr_config should create valid configuration
pub fn ssr_config_creation_test() {
  let ssr_config = inertia.ssr_config(
    enabled: True,
    path: "./ssr/server.js",
    module: "default",
    pool_size: 3,
    timeout_ms: 5000,
    supervisor_name: "test_ssr",
  )
  
  assert ssr_config.enabled == True
  assert ssr_config.path == "./ssr/server.js"
  assert ssr_config.module == "default"
  assert ssr_config.pool_size == 3
  assert ssr_config.timeout_ms == 5000
  assert ssr_config.supervisor_name == "test_ssr"
}

// Test 2: ssr_config should handle minimal configuration
pub fn ssr_config_minimal_test() {
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

// Test 3: start_ssr_supervisor should handle non-existent files gracefully
pub fn start_ssr_supervisor_nonexistent_test() {
  let ssr_config = inertia.ssr_config(
    enabled: True,
    path: "./fake/nonexistent.js",
    module: "default",
    pool_size: 1,
    timeout_ms: 1000,
    supervisor_name: "fake_supervisor",
  )
  
  // Should either succeed (lazy loading) or fail gracefully
  case inertia.start_ssr_supervisor(ssr_config) {
    Ok(_supervisor) -> Nil  // Success is fine
    Error(_message) -> Nil  // Error is also expected
  }
}

// Test 4: context with SSR enabled but no supervisor should render as CSR
pub fn ssr_enabled_no_supervisor_test() {
  let req = testing.inertia_request()
  
  let ctx = create_ssr_context(option.None, req)
    |> inertia.prop("title", Title("SSR Test"))
    |> inertia.prop("content", Content("Server-side rendered content"))
  
  let response = inertia.render(ctx, "SSRComponent")
  
  // Should render successfully as CSR when no supervisor
  assert testing.component(response) == Ok("SSRComponent")
  assert testing.prop(response, "title", decode.string) == Ok("SSR Test")
  assert testing.prop(response, "content", decode.string) == Ok("Server-side rendered content")
}

// Test 5: context without SSR supervisor should render as CSR
pub fn no_ssr_supervisor_render_test() {
  let req = testing.inertia_request()
  let ctx = create_ssr_context(option.None, req)
    |> inertia.prop("title", Title("CSR Test"))
    |> inertia.prop("content", Content("Client-side rendered content"))
  
  let response = inertia.render(ctx, "CSRComponent")
  
  assert testing.component(response) == Ok("CSRComponent")
  assert testing.prop(response, "title", decode.string) == Ok("CSR Test")
  assert testing.prop(response, "content", decode.string) == Ok("Client-side rendered content")
}

// Test 6: SSR disabled in config should render as CSR
pub fn ssr_disabled_config_test() {
  let req = testing.inertia_request()
  
  // Create config with SSR disabled
  let config = inertia.config(
    version: "1",
    ssr: False,  // Disabled
    encrypt_history: False,
  )
  
  let ctx = types.InertiaContext(
    config: config,
    request: req,
    props: dict.new(),
    prop_encoder: encode_ssr_prop,
    errors: dict.new(),
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: option.None,
  )
    |> inertia.prop("title", Title("Disabled SSR"))
  
  let response = inertia.render(ctx, "DisabledSSRComponent")
  
  assert testing.component(response) == Ok("DisabledSSRComponent")
  assert testing.prop(response, "title", decode.string) == Ok("Disabled SSR")
}

// Test 7: SSR should work with non-Inertia requests (HTML responses)
pub fn ssr_html_response_test() {
  let req = wisp_testing.get("/", [])  // Regular HTTP request
  let ctx = create_ssr_context(option.None, req)
    |> inertia.prop("title", Title("HTML SSR Test"))
    |> inertia.prop("content", Content("Server-side rendered HTML"))
  
  let response = inertia.render(ctx, "HTMLSSRComponent")
  
  // Should render as HTML without SSR (no supervisor)
  assert testing.component(response) == Ok("HTMLSSRComponent")
  assert testing.prop(response, "title", decode.string) == Ok("HTML SSR Test")
  assert testing.prop(response, "content", decode.string) == Ok("Server-side rendered HTML")
}

// Test 8: SSR configuration with various pool sizes
pub fn ssr_config_pool_sizes_test() {
  let single_pool = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 1,
    timeout_ms: 5000,
    supervisor_name: "single_pool",
  )
  
  let large_pool = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 20,
    timeout_ms: 5000,
    supervisor_name: "large_pool",
  )
  
  assert single_pool.pool_size == 1
  assert large_pool.pool_size == 20
  
  // Both should handle supervisor creation (even if they fail)
  case inertia.start_ssr_supervisor(single_pool) {
    Ok(_) -> Nil
    Error(_) -> Nil
  }
  
  case inertia.start_ssr_supervisor(large_pool) {
    Ok(_) -> Nil
    Error(_) -> Nil
  }
}

// Test 9: SSR configuration with various timeout values
pub fn ssr_config_timeout_test() {
  let short_timeout = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 2,
    timeout_ms: 100,
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
  
  assert short_timeout.timeout_ms == 100
  assert long_timeout.timeout_ms == 30000
}

// Test 10: SSR with complex props should work
pub fn ssr_complex_props_test() {
  let req = testing.inertia_request()
  let ctx = create_ssr_context(option.None, req)
    |> inertia.prop("title", Title("Complex SSR"))
    |> inertia.always_prop("content", Content("Always visible"))
    |> inertia.optional_prop("debug", fn() { Content("Debug info") })
  
  let response = inertia.render(ctx, "ComplexSSRComponent")
  
  assert testing.component(response) == Ok("ComplexSSRComponent")
  assert testing.prop(response, "title", decode.string) == Ok("Complex SSR")
  assert testing.prop(response, "content", decode.string) == Ok("Always visible")
  
  // Optional prop should not be included in regular render
  case testing.prop(response, "debug", decode.string) {
    Error(_) -> Nil  // Expected
    Ok(_) -> panic as "Optional prop should not be included"
  }
}

// Test 11: SSR with errors should work
pub fn ssr_with_errors_test() {
  let req = testing.inertia_request()
  let validation_errors = dict.from_list([
    #("name", "Name is required"),
    #("email", "Invalid email"),
  ])
  
  let ctx = create_ssr_context(option.None, req)
    |> inertia.prop("title", Title("Form with Errors"))
    |> inertia.errors(validation_errors)
  
  let response = inertia.render(ctx, "ErrorFormComponent")
  
  assert testing.component(response) == Ok("ErrorFormComponent")
  assert testing.prop(response, "title", decode.string) == Ok("Form with Errors")
  assert testing.prop(response, "errors", decode.at(["name"], decode.string)) == Ok("Name is required")
  assert testing.prop(response, "errors", decode.at(["email"], decode.string)) == Ok("Invalid email")
}

// Test 12: SSR configuration with different module names
pub fn ssr_config_modules_test() {
  let default_module = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "default",
    pool_size: 2,
    timeout_ms: 5000,
    supervisor_name: "default_ssr",
  )
  
  let named_module = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "renderToString",
    pool_size: 2,
    timeout_ms: 5000,
    supervisor_name: "named_ssr",
  )
  
  let complex_module = inertia.ssr_config(
    enabled: True,
    path: "./ssr.js",
    module: "exports.renderInertia",
    pool_size: 2,
    timeout_ms: 5000,
    supervisor_name: "complex_ssr",
  )
  
  assert default_module.module == "default"
  assert named_module.module == "renderToString"
  assert complex_module.module == "exports.renderInertia"
}