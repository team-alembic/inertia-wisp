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

  let assert Ok(_) =
    fn(req) { handle_request(req) }
    |> wisp_mist.handler("your_secret_key")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn handle_request(req: wisp.Request) -> wisp.Response {
  use ctx <- inertia_gleam.inertia_middleware(req, inertia_gleam.default_config())

  case wisp.path_segments(req) {
    [] -> home_page(ctx)
    ["about"] -> about_page(ctx)
    _ -> wisp.not_found()
  }
}
```

### 2. Create Your Pages

```gleam
import gleam/json

fn home_page(ctx: inertia_gleam.InertiaContext) -> wisp.Response {
  ctx
  |> inertia_gleam.assign_prop("message", json.string("Hello from Gleam!"))
  |> inertia_gleam.assign_prop("user", json.string("Alice"))
  |> inertia_gleam.assign_prop("count", json.int(42))
  |> inertia_gleam.render("Home")
}

fn about_page(ctx: inertia_gleam.InertiaContext) -> wisp.Response {
  inertia_gleam.render(ctx, "About")
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

## Core Features

- **Inertia Protocol**: Handles initial page loads (HTML) and navigation (JSON)
- **Component Rendering**: Simple `render(ctx, "ComponentName")` API
- **Props Support**: Type-safe prop assignment using Gleam's JSON library
- **Context-based API**: Clean, pipe-friendly prop assignment
- **Middleware**: Automatic detection and handling of Inertia requests
- **Asset Versioning**: Support for cache-busting and version mismatches
- **Always Props**: Global props included on every request
- **Lazy Props**: Performance optimization with lazy evaluation
- **Partial Reloads**: Selective prop loading for large datasets

## API Reference

### Configuration

```gleam
// Default configuration
let config = inertia_gleam.default_config()

// The middleware accepts config and initializes the InertiaContext
use ctx <- inertia_gleam.inertia_middleware(req, config)
```

### Rendering Pages

```gleam
import gleam/json

// Simple component without props
inertia_gleam.render(ctx, "Dashboard")

// Component with props using pipe-friendly API
ctx
|> inertia_gleam.assign_prop("title", json.string("My App"))
|> inertia_gleam.assign_prop("items", json.array([json.int(1), json.int(2)], json.int))
|> inertia_gleam.assign_prop("user_count", json.int(42))
|> inertia_gleam.render("Dashboard")

// Multiple props at once
ctx
|> inertia_gleam.assign_props([
  #("name", json.string("Alice")),
  #("age", json.int(30)),
])
|> inertia_gleam.render("UserProfile")
```

### Always Props (Global Props)

```gleam
// Props that appear on every page
ctx
|> inertia_gleam.assign_always_props([
  #("auth", json.object([
    #("authenticated", json.bool(True)),
    #("user", json.string("demo_user")),
  ])),
  #("csrf_token", json.string("abc123xyz")),
])
|> inertia_gleam.render("SomePage")
```

### Lazy Props

```gleam
// Props that are only evaluated when needed (for performance)
ctx
|> inertia_gleam.assign_lazy_prop("expensive_data", fn() {
  // This function only runs if the prop is requested
  fetch_expensive_computation()
})
|> inertia_gleam.render("Dashboard")
```

### Redirects

```gleam
// Standard redirect
inertia_gleam.redirect(ctx, "/users")

// External redirect (full page reload)
inertia_gleam.external_redirect("https://example.com")
```

### Middleware

```gleam
fn handle_request(req: wisp.Request) -> wisp.Response {
  // The middleware accepts config and creates InertiaContext
  use ctx <- inertia_gleam.inertia_middleware(req, inertia_gleam.default_config())
  
  // Your route handling with the context
  case wisp.path_segments(req) {
    [] -> home_page(ctx)
    _ -> wisp.not_found()
  }
}
```

## Form Handling and Validation

Inertia Gleam focuses on the core Inertia protocol. Form validation and error handling are implemented in your application using Wisp's form handling:

```gleam
pub fn create_user(ctx: inertia_gleam.InertiaContext) -> wisp.Response {
  use json_data <- wisp.require_json(ctx.request)
  
  case validate_user_data(json_data) {
    Ok(user) -> {
      // Save user and redirect
      inertia_gleam.redirect(ctx, "/users")
    }
    Error(errors) -> {
      // Return form with errors
      ctx
      |> inertia_gleam.assign_errors(errors)
      |> inertia_gleam.assign_prop("old", json_data)
      |> inertia_gleam.render("CreateUser")
    }
  }
}
```

## File Uploads

File uploads are handled through Wisp's built-in FormData mechanisms:

```gleam
pub fn handle_upload(ctx: inertia_gleam.InertiaContext) -> wisp.Response {
  use form_data <- wisp.require_form(ctx.request)
  
  // Process uploaded files from form_data.files
  let uploaded_files = process_files(form_data.files)
  
  ctx
  |> inertia_gleam.assign_prop("uploaded_files", serialize_files(uploaded_files))
  |> inertia_gleam.render("UploadSuccess")
}
```

## Examples

Check out the [`examples/`](examples/) directory for complete working examples:

- **[Minimal Example](examples/minimal/)**: Complete standalone Gleam app with React frontend, forms, validation, and file uploads

The example demonstrates:
- Form validation (implemented in the example, not the core library)
- File upload handling using Wisp's FormData
- Error handling and display
- CRUD operations with redirects

## Development Status

This package provides a complete, focused Inertia.js adapter with:

- ✅ **Core Inertia Protocol**: HTML and JSON response handling
- ✅ **Props System**: Type-safe prop serialization with lazy evaluation  
- ✅ **Always Props**: Global props on every request
- ✅ **Partial Reloads**: Performance optimization for large datasets
- ✅ **Asset Versioning**: Cache-busting and version mismatch handling
- ✅ **Context-based API**: Clean, pipe-friendly prop assignment
- ✅ **Middleware**: Automatic request detection and context initialization

Form validation and file upload handling are demonstrated in the examples but kept separate from the core adapter to maintain simplicity and flexibility.

## Documentation

- **[API Documentation](https://hexdocs.pm/inertia_gleam)** - Complete API reference
- **[Example Application Guide](docs/examples/minimal-example.md)** - Comprehensive example walkthrough

## Contributing

Contributions are welcome! The library maintains a focused scope on the core Inertia.js protocol while providing examples for common patterns like validation and file handling.

## License

Apache 2.0