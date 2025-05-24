# Inertia Gleam

[![Package Version](https://img.shields.io/hexpm/v/inertia_gleam)](https://hex.pm/packages/inertia_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/inertia_gleam/)

A modern server-side adapter for [Inertia.js](https://inertiajs.com/) built for Gleam and the [Wisp](https://github.com/gleam-wisp/wisp) web framework.

## What is Inertia.js?

Inertia.js allows you to build single-page applications using classic server-side routing and controllers, without the complexity of maintaining a separate API. You get the benefits of a SPA (no full page reloads) with the simplicity of server-side rendering.

## Installation

```sh
gleam add inertia_gleam
```

## Quick Start

### 1. Basic Setup

```gleam
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist
import inertia_gleam

pub fn main() {
  wisp.configure_logger()
  
  let config = inertia_gleam.default_config()
  
  let assert Ok(_) =
    fn(req) { handle_request(req, config) }
    |> wisp_mist.handler("your_secret_key")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn handle_request(req: wisp.Request, config: inertia_gleam.Config) -> wisp.Response {
  use _req <- inertia_gleam.inertia_middleware(req, config)
  
  case wisp.path_segments(req) {
    [] -> home_page(req)
    ["about"] -> about_page(req)
    _ -> wisp.not_found()
  }
}
```

### 2. Create Your Pages

```gleam
fn home_page(req: wisp.Request) -> wisp.Response {
  let props = inertia_gleam.props_from_list([
    #("message", inertia_gleam.string_prop("Hello from Gleam!")),
    #("user", inertia_gleam.string_prop("Alice")),
    #("count", inertia_gleam.int_prop(42)),
  ])
  
  inertia_gleam.render_inertia_with_props(req, "Home", props)
}

fn about_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.render_inertia(req, "About")
}
```

### 3. Frontend Setup (React)

Create your React components that correspond to your Gleam page components:

```jsx
// Home.jsx
export default function Home({ message, user, count }) {
  return (
    <div>
      <h1>Welcome {user}!</h1>
      <p>{message}</p>
      <p>Count: {count}</p>
      <Link href="/about">Go to About</Link>
    </div>
  );
}

// About.jsx
export default function About() {
  return (
    <div>
      <h1>About Page</h1>
      <Link href="/">Back to Home</Link>
    </div>
  );
}
```

## Features

### ✅ Current Features (Phase 0)

- **Basic Inertia Protocol**: Handles initial page loads (HTML) and navigation (JSON)
- **Component Rendering**: `render_inertia(req, "ComponentName")`
- **Props Support**: Type-safe prop helpers for strings, integers, booleans, and lists
- **Middleware**: Automatic detection of Inertia requests via `X-Inertia` header
- **Multiple Routes**: Support for multiple pages and components
- **Response Headers**: Proper `X-Inertia` and `Vary` headers

### 🚧 Coming Soon

- **Form Handling**: POST requests with validation errors
- **Lazy Props**: Props that are only evaluated when requested
- **Partial Reloads**: Request only specific props for performance
- **Asset Versioning**: Automatic page reloads when assets change
- **Redirects**: Proper redirect handling for SPAs
- **Server-Side Rendering**: Optional SSR support

## API Reference

### Configuration

```gleam
// Default configuration
let config = inertia_gleam.default_config()

// Custom configuration
let config = inertia_gleam.config("2.0", True) // version, ssr
```

### Rendering Pages

```gleam
// Simple component without props
inertia_gleam.render_inertia(req, "Dashboard")

// Component with props
let props = inertia_gleam.props_from_list([
  #("title", inertia_gleam.string_prop("My App")),
  #("items", inertia_gleam.int_list_to_json([1, 2, 3])),
])
inertia_gleam.render_inertia_with_props(req, "Dashboard", props)
```

### Prop Helpers

```gleam
// Basic types
inertia_gleam.string_prop("hello")
inertia_gleam.int_prop(42)
inertia_gleam.bool_prop(True)

// Lists
inertia_gleam.string_list_to_json(["a", "b", "c"])
inertia_gleam.int_list_to_json([1, 2, 3])

// Create props dictionary
inertia_gleam.props_from_list([
  #("name", inertia_gleam.string_prop("Alice")),
  #("age", inertia_gleam.int_prop(30)),
])
```

### Middleware

```gleam
// Add Inertia middleware to your request handler
fn handle_request(req: wisp.Request, config: inertia_gleam.Config) -> wisp.Response {
  use processed_req <- inertia_gleam.inertia_middleware(req, config)
  // Your route handling here...
}
```

## Testing

Run the included tests:

```sh
gleam test
```

Test the example server:

```sh
cd examples/minimal
gleam run
# Server starts on http://localhost:8000
```

Test with curl:

```sh
# Browser request (returns HTML)
curl http://localhost:8000/

# Inertia request (returns JSON)
curl -H "X-Inertia: true" http://localhost:8000/
```

## Examples

Check out the `/examples` directory for complete working examples:

- **Minimal Example**: Complete standalone Gleam app with React frontend and ESBuild setup

## Development Status

This package is currently in **Phase 0** - basic proof of concept. It successfully demonstrates:

- Server-side routing with Inertia.js protocol
- Seamless navigation between pages without full reloads
- Type-safe prop serialization
- React frontend integration

See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for the complete roadmap.

## Contributing

Contributions are welcome! Please see the implementation plan for current priorities.

## Documentation

Further documentation can be found at <https://hexdocs.pm/inertia_gleam>.

## License

Apache 2.0