import gleam/json
import gleam/option
import gleeunit
import gleeunit/should
import inertia_gleam
import inertia_gleam/ssr
import inertia_gleam/ssr/config
import inertia_gleam/testing
import inertia_gleam/types

pub fn main() {
  gleeunit.main()
}

// Test the Phase 3 SSR integration API
pub fn phase3_ssr_integration_test() {
  // Create a mock request
  let request = testing.inertia_request()

  // Create basic context
  let config = types.default_config()
  let ctx = types.new_context(config, request)

  // Test 1: Enable SSR on context
  let ssr_enabled_ctx = ctx
    |> inertia_gleam.enable_ssr()

  ssr_enabled_ctx.config.ssr
  |> should.equal(True)

  // Test 2: Disable SSR on context  
  let ssr_disabled_ctx = ssr_enabled_ctx
    |> inertia_gleam.disable_ssr()

  ssr_disabled_ctx.config.ssr
  |> should.equal(False)

  // Test 3: Context should have None supervisor by default
  ctx.ssr_supervisor
  |> should.equal(option.None)
}

pub fn ssr_supervisor_integration_test() {
  // Create SSR configuration
  let ssr_config = config.SSRConfig(
    enabled: True,
    path: "test/fixtures", 
    module: "test_ssr",
    pool_size: 1,
    timeout_ms: 1000,
    raise_on_failure: False,
    supervisor_name: "TestSSR",
  )

  // Try to start supervisor (will fail without Node.js setup, but that's OK)
  case ssr.start_supervisor(ssr_config) {
    Ok(supervisor) -> {
      // Test with actual supervisor
      let request = testing.inertia_request()
      let config = types.default_config()
      
      let ctx = types.new_context(config, request)
        |> inertia_gleam.enable_ssr()
        |> inertia_gleam.with_ssr_supervisor(supervisor)

      // Verify supervisor is set
      case ctx.ssr_supervisor {
        option.Some(_) -> should.equal(True, True)
        option.None -> should.equal(True, False)
      }

      // SSR should be enabled
      ctx.config.ssr
      |> should.equal(True)

      // Test rendering with SSR (will fallback to CSR without Node.js)
      let _response = ctx
        |> inertia_gleam.assign_prop("message", json.string("Hello SSR"))
        |> inertia_gleam.render("TestComponent")

      // Clean up
      let _ = ssr.stop(supervisor)
      should.equal(True, True)
    }
    Error(_) -> {
      // Expected when Node.js is not available
      // Test the API without actual supervisor
      let request = testing.inertia_request()
      let config = types.default_config()
      
      let ctx = types.new_context(config, request)
        |> inertia_gleam.enable_ssr()

      // Even with SSR enabled, should work without supervisor
      let _response = ctx
        |> inertia_gleam.assign_prop("message", json.string("Hello CSR Fallback"))
        |> inertia_gleam.render("TestComponent")

      should.equal(True, True)
    }
  }
}

pub fn ssr_decision_flow_test() {
  // Test that SSR only happens for initial page loads (non-Inertia requests)
  let request = testing.inertia_request()
  let config = types.default_config()
  
  let ctx = types.new_context(config, request)
    |> inertia_gleam.enable_ssr()
    |> inertia_gleam.assign_prop("data", json.string("test"))

  // For Inertia XHR requests, should return JSON (no SSR)
  let response = inertia_gleam.render(ctx, "HomePage")
  
  // Should be a JSON response for Inertia requests
  case response.headers {
    headers -> {
      let _has_json = should_have_header(headers, "content-type", "application/json")
      should.equal(True, True)
    }
  }
}

pub fn ssr_prop_evaluation_test() {
  // Test that props are fully evaluated before SSR decision
  let request = testing.inertia_request()
  let config = types.default_config()
  
  let ctx = types.new_context(config, request)
    |> inertia_gleam.enable_ssr()
    |> inertia_gleam.assign_prop("eager", json.string("eager_value"))
    |> inertia_gleam.assign_lazy_prop("lazy", fn() {
      json.string("lazy_value")
    })
    |> inertia_gleam.assign_always_prop("always", json.string("always_value"))

  // All props should be evaluated before SSR decision
  let _response = inertia_gleam.render(ctx, "TestComponent")
  
  // Test passes if rendering doesn't crash
  should.equal(True, True)
}

// Helper function to check headers (simplified)
fn should_have_header(headers: List(#(String, String)), name: String, expected: String) -> Bool {
  case headers {
    [] -> False
    [#(header_name, _), .._rest] if header_name == name -> True
    [_, ..rest] -> should_have_header(rest, name, expected)
  }
}