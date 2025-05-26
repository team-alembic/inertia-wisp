# Inertia Gleam

[![Package Version](https://img.shields.io/hexpm/v/inertia_gleam)](https://hex.pm/packages/inertia_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/inertia_gleam/)

A modern server-side adapter for [Inertia.js](https://inertiajs.com/) built for Gleam and the [Wisp](https://github.com/gleam-wisp/wisp) web framework.

## What is Inertia.js?

Inertia.js allows you to build single-page applications using classic server-side routing and controllers, without the complexity of maintaining a separate API. You get the benefits of a SPA (no full page reloads) with the simplicity of server-side rendering.

This library provides the server-side adapter for Gleam applications, handling the Inertia.js protocol and providing a type-safe API for building modern web applications.

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

fn handle_request(req: inertia_gleam.InertiaContext, config: inertia_gleam.Config) -> wisp.Response {
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
fn home_page(req: inertia_gleam.InertiaContext) -> wisp.Response {
  req
  |> inertia_gleam.assign_prop("message", inertia_gleam.string_prop("Hello from Gleam!"))
  |> inertia_gleam.assign_prop("user", inertia_gleam.string_prop("Alice"))
  |> inertia_gleam.assign_prop("count", inertia_gleam.int_prop(42))
  |> inertia_gleam.render("Home")
}

fn about_page(req: inertia_gleam.InertiaContext) -> wisp.Response {
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
- **Pipe-friendly API**: Context-based prop assignment for clean, readable code
- **Middleware**: Automatic detection of Inertia requests via `X-Inertia` header
- **Multiple Routes**: Support for multiple pages and components
- **Response Headers**: Proper `X-Inertia` and `Vary` headers

### 🚧 Coming Soon

- **Asset Versioning**: Automatic page reloads when assets change
- **Server-Side Rendering**: Optional SSR support
- **Error Pages**: 404/500 handling through Inertia
- **Advanced Redirects**: External redirect handling

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

// Component with props (traditional approach)
let props = inertia_gleam.props_from_list([
  #("title", inertia_gleam.string_prop("My App")),
  #("items", inertia_gleam.int_list_to_json([1, 2, 3])),
])
inertia_gleam.render_inertia_with_props(req, "Dashboard", props)

// Component with props (pipe-friendly context approach)
req
|> inertia_gleam.assign_prop("title", inertia_gleam.string_prop("My App"))
|> inertia_gleam.assign_prop("items", inertia_gleam.int_list_to_json([1, 2, 3]))
|> inertia_gleam.assign_prop("user_count", inertia_gleam.int_prop(42))
|> inertia_gleam.render("Dashboard")
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

// Pipe-friendly context API
req
|> inertia_gleam.assign_prop("name", inertia_gleam.string_prop("Alice"))
|> inertia_gleam.assign_prop("age", inertia_gleam.int_prop(30))
|> inertia_gleam.render("UserProfile")
```

### Middleware

```gleam
// Add Inertia middleware to your request handler
fn handle_request(req: inertia_gleam.InertiaContext, config: inertia_gleam.Config) -> wisp.Response {
  use processed_req <- inertia_gleam.inertia_middleware(req, config)
  // Your route handling here...
}
```

## Testing

Run the included tests:

```sh
gleam test
```

## Examples

Check out the [`examples/`](examples/) directory for complete working examples:

- **[Minimal Example](examples/minimal/)**: Complete standalone Gleam app with React frontend, forms, validation, and file uploads

## Documentation

- **[API Documentation](https://hexdocs.pm/inertia_gleam)** - Complete API reference
- **[Development Setup](docs/development/setup.md)** - Getting started with development
- **[Testing Guide](docs/development/testing.md)** - Testing strategies and tools
- **[Implementation Plan](docs/development/implementation-plan.md)** - Development roadmap and architecture
- **[Example Application Guide](docs/examples/minimal-example.md)** - Comprehensive example walkthrough
- **[Frontend Development](docs/examples/frontend-development.md)** - React + TypeScript development guide

### Feature Documentation

- **[Always Props](docs/features/always-props.md)** - Global props on every request
- **[File Uploads](docs/features/file-uploads.md)** - File upload handling and validation

## Development Status

This package is production-ready with comprehensive features including:

- ✅ **Core Inertia Protocol**: HTML and JSON response handling
- ✅ **Props System**: Type-safe prop serialization with lazy evaluation
- ✅ **Form Handling**: Validation, errors, and redirects
- ✅ **File Uploads**: Multipart form data with validation
- ✅ **Always Props**: Global props on every request
- ✅ **Partial Reloads**: Performance optimization for large datasets

See the [implementation plan](docs/development/implementation-plan.md) for detailed feature status and roadmap.

## Contributing

Contributions are welcome! Please see the [implementation plan](docs/development/implementation-plan.md) for current priorities and development guidelines.

## License

Apache 2.0
