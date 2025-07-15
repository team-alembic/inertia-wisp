# Project Structure

## Root Directory Layout

```
├── src/                    # Main library source code
├── examples/               # Example applications
├── test/                   # Test files
├── docs/                   # Documentation and guides
├── notes/                  # Development notes and feature specs
├── build/                  # Compiled artifacts (generated)
├── gleam.toml             # Main project configuration
└── manifest.toml          # Dependency lock file
```

## Core Library Structure (`src/`)

```
src/inertia_wisp/
├── inertia.gleam                    # Main public API
├── response_builder.gleam           # Response builder pattern API
├── testing.gleam                    # Testing utilities
└── internal/                        # Internal implementation
    ├── types.gleam                  # Core types and data structures
    ├── middleware.gleam             # Request/response middleware
    ├── html.gleam                   # HTML template generation
    ├── version.gleam                # Version management
    └── ssr/                         # Server-side rendering
        ├── config.gleam             # SSR configuration
        ├── nodejs_ffi.gleam         # Node.js FFI bindings
        └── supervisor.gleam         # SSR process supervision
```

## Example Applications Structure

### Demo Example (`examples/demo/`)
Full-featured example with React frontend:
```
examples/demo/
├── src/                    # Gleam backend source
│   ├── demo.gleam         # Main application entry point
│   ├── handlers/          # Request handlers by feature
│   ├── shared_types/      # Type definitions for props
│   ├── data/              # Data access layer
│   └── validators/        # Form validation logic
├── frontend/              # React frontend
│   ├── src/Pages/         # Inertia.js page components
│   ├── src/components/    # Reusable UI components
│   └── package.json       # Frontend dependencies
└── static/                # Built assets (generated)
```

### Simple Demo (`examples/simple-demo/`)
Minimal example with Makefile build system:
```
examples/simple-demo/
├── src/                   # Gleam backend
│   ├── handlers/          # Route handlers
│   └── props/             # Prop type definitions
├── frontend/              # Frontend source
├── test/                  # Backend tests
├── static/                # Static assets
└── Makefile              # Build automation
```

### Typed Demo (`examples/typed-demo/`)
Advanced modular example:
```
examples/typed-demo/
├── backend/               # Backend application
├── frontend/              # Frontend application  
└── shared_types/          # Shared type definitions package
```

## Naming Conventions

### Files and Modules
- Use snake_case for file names: `user_handler.gleam`
- Module names follow file names: `user_handler`
- Internal modules go in `internal/` directories

### Functions and Variables
- Use snake_case: `create_user`, `user_count`
- Predicate functions end with `?`: `is_valid?`
- Type constructors use PascalCase: `DefaultProp`, `LazyProp`

### Prop Types and Encoders
- Prop union types: `HomePageProp`, `UserProp`
- Encoder functions: `encode_home_page_prop`, `encode_user_prop`
- Prop constructors: `Message(String)`, `UserCount(Int)`

## Directory Organization Patterns

### Handler Organization
Group handlers by feature/resource:
```
handlers/
├── users/
│   ├── create_handler.gleam
│   ├── edit_handler.gleam
│   └── list_handler.gleam
└── uploads.gleam
```

### Type Organization
Separate shared types by page/feature:
```
shared_types/
├── auth.gleam
├── home.gleam
├── users.gleam
└── uploads.gleam
```

### Frontend Organization
Mirror backend structure in frontend:
```
frontend/src/
├── Pages/           # One-to-one with backend routes
├── components/      # Reusable UI components
├── types/          # TypeScript type definitions
└── schemas/        # Validation schemas
```

## Configuration Files

- `gleam.toml` - Project metadata and dependencies
- `manifest.toml` - Dependency lock file (auto-generated)
- `package.json` - Frontend dependencies (in example projects)
- `tsconfig.json` - TypeScript configuration (in example projects)