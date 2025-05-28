# Inertia Wisp

[![Package Version](https://img.shields.io/hexpm/v/inertia_wisp)](https://hex.pm/packages/inertia_wisp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/inertia_wisp/)

A modern server-side adapter for [Inertia.js](https://inertiajs.com/) built for Gleam and the [Wisp](https://github.com/gleam-wisp/wisp) web framework.

## What is Inertia.js?

Inertia.js allows you to build single-page applications using classic server-side routing and controllers, without the complexity of maintaining a separate API. You get the benefits of a SPA (no full page reloads) with the simplicity of server-side rendering.

This library provides the server-side adapter for Gleam applications, handling the Inertia.js protocol and providing a type-safe API for building modern web applications.

## Installation

```sh
gleam add inertia_wisp
```

## Quick Start

### 1. Basic Setup

```gleam
import gleam/erlang/process
import gleam/option
import mist
import wisp
import wisp/wisp_mist
import inertia_wisp

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
  use ctx <- inertia_wisp.inertia_middleware(
    req,
    inertia_wisp.default_config(),
    option.None  // No SSR supervisor
  )

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
import gleam/option

fn home_page(ctx: inertia_wisp.InertiaContext) -> wisp.Response {
  ctx
  |> inertia_wisp.assign_prop("message", json.string("Hello from Gleam!"))
  |> inertia_wisp.assign_prop("user", json.string("Alice"))
  |> inertia_wisp.assign_prop("count", json.int(42))
  |> inertia_wisp.render("Home")
}

fn about_page(ctx: inertia_wisp.InertiaContext) -> wisp.Response {
  inertia_wisp.render(ctx, "About")
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
let config = inertia_wisp.default_config()

// The middleware accepts config, optional SSR supervisor, and initializes the InertiaContext
use ctx <- inertia_wisp.inertia_middleware(req, config, option.None)
```

### Rendering Pages

```gleam
import gleam/json

// Simple component without props
inertia_wisp.render(ctx, "Dashboard")

// Component with props using pipe-friendly API
ctx
|> inertia_wisp.assign_prop("title", json.string("My App"))
|> inertia_wisp.assign_prop("items", json.array([json.int(1), json.int(2)], json.int))
|> inertia_wisp.assign_prop("user_count", json.int(42))
|> inertia_wisp.render("Dashboard")

// Multiple props at once
ctx
|> inertia_wisp.assign_props([
  #("name", json.string("Alice")),
  #("age", json.int(30)),
])
|> inertia_wisp.render("UserProfile")
```

### Always Props (Global Props)

```gleam
// Props that appear on every page
ctx
|> inertia_wisp.assign_always_props([
  #("auth", json.object([
    #("authenticated", json.bool(True)),
    #("user", json.string("demo_user")),
  ])),
  #("csrf_token", json.string("abc123xyz")),
])
|> inertia_wisp.render("SomePage")
```

### Lazy Props

```gleam
// Props that are only evaluated when needed (for performance)
ctx
|> inertia_wisp.assign_lazy_prop("expensive_data", fn() {
  // This function only runs if the prop is requested
  fetch_expensive_computation()
})
|> inertia_wisp.render("Dashboard")
```

### Redirects

```gleam
// Standard redirect
inertia_wisp.redirect(ctx, "/users")

// External redirect (full page reload)
inertia_wisp.external_redirect("https://example.com")
```

### Middleware

```gleam
fn handle_request(req: wisp.Request) -> wisp.Response {
  // The middleware accepts config, optional SSR supervisor, and creates InertiaContext
  use ctx <- inertia_wisp.inertia_middleware(
    req,
    inertia_wisp.default_config(),
    option.None  // No SSR supervisor
  )

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
pub fn create_user(ctx: inertia_wisp.InertiaContext) -> wisp.Response {
  use json_data <- wisp.require_json(ctx.request)

  case validate_user_data(json_data) {
    Ok(user) -> {
      // Save user and redirect
      inertia_wisp.redirect(ctx, "/users")
    }
    Error(errors) -> {
      // Return form with errors
      ctx
      |> inertia_wisp.assign_errors(errors)
      |> inertia_wisp.assign_prop("old", json_data)
      |> inertia_wisp.render("CreateUser")
    }
  }
}
```

## File Uploads

File uploads are handled through Wisp's built-in FormData mechanisms:

```gleam
pub fn handle_upload(ctx: inertia_wisp.InertiaContext) -> wisp.Response {
  use form_data <- wisp.require_form(ctx.request)

  // Process uploaded files from form_data.files
  let uploaded_files = process_files(form_data.files)

  ctx
  |> inertia_wisp.assign_prop("uploaded_files", serialize_files(uploaded_files))
  |> inertia_wisp.render("UploadSuccess")
}
```

## Examples

Check out the [`examples/`](examples/) directory for complete working examples:

- **[Demo Example](examples/demo/)**: Complete standalone Gleam app with React frontend, forms, validation, and file uploads

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

- **[API Documentation](https://hexdocs.pm/inertia_wisp)** - Complete API reference
- **[Example Application Guide](docs/examples/demo-example.md)** - Comprehensive example walkthrough

## Contributing

Contributions are welcome! The library maintains a focused scope on the core Inertia.js protocol while providing examples for common patterns like validation and file handling.

## License

Apache 2.0
