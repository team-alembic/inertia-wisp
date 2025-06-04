# SSR Setup Guide for Inertia Wisp

This guide explains how to set up Server-Side Rendering (SSR) for your Inertia Gleam application.

## Overview

SSR in Inertia Gleam uses a supervised pool of Node.js processes to render React components on the server. This provides faster initial page loads and better SEO while maintaining the SPA experience for subsequent navigation.

## Step 1: Frontend SSR Bundle

Your frontend build must output a CommonJS bundle for Node.js consumption.

### Update package.json

```json
{
  "scripts": {
    "build:js": "esbuild src/main.tsx --bundle --outdir=../static/js --format=esm --splitting --chunk-names=[name]-[hash] --jsx=automatic",
    "build:ssr": "esbuild src/ssr.tsx --bundle --outdir=../static/js --format=cjs --platform=node --target=node18 --jsx=automatic --outfile=../static/js/ssr.js",
    "build": "npm run build:js && npm run build:ssr"
  }
}
```

### Create src/ssr.tsx

```tsx
import React from "react";
import ReactDOMServer from "react-dom/server";
import { createInertiaApp } from "@inertiajs/react";

export function render(page: any) {
  return createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    resolve: async (name: string) => {
      try {
        const component = await import(`./Pages/${name}.tsx`);
        return component.default || component;
      } catch (error) {
        console.error(`SSR: Component '${name}' not found:`, error);
        return () =>
          React.createElement("div", {}, `Component '${name}' not found`);
      }
    },
    setup: ({ App, props }) => React.createElement(App, props),
  });
}
```

## Step 2: Gleam SSR Integration

Update your main application to use SSR:

```gleam
import gleam/erlang/process
import gleam/option
import gleam/http
import mist
import wisp
import wisp/wisp_mist
import inertia_wisp/inertia

pub fn main() {
  wisp.configure_logger()

  // Start SSR supervisor with graceful fallback
  let ssr_supervisor = case start_ssr_supervisor() {
    Ok(supervisor) -> {
      wisp.log_info("SSR supervisor started successfully")
      option.Some(supervisor)
    }
    Error(error) -> {
      wisp.log_info("SSR not available, falling back to CSR: " <> error)
      option.None
    }
  }

  let assert Ok(_) =
    fn(req) { handle_request(req, ssr_supervisor) }
    |> wisp_mist.handler("secret_key_change_me_in_production")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn start_ssr_supervisor() {
  let config =
    inertia.ssr_config(
      enabled: True,
      path: "./static/js/ssr.js",
      module: "render",
      pool_size: 4,
      timeout_ms: 5000,
      supervisor_name: "InertiaSSR",
    )

  inertia.start_ssr_supervisor(config)
}

fn handle_request(
  req: wisp.Request,
  ssr_supervisor: option.Option(process.Subject(inertia.SSRMessage)),
) -> wisp.Response {
  use <- wisp.serve_static(req, from: "./static", under: "/static")

  // Pass ssr_supervisor to middleware
  use ctx <- inertia.middleware(req, inertia.default_config(), ssr_supervisor)

  case wisp.path_segments(req), req.method {
    [], http.Get -> home_page(ctx)
    ["about"], http.Get -> about_page(ctx)
    _ -> wisp.not_found()
  }
}

// Define your props as union types and encoders
pub type HomePageProp {
  Title(title: String)
  Message(message: String)
}

fn encode_home_page_prop(prop: HomePageProp) -> json.Json {
  case prop {
    Title(title) -> json.string(title)
    Message(message) -> json.string(message)
  }
}

fn home_page(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
  ctx
  |> inertia.with_encoder(encode_home_page_prop)
  |> inertia.prop("title", Title("Home"))
  |> inertia.prop("message", Message("Welcome to SSR!"))
  |> inertia.render("Home")
}

fn about_page(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
  inertia.render(ctx, "About")
}
```

## Step 3: Build and Run

```bash
# Install frontend dependencies
cd frontend && npm install

# Build frontend bundles (including SSR)
npm run build

# Run with SSR
cd ..
gleam run
```

## How It Works

1. **Initial Request**: Browser requests `/` without `X-Inertia` header
2. **SSR Decision**: Gleam checks if SSR is enabled and supervisor available
3. **Node.js Render**: Page data sent to Node.js worker for server-side rendering
4. **HTML Response**: Returns full HTML with pre-rendered content + embedded page data
5. **Client Hydration**: React hydrates on client side for subsequent navigation

## Graceful Fallback

If SSR fails for any reason, the system will fallback to client-side rendering.
