# Technology Stack

## Core Technologies

- **Language**: Gleam (functional programming language for the BEAM VM)
- **Web Framework**: Wisp (lightweight web framework for Gleam)
- **Runtime**: Erlang/OTP (BEAM virtual machine)
- **Package Manager**: Gleam's built-in package manager
- **Frontend Integration**: Inertia.js protocol with React/Vue/Svelte support

## Key Dependencies

- `gleam_stdlib` - Standard library functions
- `gleam_http` - HTTP utilities and types
- `gleam_json` - JSON encoding/decoding
- `wisp` - Web framework (version 1.8.0+)
- `gleam_crypto` - Cryptographic functions
- `simplifile` - File system operations
- `gleam_otp` - OTP abstractions
- `nodejs` - Node.js FFI for SSR support

## Build System

The project uses Gleam's native build system with `gleam.toml` configuration files.

### Common Commands

```bash
# Install dependencies
gleam deps download

# Build the project
gleam build

# Run tests
gleam test

# Format code
gleam format

# Check types
gleam check

# Generate documentation
gleam docs build
```

### Example Projects

Each example has its own build setup:

```bash
# Demo example (full-featured)
cd examples/demo
gleam run

# Simple demo (with Makefile)
cd examples/simple-demo
make install  # Install all dependencies
make build    # Build frontend and backend
make run      # Build and start server
make dev      # Development mode with watching

# Typed demo (modular structure)
cd examples/typed-demo/backend
gleam run
```

## Frontend Build Integration

Examples use npm/Node.js for frontend asset building:
- React with TypeScript
- Vite for bundling and development
- CSS processing and optimization
- Static asset management in `/static` directories

## Development Workflow

1. Backend development in Gleam with hot reloading via `gleam run`
2. Frontend development with `npm run build:watch` for asset compilation
3. Type-safe prop definitions shared between backend and frontend
4. SSR support with Node.js process supervision