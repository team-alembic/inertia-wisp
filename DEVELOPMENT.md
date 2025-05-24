# Development Setup

This guide explains how to set up the development environment for Inertia Gleam projects using ESBuild for asset bundling.

## Quick Start

1. **Install frontend dependencies:**
```bash
cd frontend
npm install
```

2. **Start asset watcher (Terminal 1):**
```bash
cd frontend
npm run watch
```

3. **Start Gleam server (Terminal 2):**
```bash
gleam run -m examples/minimal/main
```

4. **Access your app at `http://localhost:8000`**

## How It Works

### Asset Pipeline
- ESBuild watches `frontend/src/` and bundles to `static/js/main.js`
- The Gleam server serves static files from the `static/` directory
- Changes require a browser refresh (no hot module replacement)

### Project Structure

```
inertia-gleam/
├── frontend/
│   ├── src/
│   │   ├── main.jsx          # Entry point
│   │   └── Pages/            # Inertia components
│   │       ├── Home.jsx
│   │       └── About.jsx
│   └── package.json
├── static/
│   └── js/
│       └── main.js           # Built assets
├── examples/
│   └── minimal/
│       └── main.gleam        # Example server
└── src/
    └── inertia_gleam/        # Library code
```

## Development Workflow

### Frontend Changes
1. Edit components in `frontend/src/Pages/`
2. ESBuild automatically rebuilds
3. Refresh browser to see changes

### Backend Changes
1. Edit Gleam code in `src/` or `examples/`
2. Restart Gleam server (`Ctrl+C` then `gleam run`)
3. Refresh browser

### Adding New Pages
1. Create `frontend/src/Pages/NewPage.jsx`:
```jsx
export default function NewPage({ title }) {
    return <h1>{title}</h1>
}
```

2. Add route in Gleam:
```gleam
fn handle_request(req: wisp.Request, config: inertia_gleam.Config) -> wisp.Response {
  use _req <- inertia_gleam.inertia_middleware(req, config)
  
  case wisp.path_segments(req) {
    [] -> home_page(req)
    ["about"] -> about_page(req)
    ["new"] -> new_page(req)  // Add this
    ["static", ..path] -> wisp.serve_static(req, path, from: "./static", under: "/static")
    _ -> wisp.not_found()
  }
}

fn new_page(req: wisp.Request) -> wisp.Response {
  let props = inertia_gleam.props_from_list([
    #("title", inertia_gleam.string_prop("New Page")),
  ])
  
  inertia_gleam.render_inertia_with_props(req, "NewPage", props)
}
```

## Frontend Scripts

```bash
npm run dev      # Alias for watch
npm run watch    # Build and watch for changes
npm run build    # Build once (production)
```

## Debugging

### Frontend Issues
- Check browser console for errors
- Verify `static/js/main.js` exists and is recent
- Check that ESBuild watcher is running

### Backend Issues
- Ensure Gleam server is running on port 8000
- Check that routes return proper Inertia responses
- Verify static file serving is working (`/static/js/main.js`)

### Integration Issues
- Confirm `data-page` attribute contains valid JSON
- Check that component names match between frontend and backend
- Verify props are properly serialized to JSON

## Production Build

```bash
cd frontend
npm run build
```

Deploy the `static/` directory with your Gleam application. The same HTML template and routing logic works for both development and production.