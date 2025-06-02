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
import inertia_wisp/inertia

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
  use ctx <- inertia.middleware(
    req,
    inertia.default_config(),
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
import inertia_wisp/inertia.{type InertiaContext}

fn home_page(ctx: InertiaContext) -> wisp.Response {
  ctx
  |> inertia.assign_prop("message", json.string("Hello from Gleam!"))
  |> inertia.assign_prop("user", json.string("Alice"))
  |> inertia.assign_prop("count", json.int(42))
  |> inertia.render("Home")
}

fn about_page(ctx: inertia.InertiaContext) -> wisp.Response {
  inertia.render(ctx, "About")
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

## Testing

For testing Inertia applications, use the testing utilities:

```gleam
import inertia_wisp/testing
import gleam/should

pub fn test_home_page() {
  let req = testing.inertia_request()
  let response = my_handler(req)

  testing.component(response) |> should.equal(Ok("HomePage"))
  testing.prop(response, "title", decode.string)
    |> should.equal(Ok("Welcome"))
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
- ✅ **Props System**: Prop serialization with lazy evaluation
- ✅ **Always Props**: Global props on every request
- ✅ **Partial Reloads**: Performance optimization for large datasets
- ✅ **Asset Versioning**: Cache-busting and version mismatch handling
- ✅ **Server-Side Rendering**: Render full HTML responses for initial page loads

## Documentation

- **[API Documentation](https://hexdocs.pm/inertia_wisp)** - Complete API reference

## Contributing

Contributions are welcome!

## License

MIT
