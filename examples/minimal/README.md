# Minimal Inertia Gleam Example

A complete demonstration of the `inertia-gleam` library with React frontend components, showcasing forms, validation, file uploads, and CRUD operations.

## Quick Start

1. **Install frontend dependencies:**
```bash
cd frontend
npm install
```

2. **Build frontend assets:**
```bash
npm run build
```

3. **Run the Gleam server:**
```bash
gleam run
```

4. **Visit http://localhost:8000**

## What's Included

- **SPA Navigation** with Inertia.js
- **User Management** (CRUD operations with validation)
- **File Uploads** with drag & drop interface
- **Form Handling** with error feedback
- **TypeScript Frontend** with React components
- **Server-Side Rendering (SSR)** with Node.js integration

## Development

For active development with auto-rebuilding:

1. **Frontend watcher (Terminal 1):**
   ```bash
   cd frontend && npm run watch
   ```

2. **Gleam server (Terminal 2):**
   ```bash
   gleam run
   ```

## Server-Side Rendering (SSR)

This example includes SSR support for faster initial page loads and better SEO. Currently running in CSR fallback mode.

For full SSR setup in production:
- See [SSR_SETUP.md](./SSR_SETUP.md) for detailed configuration
- Requires Elixir Mix environment with `nodejs` package
- Gracefully falls back to CSR when SSR unavailable

## Project Structure

```
minimal/
├── src/                     # Gleam backend
├── frontend/src/Pages/      # React components  
├── static/js/               # Built assets
└── gleam.toml
```

## Testing

Try these scenarios:
1. Navigate between pages (no full page reloads)
2. Create users with invalid data (see validation)
3. Upload files with drag & drop
4. Use browser back/forward buttons

## More Information

For detailed documentation, see the [main project docs](../../docs/).
