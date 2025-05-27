# SSR Setup Guide for Inertia Gleam

This guide explains how to set up Server-Side Rendering (SSR) for your Inertia Gleam application.

## Overview

SSR in Inertia Gleam uses a supervised pool of Node.js processes to render React components on the server. This provides faster initial page loads and better SEO while maintaining the SPA experience for subsequent navigation.

## Prerequisites

1. **Gleam Project**: SSR works with standard Gleam projects using gleam.toml
2. **Node.js**: Version 18 or higher
3. **nodejs package**: Gleam package for managing Node.js worker processes

## Step 1: Project Dependencies

Add the required dependencies to your `gleam.toml`:

```toml
[dependencies]
gleam_stdlib = ">= 0.60.0"
gleam_http = ">= 4.0.0"
gleam_json = ">= 3.0.0"
wisp = ">= 1.7.0"
inertia_gleam = "~> 1.0"
nodejs = ">= 3.1.3 and < 4.0.0"
gleam_otp = ">= 0.15.0 and < 1.0.0"
mist = ">= 2.0.0"
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
import gleam/erlang/process
import gleam/option
import inertia_gleam
import inertia_gleam/ssr
import inertia_gleam/types
import wisp

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

  // ... rest of application setup with ssr_supervisor
}

fn start_ssr_supervisor() {
  let config =
    types.SSRConfig(
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

fn handle_request(
  req: wisp.Request,
  ssr_supervisor: option.Option(process.Subject(types.SSRMessage)),
) -> wisp.Response {
  use ctx <- inertia_gleam.inertia_middleware(req, inertia_gleam.default_config())
  
  // Enable SSR if supervisor is available
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

## Step 4: SSR Configuration Options

### Using Configuration Helpers

For common scenarios, use the built-in configuration helpers:

```gleam
import inertia_gleam/ssr/config

// Development configuration
let dev_config = 
  config.development()
  |> config.with_path("./ssr")
  |> config.with_module("ssr")

// Production configuration  
let prod_config =
  config.production()
  |> config.with_path("./ssr")
  |> config.with_module("ssr")
```

### Manual Configuration

```gleam
let custom_config = types.SSRConfig(
  enabled: True,
  path: "./ssr",           // Path to SSR bundle directory
  module: "ssr",           // Module name (without .js extension)
  pool_size: 4,           // Number of Node.js workers
  timeout_ms: 5000,       // Render timeout in milliseconds
  raise_on_failure: False, // Whether to raise or fallback on errors
  supervisor_name: "InertiaSSR", // Process name
)
```

## Step 5: Build and Run

```bash
# Install frontend dependencies
cd frontend && npm install

# Build frontend bundles (including SSR)
npm run build

# Install Gleam dependencies
cd .. && gleam deps download

# Run with SSR
gleam run
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
- **Path**: Default path is "priv", change to "./ssr" for development

## Troubleshooting

### SSR Supervisor Fails to Start
- Ensure Node.js is installed and accessible
- Check that SSR bundle exists at configured path
- Verify module name matches the exported file

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
config.development() // Raises errors, longer timeout, fewer workers
```

### Production
```gleam
config.production() // Graceful fallback, shorter timeout, more workers
```

## Configuration Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | Bool | False | Whether SSR is globally enabled |
| `path` | String | "priv" | Directory containing SSR bundle |
| `module` | String | "ssr" | Node.js module name (no .js) |
| `pool_size` | Int | 4 | Number of Node.js workers |
| `timeout_ms` | Int | 5000 | Render timeout in milliseconds |
| `raise_on_failure` | Bool | False | Raise exceptions vs fallback |
| `supervisor_name` | String | "InertiaSSR" | Process name |

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