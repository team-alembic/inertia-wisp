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
  use <- wisp.serve_static(req, from: "./static", under: "/static")

  case wisp.path_segments(req) {
    [] -> home_page(req)
    ["about"] -> about_page(req)
    _ -> wisp.not_found()
  }
}
```

### 2. Create Your Pages

Define your page props type and create pages:

```gleam
import gleam/dict
import gleam/json
import inertia_wisp/inertia

// Define your props type
pub type HomePageProps {
  HomePageProps(
    message: String,
    user: String,
    count: Int,
  )
}

// Create encoder for your props
fn encode_home_page_props(props: HomePageProps) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("message", json.string(props.message)),
    #("user", json.string(props.user)),
    #("count", json.int(props.count)),
  ])
}

fn home_page(req: wisp.Request) -> wisp.Response {
  let props = HomePageProps(
    message: "Hello from Gleam!",
    user: "Alice",
    count: 42,
  )

  req
  |> inertia.response_builder("Home")
  |> inertia.props(props, encode_home_page_props)
  |> inertia.response(200)
}

fn about_page(req: wisp.Request) -> wisp.Response {
  let props = AboutPageProps(title: "About Us")

  req
  |> inertia.response_builder("About")
  |> inertia.props(props, encode_about_page_props)
  |> inertia.response(200)
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

export default function About({ title }) {
  return (
    <div>
      <h1>{title}</h1>
      <Link href="/">Back to Home</Link>
    </div>
  );
}
```

## Advanced Usage

### Lazy, Optional, and Always Props

```gleam
import gleam/option.{type Option}

pub type DashboardProps {
  DashboardProps(
    auth: User,              // Always included
    stats: Stats,            // Default prop
    notifications: Option(List(Notification)),  // Lazy-loaded
  )
}

fn dashboard_page(req: wisp.Request) -> wisp.Response {
  let props = DashboardProps(
    auth: get_current_user(req),
    stats: get_user_stats(),
    notifications: option.None,  // Not loaded initially
  )

  req
  |> inertia.response_builder("Dashboard")
  |> inertia.props(props, encode_dashboard_props)
  |> inertia.always("auth")  // Include in all requests, even partial reloads
  |> inertia.lazy("notifications", fn(props) {
      // Lazy evaluation - only computed when needed
      Ok(DashboardProps(
        ..props,
        notifications: option.Some(get_notifications()),
      ))
    })
  |> inertia.response(200)
}
```

### Deferred Props

Deferred props are loaded after the initial page render, perfect for heavy background operations:

```gleam
import gleam/option.{type Option, Some, None}
import gleam/erlang/process

pub type AnalyticsPageProps {
  AnalyticsPageProps(
    basic_stats: Stats,
    heavy_report: Option(Report),
  )
}

fn analytics_page(req: wisp.Request) -> wisp.Response {
  let props = AnalyticsPageProps(
    basic_stats: get_basic_stats(),
    heavy_report: None,
  )

  req
  |> inertia.response_builder("Analytics")
  |> inertia.props(props, encode_analytics_props)
  |> inertia.defer("heavy_report", fn(props) {
      // This runs in a separate request after page loads
      process.sleep(2000)  // Simulate expensive operation
      Ok(AnalyticsPageProps(
        ..props,
        heavy_report: Some(generate_heavy_report()),
      ))
    })
  |> inertia.response(200)
}
```

### Form Handling and Validation

```gleam
import gleam/dict

pub type ContactFormProps {
  ContactFormProps(
    name: String,
    email: String,
    message: String,
  )
}

pub fn show_contact_form(req: wisp.Request) -> wisp.Response {
  let props = ContactFormProps(name: "", email: "", message: "")

  req
  |> inertia.response_builder("ContactForm")
  |> inertia.props(props, encode_contact_form_props)
  |> inertia.response(200)
}

pub fn submit_contact_form(req: wisp.Request) -> wisp.Response {
  use json_data <- wisp.require_json(req)

  let form_data = decode_contact_form(json_data)

  case validate_contact_form(form_data) {
    Ok(_) -> {
      // Success - redirect
      wisp.redirect("/thank-you")
    }
    Error(validation_errors) -> {
      // Re-render with errors
      req
      |> inertia.response_builder("ContactForm")
      |> inertia.errors(validation_errors)
      |> inertia.redirect("/contact")
    }
  }
}

fn validate_contact_form(form) -> Result(_, dict.Dict(String, String)) {
  let errors = dict.new()

  // Add validation logic
  let errors = case form.email {
    "" -> dict.insert(errors, "email", "Email is required")
    _ -> errors
  }

  case dict.is_empty(errors) {
    True -> Ok(form)
    False -> Error(errors)
  }
}
```

### Merge Props

Merge props allow efficient client-side merging of data, useful for infinite scroll or pagination:

```gleam
import gleam/option

pub type UsersListProps {
  UsersListProps(
    users: List(User),
    page: Int,
  )
}

fn users_list(req: wisp.Request, page: Int) -> wisp.Response {
  let props = UsersListProps(
    users: get_users(page),
    page: page,
  )

  req
  |> inertia.response_builder("UsersList")
  |> inertia.props(props, encode_users_list_props)
  |> inertia.merge("users", match_on: option.Some(["id"]), deep: False)
  |> inertia.response(200)
}
```

## Examples

Check out the [`examples/presentation/`](examples/presentation/) directory for a complete working example:

- **Contact Form**: Form validation with error handling
- **Paginated Table**: Partial reloads for efficient pagination
- **Presentation Slides**: Complex navigation with multi-step content
- **Deferred Props**: Background data loading demonstration

The examples demonstrate:
- Record-based props with type-safe encoders
- Lazy and deferred prop evaluation
- Form validation and error handling
- Partial reloads for performance
- Always props for shared data
- Merge props for efficient data updates

## Documentation

- **[API Documentation](https://hexdocs.pm/inertia_wisp)** - Complete API reference
- **[Inertia.js Documentation](https://inertiajs.com/)** - Official Inertia.js docs

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT
