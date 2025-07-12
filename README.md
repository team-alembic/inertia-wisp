# Inertia Wisp

[![Package Version](https://img.shields.io/hexpm/v/inertia_wisp)](https://hex.pm/packages/inertia_wisp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/inertia_wisp/)

A modern server-side adapter for [Inertia.js](https://inertiajs.com/) built for Gleam and the [Wisp](https://github.com/gleam-wisp/wisp) web framework. Features a clean, type-safe API for building single-page applications with server-side rendering.

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
import gleam/json
import mist
import wisp
import wisp/wisp_mist
import inertia_wisp/inertia
import inertia_wisp/internal/types

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
  use <- wisp.serve_static(req, from: "./static", under: "/static")
  
  case wisp.path_segments(req) {
    [] -> home_page(req)
    ["about"] -> about_page(req)
    _ -> wisp.not_found()
  }
}
```

### 2. Create Your Pages

Define your page props types and create pages:

```gleam
import gleam/json
import inertia_wisp/inertia
import inertia_wisp/internal/types

// Define your props as a union type
pub type HomePageProp {
  Message(message: String)
  User(user: String)
  Count(count: Int)
}

// Create encoder for your props
fn encode_home_page_prop(prop: HomePageProp) -> #(String, json.Json) {
  case prop {
    Message(message) -> #("message", json.string(message))
    User(user) -> #("user", json.string(user))
    Count(count) -> #("count", json.int(count))
  }
}

fn home_page(req: wisp.Request) -> wisp.Response {
  let props = [
    types.DefaultProp("message", Message("Hello from Gleam!")),
    types.DefaultProp("user", User("Alice")),
    types.DefaultProp("count", Count(42)),
  ]
  
  let page = inertia.eval(req, "Home", props, encode_home_page_prop)
  inertia.render(req, page)
}

fn about_page(req: wisp.Request) -> wisp.Response {
  let page = inertia.eval(req, "About", [], fn(_) { #("", json.null()) })
  inertia.render(req, page)
}
```

### 3. Frontend Setup (React)

Create your React components that correspond to your Gleam page components:

```jsx
// Home.jsx
import { Link } from '@inertiajs/react'

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
import { Link } from '@inertiajs/react'

export default function About() {
  return (
    <div>
      <h1>About Page</h1>
      <Link href="/">Back to Home</Link>
    </div>
  );
}
```

## Advanced Usage

### Different Prop Types

```gleam
import gleam/dict

fn dashboard_page(req: wisp.Request) -> wisp.Response {
  let props = [
    // Always included in every request (even partial reloads)
    types.AlwaysProp("auth", get_current_user()),
    
    // Included on standard visits, optional on partial reloads
    types.DefaultProp("stats", get_user_stats()),
    
    // Only evaluated when explicitly requested in partial reloads
    types.OptionalProp("debug", fn() { get_debug_info() }),
    
    // Lazy evaluation - only computed when needed
    types.LazyProp("notifications", fn() { get_notifications() }),
    
    // Deferred - loaded separately after initial page render
    types.DeferProp("analytics", option.None, fn() { get_analytics_data() }),
  ]
  
  let page = inertia.eval(req, "Dashboard", props, encode_dashboard_prop)
  
  // Add validation errors if present
  let page_with_errors = case get_validation_errors() {
    Ok(errors) -> inertia.errors(page, errors)
    Error(_) -> page
  }
  
  inertia.render(req, page_with_errors)
}
```

### Form Handling and Validation

```gleam
import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode

pub fn create_user(req: wisp.Request) -> wisp.Response {
  use form_data <- wisp.require_form(req)
  
  case validate_user_form(form_data) {
    Ok(user) -> {
      // Save user and redirect
      save_user(user)
      wisp.redirect("/users")
    }
    Error(validation_errors) -> {
      // Re-render form with errors
      let props = [
        types.DefaultProp("form_data", form_data),
      ]
      let page = inertia.eval(req, "Users/Create", props, encode_user_prop)
      let page_with_errors = inertia.errors(page, validation_errors)
      inertia.render(req, page_with_errors)
    }
  }
}

fn validate_user_form(form_data) -> Result(User, dict.Dict(String, String)) {
  // Your validation logic here
  todo
}
```

## Examples

Check out the [`examples/`](examples/) directory for complete working examples:

- **[Demo Example](examples/demo/)**: Complete Gleam app with React frontend using the context-based API
- **[Typed Demo](examples/typed-demo/)**: Advanced example with TypeScript integration and modular structure  
- **[Simple Demo](examples/simple-demo/)**: Clean example showcasing the new eval-based API (coming soon)

The examples demonstrate:

- Different prop types and their behaviors
- Partial reloads for performance optimization
- Form validation and error handling
- File upload handling using Wisp's FormData
- Deferred props for heavy background operations
- CRUD operations with proper redirects

## Development Status

This package provides a complete, focused Inertia.js adapter with:

- ✅ **Core Inertia Protocol**: Full compatibility with Inertia.js client libraries
- ✅ **Type-Safe Props**: Compile-time prop validation with Gleam's type system
- ✅ **Multiple Prop Types**: `DefaultProp`, `LazyProp`, `OptionalProp`, `AlwaysProp`, `DeferProp`, `MergeProp`
- ✅ **Partial Reloads**: Performance optimization for large datasets
- ✅ **Deferred Props**: Background data loading with grouping support
- ✅ **Error Handling**: Built-in form validation error support
- ✅ **Asset Versioning**: Cache-busting and version mismatch handling
- ✅ **Server-Side Rendering**: SSR support with graceful CSR fallback
- ✅ **Clean API**: Direct Page construction without context objects

## Documentation

- **[API Documentation](https://hexdocs.pm/inertia_wisp)** - Complete API reference

## Contributing

Contributions are welcome!

## License

MIT
