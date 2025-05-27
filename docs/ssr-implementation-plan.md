# Inertia Gleam SSR Implementation Plan

**Status**: 🚧 In Progress  
**Last Updated**: 2025-01-27  
**Current Phase**: Phase 3 - Render Integration

## Overview

Implementation of server-side rendering (SSR) for Inertia Gleam using a supervised pool of Node.js processes, following the proven architecture from the Phoenix inertia-phoenix package.

## Architecture

We'll implement SSR using direct Elixir FFI calls to the `nodejs` package, avoiding the need for custom Erlang modules. This approach leverages existing, battle-tested infrastructure while providing type-safe Gleam APIs.

### Key Components

1. **Direct Elixir FFI** - Thin Gleam wrappers around the `nodejs` package
2. **Supervision Strategy** - Gleam OTP supervisors managing Node.js worker pools
3. **SSR Integration** - Enhanced render functions with automatic SSR/CSR detection
4. **Configuration Management** - Type-safe configuration with environment support
5. **Error Handling** - Graceful fallback to CSR when SSR fails

## Dependencies

### Elixir Dependencies (mix.exs)
```elixir
defp deps do
  [
    {:nodejs, "~> 2.0"},
    # ... existing deps
  ]
end
```

### Gleam Dependencies (gleam.toml)
```toml
[dependencies]
# ... existing deps ...
gleam_otp = ">= 0.15.0 and < 1.0.0"
gleam_dynamic = ">= 3.0.0 and < 4.0.0"
```

## Module Structure

```
src/inertia_gleam/
├── ssr/
│   ├── nodejs_ffi.gleam      # Direct Elixir FFI calls
│   ├── supervisor.gleam      # Gleam supervisor wrapper  
│   └── config.gleam          # Configuration types
└── ssr.gleam                 # Main SSR API
```

## Implementation Phases

### Phase 1: FFI Foundation ✅ Complete

**Goal**: Create foundation for calling Node.js processes from Gleam

**Tasks**:
- [x] Create `nodejs_ffi.gleam` with direct Elixir FFI calls
- [x] Implement type-safe wrappers for `NodeJS.Supervisor.start_link/1`
- [x] Implement type-safe wrappers for `NodeJS.call/3`
- [x] Add JSON serialization helpers for page data
- [x] Basic error handling and type conversions
- [x] Write unit tests for FFI functions

**API Design**:
```gleam
// nodejs_ffi.gleam
pub fn start_supervisor(config: NodeSupervisorConfig) -> Result(Pid, FFIError)
pub fn call_render(module: String, page_json: String, supervisor_name: String, timeout_ms: Int) -> Result(String, FFIError)
```

**Implemented**:
- `src/inertia_gleam/ssr/nodejs_ffi.gleam` - Direct Elixir FFI calls
- `src/inertia_gleam/ssr/config.gleam` - Configuration types and validation
- `src/inertia_gleam/ssr.gleam` - Main SSR API with functional approach
- `test/ssr_test.gleam` - Comprehensive unit tests
- All tests passing (48 tests, 0 failures)

**Status**: ✅ Complete

---

### Phase 2: Supervisor Implementation ✅ Complete

**Goal**: Create Gleam supervisor that manages Node.js worker pool

**Tasks**:
- [x] Implement SSR supervisor with configurable worker pool
- [x] Add configuration management with environment variable support  
- [x] Process lifecycle management (start, stop, restart workers)
- [x] Health checks and monitoring
- [x] Integration with Gleam OTP supervision tree

**API Design**:
```gleam
// supervisor.gleam
pub type SSRConfig {
  SSRConfig(
    path: String,           // Path to directory containing ssr.js
    module: String,         // Module name (default: "ssr") 
    pool_size: Int,         // Number of worker processes
    timeout: Int,           // Render timeout in milliseconds
  )
}

pub fn start_link(config: SSRConfig) -> Result(Subject(Message), StartError)
```

**Implemented**:
- `src/inertia_gleam/ssr/supervisor.gleam` - OTP actor-based supervisor
- Enhanced `src/inertia_gleam/ssr.gleam` with supervisor integration
- `src/inertia_gleam/ssr/example.gleam` - Integration examples and patterns
- `test/ssr_supervisor_test.gleam` - Comprehensive supervisor tests
- Full OTP supervision tree integration with child specs

**Status**: ✅ Complete

---

### Phase 3: Render Integration ⏳ Ready to Start

**Goal**: Integrate SSR with existing Inertia render system

**Tasks**:
- [ ] Enhance existing render function to detect SSR vs CSR scenarios
- [ ] Add SSR-specific response handling (HTML with embedded page data)
- [ ] Implement fallback mechanisms when SSR fails
- [ ] Add performance monitoring and timeouts
- [ ] Support for lazy props and deferred props in SSR context

**API Design**:
```gleam
// ssr.gleam
pub type SSRResult {
  SSRSuccess(html: String)
  SSRFallback(reason: String)  // Fall back to CSR
  SSRError(error: String)      // Hard error
}

pub fn render_with_ssr(ctx: InertiaContext, component: String) -> Result(Response, SSRError)
```

**Enhanced main render function**:
```gleam
// inertia_gleam.gleam
pub fn render(ctx: InertiaContext, component: String) -> Response {
  case should_use_ssr(ctx) {
    True -> ssr.render_with_ssr(ctx, component)
    False -> render_csr(ctx, component)  // Existing implementation
  }
}
```

**Status**: 🔄 Ready to start

---

### Phase 4: Developer Experience ⏳ Waiting for Phase 3

**Goal**: Polish developer experience and production readiness

**Tasks**:
- [ ] Create build tooling helpers and documentation
- [ ] Add development mode optimizations (hot reloading compatibility)
- [ ] Error reporting and debugging tools
- [ ] Production deployment guides
- [ ] Performance benchmarking and optimization
- [ ] Complete example application

**Status**: ⏸️ Waiting for Phase 3

## Configuration API

### Global Configuration
```gleam
// Application startup
import inertia_gleam/ssr

pub fn main() {
  let ssr_config = ssr.SSRConfig(
    path: "priv",
    module: "ssr",
    pool_size: 4,
    timeout: 5000,
  )
  
  // Start SSR supervisor before web server
  let assert Ok(_) = ssr.start_link(ssr_config)
  
  // Start Wisp server...
}
```

### Per-Request Configuration
```gleam
// Override SSR behavior per request
ctx
|> inertia_gleam.disable_ssr()  // Force CSR for this request
|> inertia_gleam.render("Dashboard")

// Or with timeout override
ctx
|> inertia_gleam.ssr_timeout(10_000)  // Custom timeout
|> inertia_gleam.render("ExpensivePage")
```

## Frontend Build Integration

### SSR Entry Point (src/ssr.js)
```javascript
import React from 'react'
import ReactDOMServer from 'react-dom/server'
import { createInertiaApp } from '@inertiajs/react'

export function render(page) {
  return createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    resolve: async (name) => {
      const pages = import.meta.glob('./pages/**/*.jsx', { eager: true })
      return pages[`./pages/${name}.jsx`]
    },
    setup: ({ App, props }) => React.createElement(App, props),
  })
}
```

### Build Configuration
```javascript
// build.js
import * as esbuild from 'esbuild'

// Client bundle
await esbuild.build({
  entryPoints: ['src/app.js'],
  bundle: true,
  outdir: 'dist/assets',
  format: 'esm',
  target: 'es2020'
})

// SSR bundle  
await esbuild.build({
  entryPoints: ['src/ssr.js'],
  bundle: true,
  outdir: 'priv',
  format: 'cjs',
  platform: 'node',
  target: 'node18'
})
```

## Error Handling Strategy

### Graceful Degradation
- SSR failures fall back to CSR by default in production
- Development mode can raise exceptions for debugging
- Timeout handling prevents hanging requests

### Error Types
```gleam
pub type SSRError {
  TimeoutError(duration: Int)
  WorkerError(message: String)
  SerializationError(details: String)
  ModuleNotFound(module: String)
  ConfigurationError(issue: String)
}
```

### Monitoring and Logging
- Performance metrics (render times, success/failure rates)
- Worker health monitoring
- Graceful fallback logging for production debugging

## Benefits

1. **Familiar Pattern** - Follows proven Phoenix inertia-phoenix architecture
2. **Type Safety** - Leverages Gleam's type system for configuration and error handling
3. **Performance** - Supervised worker pool provides good performance and fault tolerance
4. **Gradual Adoption** - Can be enabled/disabled globally or per-request
5. **Fallback Strategy** - Graceful degradation to CSR when SSR fails
6. **Developer Experience** - Clear APIs and good error messages
7. **No Custom Erlang** - Uses direct Elixir FFI calls to battle-tested nodejs package

## Testing Strategy

### Unit Tests
- FFI function correctness
- Configuration validation
- Error handling scenarios

### Integration Tests  
- Full SSR rendering pipeline
- Fallback behavior
- Performance under load

### Example Applications
- Complete React + Gleam SSR demo
- Production deployment examples

---

## Progress Log

### 2025-01-27
- ✅ Created implementation plan
- ✅ Defined architecture and module structure
- ✅ Identified direct Elixir FFI approach (no custom .erl needed)
- ✅ Completed Phase 1: FFI Foundation
- ✅ Completed Phase 2: Supervisor Implementation
- 🔄 Ready for Phase 3: Render Integration

### Phase 1 Progress
- [x] `nodejs_ffi.gleam` implementation with direct Elixir FFI calls
- [x] Configuration types and validation in `config.gleam`
- [x] Main SSR API in `ssr.gleam` with functional approach
- [x] JSON serialization for page data
- [x] Comprehensive unit tests (48 tests passing)
- [x] Error handling with proper type safety

**Key Achievements**:
- Direct FFI calls to `NodeJS.Supervisor.start_link/1` and `NodeJS.call/3`
- Type-safe configuration with validation
- Functional API design avoiding global state
- Complete test coverage for all implemented functionality

### Phase 2 Progress
- [x] OTP supervisor implementation using Gleam actors
- [x] Integration with Gleam supervision tree via child specs
- [x] State management for SSR configuration with runtime updates
- [x] Health checks and monitoring via status queries
- [x] Worker pool lifecycle management (start/stop Node.js processes)

**Key Achievements**:
- Complete OTP actor-based supervisor for managing SSR state
- Message-based API for supervisor communication (start, stop, render, config updates)
- Integration with existing FFI layer for Node.js process management
- Proper error handling and graceful fallback mechanisms
- Child spec support for supervision tree integration
- Comprehensive test coverage and integration examples

### Phase 3 Progress
- [ ] Integration with existing Inertia render pipeline
- [ ] Automatic SSR/CSR detection based on request type
- [ ] HTML template system with embedded page data
- [ ] Enhanced error handling and fallback strategies
- [ ] Performance monitoring and metrics

**Next**: Integrate SSR supervisor with main Inertia render functions