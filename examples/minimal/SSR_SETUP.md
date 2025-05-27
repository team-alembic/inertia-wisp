# SSR Setup Guide for Inertia Gleam

This guide explains how to set up Server-Side Rendering (SSR) for your Inertia Gleam application.

## Overview

SSR in Inertia Gleam uses a supervised pool of Node.js processes to render React components on the server. This provides faster initial page loads and better SEO while maintaining the SPA experience for subsequent navigation.

## Prerequisites

1. **Elixir Environment**: SSR requires running in an Elixir Mix project, not pure Gleam
2. **Node.js**: Version 18 or higher
3. **Elixir nodejs package**: For managing Node.js worker processes

## Step 1: Elixir Mix Project Setup

Convert your Gleam project to use Elixir Mix:

### Create mix.exs

```elixir
defmodule MinimalInertiaExample.MixProject do
  use Mix.Project

  def project do
    [
      app: :minimal_inertia_example,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MinimalInertiaExample.Application, []}
    ]
  end

  defp deps do
    [
      {:gleam_stdlib, "~> 0.60"},
      {:gleam_otp, "~> 0.15"},
      {:gleam_http, "~> 4.0"},
      {:gleam_json, "~> 3.0"},
      {:wisp, "~> 1.7"},
      {:mist, "~> 2.0"},
      {:nodejs, "~> 2.0"},
      {:inertia_gleam, path: "../../"}
    ]
  end

  defp aliases do
    [
      "gleam.build": ["cmd gleam build"],
      "gleam.run": ["cmd gleam run"]
    ]
  end
end
```

### Create application.ex

```elixir
defmodule MinimalInertiaExample.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Start the NodeJS supervisor for SSR
      {NodeJS.Supervisor, [path: Path.join([File.cwd!(), "ssr"]), pool_size: 4]}
    ]

    opts = [strategy: :one_for_one, name: MinimalInertiaExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## Step 2: Frontend SSR Bundle

Your frontend build must output a CommonJS bundle for Node.js consumption.

### Update package.json

```json
{
  "scripts": {
    "build:ssr": "esbuild src/ssr.tsx --bundle --outdir=../ssr --format=cjs --platform=node --target=node18 --jsx=automatic",
    "build": "npm run build:css && npm run build:js && npm run build:ssr"
  }
}
```

### Create src/ssr.tsx

```tsx
import React from 'react'
import ReactDOMServer from 'react-dom/server'
import { createInertiaApp } from '@inertiajs/react'

export function render(page: any) {
  return createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    resolve: async (name: string) => {
      try {
        const component = await import(`./Pages/${name}.tsx`)
        return component.default || component
      } catch (error) {
        console.error(`SSR: Component '${name}' not found:`, error)
        return () => React.createElement('div', {}, `Component '${name}' not found`)
      }
    },
    setup: ({ App, props }) => React.createElement(App, props),
  })
}
```

## Step 3: Gleam SSR Integration

Update your main application to use SSR:

```gleam
import inertia_gleam/ssr
import inertia_gleam/ssr/config as ssr_config

pub fn main() {
  wisp.configure_logger()

  // Start SSR supervisor
  let ssr_supervisor = case start_ssr_supervisor() {
    Ok(supervisor) -> {
      wisp.log_info("SSR enabled")
      option.Some(supervisor)
    }
    Error(error) -> {
      wisp.log_info("SSR not available: " <> error)
      option.None
    }
  }

  // ... rest of application setup
}

fn start_ssr_supervisor() {
  let config = ssr_config.SSRConfig(
    enabled: True,
    path: "./ssr",
    module: "ssr",
    pool_size: 2,
    timeout_ms: 5000,
    raise_on_failure: False,
    supervisor_name: "InertiaSSR",
  )
  
  ssr.start_supervisor(config)
}

fn handle_request(req, ssr_supervisor) {
  use ctx <- inertia_gleam.inertia_middleware(req, config)
  
  // Enable SSR if available
  let ctx = case ssr_supervisor {
    option.Some(supervisor) -> 
      ctx
      |> inertia_gleam.enable_ssr()
      |> inertia_gleam.with_ssr_supervisor(supervisor)
    option.None -> ctx
  }
  
  // ... handle routes
}
```

## Step 4: Build and Run

```bash
# Install frontend dependencies
cd frontend && npm install

# Build frontend bundles (including SSR)
npm run build

# Install Elixir dependencies
cd .. && mix deps.get

# Compile Gleam code
mix gleam.build

# Run with SSR
mix run --no-halt
```

## How It Works

1. **Initial Request**: Browser requests `/` without `X-Inertia` header
2. **SSR Decision**: Gleam checks if SSR is enabled and supervisor available
3. **Node.js Render**: Page data sent to Node.js worker for server-side rendering
4. **HTML Response**: Returns full HTML with pre-rendered content + embedded page data
5. **Client Hydration**: React hydrates on client side for subsequent navigation

## Graceful Fallback

If SSR fails for any reason:
- Development: Can raise exceptions for debugging (set `raise_on_failure: True`)
- Production: Falls back to CSR automatically (set `raise_on_failure: False`)

## Performance Considerations

- **Pool Size**: Start with 2-4 workers, adjust based on traffic
- **Timeout**: 5 seconds is reasonable, adjust based on component complexity
- **Memory**: Each Node.js worker uses ~30-50MB memory
- **Caching**: Consider caching rendered components for static content

## Troubleshooting

### SSR Supervisor Fails to Start
- Ensure you're running in an Elixir Mix project
- Check that `nodejs` dependency is installed
- Verify SSR bundle exists at configured path

### Render Errors
- Check Node.js console output for JavaScript errors
- Ensure all imported modules are SSR-compatible
- Verify component props match expected schema

### Performance Issues
- Increase timeout for complex components
- Add more workers to the pool
- Consider lazy loading for heavy components

## Development vs Production

### Development
```gleam
ssr_config.development() // Raises errors, longer timeout
```

### Production
```gleam
ssr_config.production() // Graceful fallback, more workers
```

## Example Output

With SSR enabled, initial page loads return:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title inertia>Welcome to Inertia Gleam</title>
    <link rel="stylesheet" href="/static/css/styles.css">
</head>
<body>
    <div id="app" data-page="{...}">
        <!-- Fully rendered React component HTML -->
        <div class="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-cyan-50">
            <!-- Component content pre-rendered -->
        </div>
    </div>
    <script type="module" src="/static/js/main.js"></script>
</body>
</html>
```

Subsequent Inertia requests return JSON as usual.