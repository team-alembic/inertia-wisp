# Presentation Example

A meta presentation that demonstrates Inertia-Wisp by using it to present itself!

## Quick Start

```bash
# First time setup
make certs    # Generate trusted HTTPS certificates (requires mkcert)
make deps     # Install dependencies
make build    # Build frontend assets

# Run the server
make run
```

Open **https://localhost:8444/**

## Development Mode

```bash
# Terminal 1: Watch and rebuild frontend
make dev-frontend

# Terminal 2: Run server (restart on backend changes)
make dev-server
```

## What This Demonstrates

**Backend as CMS Pattern**
- All slide content defined in Gleam (`src/slides/`)
- Navigation logic handled server-side
- Backend controls structure, frontend just renders

**Generic Frontend**
- Single `Slide.tsx` component renders all slides
- Content blocks rendered dynamically based on type
- Keyboard navigation with arrow keys

**End-to-End Type Safety**
- Gleam types → JSON encoders → TypeScript types
- Compile-time validation across the language boundary
- No runtime type errors

**Key Insight:** The backend controls everything. The frontend is a rendering engine that doesn't know about individual slides.

## Available Commands

```bash
make all          # Install dependencies and build (default)
make certs        # Generate HTTPS certificates with mkcert
make deps         # Install Gleam and frontend dependencies
make build        # Build frontend assets
make run          # Run the server
make dev-frontend # Watch and rebuild frontend
make dev-server   # Run server
make clean        # Remove build artifacts
make test         # Run tests
```

## Troubleshooting

**Certificate issues?**
```bash
# macOS
brew install mkcert
mkcert -install
make certs
```

**Port 8444 in use?** Change the port in `src/presentation.gleam`

**Build errors?** Run `make clean && make all`
