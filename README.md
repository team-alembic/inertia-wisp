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
import gleam/json
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

Define your page props types and create pages:

```gleam
import gleam/json
import inertia_wisp/inertia.{type InertiaContext}

// Define your props as a union type
pub type HomePageProp {
  Message(message: String)
  User(user: String)
  Count(count: Int)
}

// Create encoder for your props
fn encode_home_page_prop(prop: HomePageProp) -> json.Json {
  case prop {
    Message(message) -> json.string(message)
    User(user) -> json.string(user)
    Count(count) -> json.int(count)
  }
}

fn home_page(ctx: InertiaContext(Nil)) -> wisp.Response {
  ctx
  |> inertia.with_encoder(encode_home_page_prop)
  |> inertia.prop("message", Message("Hello from Gleam!"))
  |> inertia.prop("user", User("Alice"))
  |> inertia.prop("count", Count(42))
  |> inertia.render("Home")
}

fn about_page(ctx: InertiaContext(Nil)) -> wisp.Response {
  inertia.render(ctx, "About")
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
// Always included props (included in all requests)
ctx
|> inertia.always_prop("auth", current_user)

// Optional props (only included when specifically requested)
ctx  
|> inertia.optional_prop("debug", fn() { get_debug_info() })

// Validation errors
let errors = dict.from_list([
  #("email", "Email is required"),
  #("password", "Password must be at least 8 characters"),
])
ctx |> inertia.errors(errors)
```

### JSON Request Handling

```gleam
import gleam/dynamic/decode

pub fn create_user(ctx: InertiaContext(Nil)) -> wisp.Response {
  use user_data <- inertia.require_json(ctx, user_decoder())
  // user_data is now the decoded user struct
  // ... handle the user creation logic
  inertia.redirect(ctx.request, "/users")
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
