# Inertia Wisp

[![Package Version](https://img.shields.io/hexpm/v/inertia_wisp)](https://hex.pm/packages/inertia_wisp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/inertia_wisp/)

An [Inertia.js](https://inertiajs.com/) adapter for Gleam and the [Wisp](https://github.com/gleam-wisp/wisp) web framework.

## Installation

```sh
gleam add inertia_wisp
```

## Quick Start

### 1. Define Your HTML Layout

First, create a layout function that generates your HTML document structure. You can use Lustre's HTML builder or the built-in default layout:

```gleam
// src/layout.gleam
import gleam/json
import lustre/attribute
import lustre/element
import lustre/element/html

/// Custom HTML layout built with Lustre
pub fn html_layout(component_name: String, app_data: json.Json) -> String {
  html.html([attribute.attribute("lang", "en")], [
    html.head([], [
      html.meta([attribute.attribute("charset", "utf-8")]),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1"),
      ]),
      html.title([], component_name),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/css/styles.css"),
      ]),
    ]),
    html.body([], [
      html.div(
        [
          attribute.id("app"),
          attribute.attribute("data-page", json.to_string(app_data)),
        ],
        [],
      ),
      html.script(
        [attribute.type_("module"), attribute.src("/static/js/main.js")],
        "",
      ),
    ]),
  ])
  |> element.to_document_string()
}
```

Alternatively, use the built-in default layout:

```gleam
import inertia_wisp/html

// Use html.default_layout for a simple starting point
```

### 2. Basic Server Setup

```gleam
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist
import inertia_wisp/inertia
import layout  // Your custom layout module

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

### 3. Create Your Pages

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
  |> inertia.response(200, layout.html_layout)
}

fn about_page(req: wisp.Request) -> wisp.Response {
  let props = AboutPageProps(title: "About Us")

  req
  |> inertia.response_builder("About")
  |> inertia.props(props, encode_about_page_props)
  |> inertia.response(200, layout.html_layout)
}
```

### 4. Frontend Setup

#### Install Dependencies

Create a `frontend/` directory and add a `package.json`. You can use your preferred JavaScript build tools; this example uses ESBuild with code splitting enabled:

```json
{
  "name": "my-app-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "build": "esbuild src/main.tsx --bundle --outdir=../priv/static/js --format=esm --splitting --jsx=automatic --minify",
    "watch": "esbuild src/main.tsx --bundle --outdir=../priv/static/js --format=esm --splitting --jsx=automatic --watch"
  },
  "dependencies": {
    "@inertiajs/react": "^2.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "esbuild": "^0.19.0",
    "typescript": "^5.3.0"
  }
}
```

Install dependencies:

```bash
npm install
```

#### Create Entry Point

Create `src/main.tsx`:

```typescript
import React from "react";
import { createRoot } from "react-dom/client";
import { createInertiaApp } from "@inertiajs/react";

createInertiaApp({
  title: (title) => `${title} - My App`,
  resolve: async (name) => {
    const module = await import(`./Pages/${name}.tsx`);
    return module.default;
  },
  setup({ el, App, props }) {
    const root = createRoot(el);
    root.render(<App {...props} />);
  },
  progress: {
    color: "#9333ea",
  },
});
```

#### Create React Components

Create your React components in `src/Pages/` that correspond to your Gleam page components:

```tsx
// src/Pages/Home.tsx
import { Link } from '@inertiajs/react'

export default function Home({ message, user, count }: {
  message: string;
  user: string;
  count: number;
}) {
  return (
    <div>
      <h1>Welcome {user}!</h1>
      <p>{message}</p>
      <p>Count: {count}</p>
      <Link href="/about">Go to About</Link>
    </div>
  );
}

// src/Pages/About.tsx
import { Link } from '@inertiajs/react'

export default function About({ title }: { title: string }) {
  return (
    <div>
      <h1>{title}</h1>
      <Link href="/">Back to Home</Link>
    </div>
  );
}
```

#### Build Your Frontend

From the `frontend/` directory, build for production:

```bash
npm run build
```

Or watch for changes during development:

```bash
npm run watch
```

This will output your bundled JavaScript to `../priv/static/js/`, which your Gleam server will serve.

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
  |> inertia.response(200, layout.html_layout)
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
  |> inertia.response(200, layout.html_layout)
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
  |> inertia.response(200, layout.html_layout)
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
  |> inertia.response(200, layout.html_layout)
}
```

## Sharing Types Between Frontend and Backend

For larger applications, you can share types, encoders, decoders, and validation logic between your Gleam backend and TypeScript frontend by creating a separate `shared` package.

### Repository Structure

Organize your project with three packages:

```
my-app/
├── backend/           # Gleam backend (target: erlang)
│   ├── src/
│   ├── gleam.toml
│   └── priv/static/   # Compiled frontend assets
├── frontend/          # TypeScript/React frontend
│   ├── src/
│   ├── package.json
│   └── tsconfig.json
└── shared/            # Shared Gleam code (target: javascript)
    ├── src/shared/
    ├── gleam.toml
    └── manifest.toml
```

### Setting Up the Shared Package

Create `shared/gleam.toml`:

```toml
name = "shared"
version = "1.0.0"
target = "javascript"

[dependencies]
gleam_stdlib = ">= 0.60.0"
gleam_json = ">= 3.0.0"

[javascript]
typescript_declarations = true
```

### Define Shared Types and Codecs

Create `shared/src/shared/todo_item.gleam`:

```gleam
import gleam/dict
import gleam/dynamic/decode
import gleam/json.{type Json}

// Types
pub type Todo {
  Todo(id: Int, text: String, completed: Bool)
}

pub type TodoProps {
  TodoProps(todos: List(Todo))
}

pub type AddTodoRequest {
  AddTodoRequest(text: String)
}

// Encoders (Gleam → JSON)
pub fn encode_todo(item: Todo) -> Json {
  json.object([
    #("id", json.int(item.id)),
    #("text", json.string(item.text)),
    #("completed", json.bool(item.completed)),
  ])
}

pub fn encode_todo_props(props: TodoProps) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("todos", json.array(props.todos, encode_todo)),
  ])
}

pub fn encode_add_todo_request(request: AddTodoRequest) -> Json {
  json.object([#("text", json.string(request.text))])
}

// Decoders (JSON → Gleam)
pub fn decode_todo() -> decode.Decoder(Todo) {
  use id <- decode.field("id", decode.int)
  use text <- decode.field("text", decode.string)
  use completed <- decode.field("completed", decode.bool)
  decode.success(Todo(id:, text:, completed:))
}

pub fn decode_todo_props() -> decode.Decoder(TodoProps) {
  use todos <- decode.field("todos", decode.list(decode_todo()))
  decode.success(TodoProps(todos:))
}

pub fn decode_add_todo_request() -> decode.Decoder(AddTodoRequest) {
  use text <- decode.field("text", decode.string)
  decode.success(AddTodoRequest(text:))
}
```

### Using Shared Types in Backend

Add the shared package to `backend/gleam.toml`:

```toml
[dependencies]
shared = { path = "../shared" }
```

Use the shared types in your handlers:

```gleam
import shared/todo_item.{Todo, TodoProps, AddTodoRequest}
import gleam/dynamic/decode

pub fn show_todos(req: Request) -> Response {
  let props = TodoProps(todos: [])

  req
  |> inertia.response_builder("TodoList")
  |> inertia.props(props, todo_item.encode_todo_props)
  |> inertia.response(200, layout.html_layout)
}

pub fn add_todo_item(req: Request) -> Response {
  use json_body <- wisp.require_json(req)
  let assert Ok(add_request) = decode.run(json_body, todo_item.decode_add_todo_request())

  let new_item = Todo(id: generate_id(), text: add_request.text, completed: False)
  let props = TodoProps(todos: [new_item])

  req
  |> inertia.response_builder("TodoList")
  |> inertia.props(props, todo_item.encode_todo_props)
  |> inertia.merge("todos", match_on: option.Some(["id"]), deep: False)
  |> inertia.response(200, layout.html_layout)
}
```

### Using Shared Types in Frontend

Configure TypeScript to find the compiled Gleam code. Update `frontend/tsconfig.json`:

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@gleam/*": ["../shared/build/dev/javascript/*"]
      "@shared/*": ["../shared/build/dev/javascript/shared/shared/*"]
    }
  }
}
```

Gleam 1.13 and later compiles to JavaScript with verbose accessor names. Create a wrapper file to re-export with cleaner names:

```typescript
// frontend/src/lib/todo_item.ts
export {
  // Types
  type Todo$,
  type TodoProps$,
  type AddTodoRequest$,
  // Constructors
  Todo$Todo as createTodo,
  AddTodoRequest$AddTodoRequest as createAddTodoRequest,
  // Accessors
  TodoProps$TodoProps$todos as getTodos,
  Todo$Todo$id as getId,
  Todo$Todo$text as getText,
  Todo$Todo$completed as getCompleted,
  // Codecs
  decode_todo_props,
  encode_add_todo_request,
} from "@shared/todo_item.mjs";
```

Use the shared types in your React components:

```tsx
// frontend/src/Pages/TodoList.tsx
import { router } from "@inertiajs/react";
import * as TodoItem from "../lib/todo_item";

function TodoList(props: TodoItem.TodoProps$) {
  const todos = Array.from(TodoItem.getTodos(props));

  const handleAddTodo = (text: string) => {
    const request = TodoItem.createAddTodoRequest(text);
    router.post("/todo/add", TodoItem.encode_add_todo_request(request), {
      preserveScroll: true,
      only: ["todos"],
    });
  };

  return (
    <div>
      {todos.map((item) => (
        <div key={TodoItem.getId(item)}>
          <span>{TodoItem.getText(item)}</span>
          <input
            type="checkbox"
            checked={TodoItem.getCompleted(item)}
            onChange={() => handleToggle(item)}
          />
        </div>
      ))}
    </div>
  );
}

export default TodoList;
```

### Runtime Props Validation with decodeProps

To ensure type safety at runtime, you can create a higher-order component that validates props using Gleam decoders before rendering:

```typescript
// frontend/src/lib/decodeProps.tsx
import { ComponentType } from "react";
import * as Decode from "@gleam/gleam_stdlib/gleam/dynamic/decode.mjs";
import {
  Result$Error$0 as unwrapError,
  Result$isOk as isOk,
  Result$Ok$0 as unwrapOk,
} from "@gleam/prelude.mjs";
import { Dynamic$ } from "@gleam/gleam_stdlib/gleam/dynamic.mjs";

export function decodeProps<P extends object>(
  Component: ComponentType<P>,
  decoder: Decode.Decoder$<P>,
) {
  return function ValidatedComponent(props: Dynamic$) {
    const result = Decode.run(props, decoder);

    if (isOk(result)) {
      const decodedProps = unwrapOk(result)!;
      return <Component {...decodedProps} />;
    } else {
      // Decoding failed - show error UI
      const errorsList = unwrapError(result)!;
      const errors = Array.from(errorsList);

      console.error("Props validation failed:", errors);

      return (
        <div className="error-container">
          <h1>Props Validation Failed</h1>
          <pre>{JSON.stringify(errors, null, 2)}</pre>
        </div>
      );
    }
  };
}
```

Wrap your component exports with `decodeProps`:

```tsx
// frontend/src/Pages/TodoList.tsx
import { router } from "@inertiajs/react";
import * as TodoItem from "../lib/todo_item";
import { decodeProps } from "../lib/decodeProps";

function TodoList(props: TodoItem.TodoProps$) {
  const todos = Array.from(TodoItem.getTodos(props));
  // ... component implementation
}

// Validate props at runtime using the same Gleam decoder
export default decodeProps(TodoList, TodoItem.decode_todo_props());
```

This approach provides ensures your frontend component only ever renders with valid props explicitly decoded for type safety.


### Build Process

Build the shared package with the javascript target before building frontend:

```bash
# Build shared package
cd shared && gleam build --target javascript

# Build frontend
cd frontend && npm run build
```

## Documentation

- **[API Documentation](https://hexdocs.pm/inertia_wisp)** - Complete API reference
- **[Inertia.js Documentation](https://inertiajs.com/)** - Official Inertia.js docs

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT
