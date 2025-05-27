import gleam/json
import inertia_gleam
import inertia_gleam/ssr
import inertia_gleam/ssr/config
import inertia_gleam/testing
import inertia_gleam/types
import wisp

/// Phase 3 SSR Integration Example
/// 
/// This demonstrates the simple API for integrating SSR with Inertia Gleam.
/// The key principle: SSR decision is delayed until the very last moment,
/// after all props have been evaluated and the Page JSON is ready.

/// Example 1: Basic SSR Setup
/// 
/// This shows how to set up SSR in your application startup
pub fn setup_ssr_example() {
  // 1. Create SSR configuration
  let ssr_config = config.SSRConfig(
    enabled: True,
    path: "priv",           // Directory containing your ssr.js file
    module: "ssr",          // Module name (ssr.js exports)
    pool_size: 4,           // Number of Node.js worker processes
    timeout_ms: 5000,       // Render timeout
    raise_on_failure: False, // Graceful fallback to CSR on errors
    supervisor_name: "MyAppSSR",
  )

  // 2. Start the SSR supervisor (usually in your app startup)
  case ssr.start_supervisor(ssr_config) {
    Ok(supervisor) -> {
      // Store supervisor reference to use in request handlers
      Ok(supervisor)
    }
    Error(msg) -> {
      // Handle startup error - might continue without SSR
      Error("Failed to start SSR: " <> msg)
    }
  }
}

/// Example 2: Simple Request Handler with SSR
/// 
/// This shows how to use SSR in your route handlers
pub fn simple_ssr_handler_example(request: wisp.Request, supervisor) {
  let config = types.default_config()
  
  // Create context and enable SSR
  let ctx = types.new_context(config, request)
    |> inertia_gleam.enable_ssr()                    // Enable SSR flag
    |> inertia_gleam.with_ssr_supervisor(supervisor) // Set supervisor
    |> inertia_gleam.assign_prop("title", json.string("Welcome"))
    |> inertia_gleam.assign_prop("user", json.object([
      #("name", json.string("Alice")),
      #("role", json.string("admin"))
    ]))

  // Render - SSR decision happens automatically at this point
  inertia_gleam.render(ctx, "HomePage")
}

/// Example 3: Conditional SSR per Route
/// 
/// This shows how to enable/disable SSR per route
pub fn conditional_ssr_example(request: wisp.Request, supervisor) {
  let config = types.default_config()
  let base_ctx = types.new_context(config, request)
    |> inertia_gleam.with_ssr_supervisor(supervisor)

  case wisp.path_segments(request) {
    // Enable SSR for marketing pages
    [] | ["about"] | ["features"] -> {
      base_ctx
      |> inertia_gleam.enable_ssr()
      |> inertia_gleam.assign_prop("page", json.string("marketing"))
      |> inertia_gleam.render("MarketingPage")
    }
    
    // Disable SSR for admin dashboard (client-heavy interactions)
    ["admin", ..] -> {
      base_ctx
      |> inertia_gleam.disable_ssr()
      |> inertia_gleam.assign_prop("page", json.string("admin"))
      |> inertia_gleam.render("AdminDashboard")
    }
    
    // Default SSR behavior for other pages
    _ -> {
      base_ctx
      |> inertia_gleam.enable_ssr()
      |> inertia_gleam.assign_prop("page", json.string("default"))
      |> inertia_gleam.render("DefaultPage")
    }
  }
}

/// Example 4: SSR with Lazy Props
/// 
/// This demonstrates that SSR evaluation happens after all props are resolved
pub fn ssr_with_lazy_props_example(request: wisp.Request, supervisor) {
  let config = types.default_config()
  
  types.new_context(config, request)
  |> inertia_gleam.enable_ssr()
  |> inertia_gleam.with_ssr_supervisor(supervisor)
  // Eager props are evaluated immediately
  |> inertia_gleam.assign_prop("title", json.string("Dashboard"))
  // Lazy props are evaluated just before SSR decision
  |> inertia_gleam.assign_lazy_prop("stats", fn() {
    // This expensive computation runs before SSR decision
    fetch_user_stats() |> json.object()
  })
  // Always props are included in every request
  |> inertia_gleam.assign_always_prop("app_name", json.string("My App"))
  // At this point: all props evaluated → Page JSON created → SSR decision
  |> inertia_gleam.render("Dashboard")
}

/// Example 5: SSR Decision Flow
/// 
/// This shows exactly when SSR vs CSR decisions are made
pub fn ssr_decision_flow_example() {
  let request = testing.inertia_request() // Simulates XHR request
  let config = types.default_config()
  
  // For this example, we'll show the decision flow:
  
  // Step 1: Props are assigned (not yet evaluated)
  let ctx = types.new_context(config, request)
    |> inertia_gleam.enable_ssr()
    |> inertia_gleam.assign_prop("data", json.string("test"))
    |> inertia_gleam.assign_lazy_prop("computed", fn() {
      json.int(42) // This will be evaluated before SSR decision
    })
  
  // Step 2: render() is called
  // Step 3: All props are evaluated into final values
  // Step 4: Page JSON object is created with all evaluated props
  // Step 5: SSR decision is made:
  //   - Is this an Inertia XHR request? → Return JSON (CSR)
  //   - Is this an initial page load? → Check SSR config
  //   - Is SSR enabled AND supervisor available? → Try SSR
  //   - SSR success? → Return HTML
  //   - SSR failure? → Fallback to CSR HTML
  let _response = inertia_gleam.render(ctx, "TestPage")
  
  // The beauty: the decision is completely transparent to the developer
}

/// Example 6: Production Configuration
/// 
/// This shows a production-ready SSR setup
pub fn production_ssr_example() {
  // Production SSR config with appropriate settings
  let prod_config = config.production()
    |> config.with_pool_size(8)        // More workers for production
    |> config.with_timeout(3000)       // Shorter timeout for better UX
    |> config.with_path("/app/priv")    // Production asset path
  
  case ssr.start_supervisor(prod_config) {
    Ok(supervisor) -> {
      // In production, you might want health checks
      let status = ssr.get_status(supervisor)
      case status.enabled && status.supervisor_running {
        True -> {
          // SSR is healthy, use it in request handlers
          Ok(supervisor)
        }
        False -> {
          // SSR not available, log warning and continue without SSR
          Error("SSR supervisor not healthy")
        }
      }
    }
    Error(msg) -> {
      // In production, you might want to continue without SSR
      Error("SSR startup failed: " <> msg)
    }
  }
}

/// Example 7: Testing SSR-enabled Routes
/// 
/// This shows how to test routes that use SSR
pub fn test_ssr_route_example() {
  // Create test context  
  let request = testing.inertia_request()
  let config = types.default_config()
  
  // Test without SSR supervisor (should fallback gracefully)
  let ctx_no_ssr = types.new_context(config, request)
    |> inertia_gleam.enable_ssr() // Enabled but no supervisor
    |> inertia_gleam.assign_prop("test", json.string("value"))
  
  let response = inertia_gleam.render(ctx_no_ssr, "TestComponent")
  
  // Should return JSON for Inertia XHR requests (bypasses SSR anyway)
  // Should return HTML for initial page loads (falls back to CSR)
  
  response
}

// Mock functions for examples
fn fetch_user_stats() -> List(#(String, json.Json)) {
  [
    #("total_users", json.int(1250)),
    #("active_sessions", json.int(89)),
    #("revenue", json.float(15420.50))
  ]
}