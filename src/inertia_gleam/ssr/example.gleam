import gleam/bool
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/json
import gleam/string
import inertia_gleam/ssr
import inertia_gleam/ssr/config
import inertia_gleam/ssr/supervisor

pub fn main() {
  example_integration()

}
/// Example of how to integrate SSR with your Gleam application
pub fn example_integration() {
  // 1. Create SSR configuration
  let ssr_config =
    config.SSRConfig(
      enabled: True,
      path: "priv",
      // Path to directory containing ssr.js
      module: "ssr",
      // Name of the SSR module
      pool_size: 4,
      // Number of Node.js workers
      timeout_ms: 5000,
      // Render timeout
      raise_on_failure: False,
      // Fallback to CSR on failure
      supervisor_name: "MyAppSSR",
    )

  // 2. Start the SSR supervisor
  case ssr.start_supervisor(ssr_config) {
    Ok(supervisor) -> {
      io.println("SSR supervisor started successfully")

      // 3. Create some sample page data
      let props =
        json.object([
          #(
            "user",
            json.object([
              #("name", json.string("Alice")),
              #("email", json.string("alice@example.com")),
            ]),
          ),
          #(
            "posts",
            json.array(
              [
                json.object([
                  #("id", json.int(1)),
                  #("title", json.string("Hello World")),
                ]),
                json.object([
                  #("id", json.int(2)),
                  #("title", json.string("Gleam is Great")),
                ]),
              ],
              fn(x) { x },
            ),
          ),
        ])

      // 4. Render a page with SSR
      case
        ssr.render_page(supervisor, "UserDashboard", props, "/dashboard", "1.0")
      {
        ssr.SSRSuccess(html) -> {
          io.println("SSR render successful!")
          io.println("HTML length: " <> html |> string.length |> int.to_string)
        }
        ssr.SSRFallback(reason) -> {
          io.println("SSR fallback: " <> reason)
          // Your app would render CSR here
        }
        ssr.SSRError(error) -> {
          io.println("SSR error: " <> error)
          // Handle error appropriately
        }
      }

      // 5. Check supervisor status
      let status = ssr.get_status(supervisor)
      io.println("SSR enabled: " <> bool.to_string(status.enabled))
      io.println(
        "Supervisor running: " <> bool.to_string(status.supervisor_running),
      )

      // 6. Gracefully stop when done
      case ssr.stop(supervisor) {
        Ok(_) -> io.println("SSR stopped successfully")
        Error(msg) -> io.println("Failed to stop SSR: " <> msg)
      }
    }
    Error(msg) -> {
      io.println("Failed to start SSR supervisor: " <> msg)
    }
  }
}

/// Example of using SSR in a supervision tree
pub fn supervised_example() {
  let ssr_config = config.production()

  // Create child spec for your application supervisor
  let _ssr_child = supervisor.child_spec(ssr_config)

  // In your application's supervision tree, you would add:
  // supervisor.add_child(app_supervisor, ssr_child)

  io.println("SSR child spec created for supervision tree")
}

/// Example middleware-like function concept (simplified for demo)
pub fn ssr_middleware_concept() {
  io.println("SSR middleware would intercept requests and:")
  io.println("1. Check if it's an Inertia AJAX request")
  io.println("2. If not, attempt SSR for initial page loads")
  io.println("3. Fallback to CSR on SSR failure")
}

/// Example SSR request handler
pub fn handle_ssr_example(
  supervisor: process.Subject(supervisor.Message),
) -> String {
  // Extract component and props based on your route handling
  let component = "HomePage"
  // Determine from route
  let props = json.object([])
  // Build props from request
  let url = "/example"
  let version = "1.0"
  // Your app version

  case ssr.render_page(supervisor, component, props, url, version) {
    ssr.SSRSuccess(html) -> {
      // Return HTML response with embedded Inertia data
      html
    }
    ssr.SSRFallback(_) | ssr.SSRError(_) -> {
      // Fallback to standard Inertia CSR response
      build_inertia_html(component, props, url, version)
    }
  }
}

fn build_inertia_html(
  component: String,
  props: json.Json,
  url: String,
  version: String,
) -> String {
  // Build the standard Inertia HTML template with embedded JSON
  let page_data =
    json.object([
      #("component", json.string(component)),
      #("props", props),
      #("url", json.string(url)),
      #("version", json.string(version)),
    ])

  "<!DOCTYPE html>
<html>
<head>
  <title>My App</title>
  <script src=\"/assets/app.js\" defer></script>
</head>
<body>
  <div id=\"app\" data-page=\"" <> json.to_string(page_data) <> "\"></div>
</body>
</html>"
}
