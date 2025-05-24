# Frontend Development

This directory contains the React frontend for the Inertia Gleam project, built with ESBuild.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Build assets for development with watch mode:
```bash
npm run watch
```

This will bundle the JavaScript and watch for changes, automatically rebuilding when files change.

## Scripts

- `npm run dev` - Alias for `npm run watch`
- `npm run watch` - Build and watch for changes (development)
- `npm run build` - Build once (production)

## Project Structure

```
src/
├── main.jsx          # Application entry point
└── Pages/            # Inertia page components
    ├── Home.jsx      # Home page component
    └── About.jsx     # About page component
```

## Development Workflow

1. **Start the asset watcher:**
```bash
npm run watch
```

2. **Start the Gleam server:**
```bash
gleam run -m examples/minimal/main
```

3. **Access your app at `http://localhost:8000`**

## How It Works

- ESBuild watches your source files and automatically rebuilds when changes occur
- Bundled assets are written to `../static/js/main.js`
- The Gleam server serves static files from the `static/` directory
- Changes require a browser refresh (no hot module replacement)

## Building for Production

```bash
npm run build
```

This creates a production-optimized bundle in `../static/js/`.

## Adding New Pages

1. Create a new component in `src/Pages/` (e.g., `Contact.jsx`)
2. Export it as the default export
3. ESBuild will automatically include it via `import.meta.glob`
4. Add the corresponding route in your Gleam server

The component will be automatically available to Inertia using the filename as the component name.