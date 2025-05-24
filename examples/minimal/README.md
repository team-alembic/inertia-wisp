# Minimal Inertia Gleam Example

This is a complete, standalone Gleam application demonstrating how to use the `inertia-gleam` library with React frontend components.

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

## Development Workflow

For active development with auto-rebuilding frontend assets:

1. **Start frontend watcher (Terminal 1):**
```bash
cd frontend
npm run watch
```

2. **Start Gleam server (Terminal 2):**
```bash
gleam run
```

3. **Make changes and refresh browser**

## Project Structure

```
minimal/
├── src/
│   └── main.gleam           # Gleam web server
├── frontend/
│   ├── src/
│   │   ├── main.jsx         # React entry point
│   │   └── pages/           # Inertia page components
│   │       ├── Home.jsx
│   │       └── About.jsx
│   └── package.json
├── static/
│   └── js/
│       └── main.js          # Built frontend assets
├── gleam.toml               # Gleam project config
└── README.md
```

## How It Works

1. **Frontend**: React components in `frontend/src/pages/` are bundled by ESBuild into `static/js/` with automatic code splitting
2. **Backend**: Gleam server serves HTML responses with Inertia page data and includes the bundled JavaScript
3. **Routing**: Both initial page loads and subsequent navigation are handled by the same Gleam routes
4. **Static Assets**: The Gleam server serves static files from the `static/` directory

## Adding New Pages

1. **Create React component:**
```jsx
// frontend/src/pages/Contact.jsx
export default function Contact({ email }) {
    return <div>Contact us at: {email}</div>
}
```

2. **Add Gleam route:**
```gleam
// src/main.gleam
case wisp.path_segments(req) {
  [] -> home_page(req)
  ["about"] -> about_page(req)
  ["contact"] -> contact_page(req)  // Add this
  // ...
}

fn contact_page(req: wisp.Request) -> wisp.Response {
  let props = inertia_gleam.props_from_list([
    #("email", inertia_gleam.string_prop("hello@example.com")),
  ])
  
  inertia_gleam.render_inertia_with_props(req, "Contact", props)
}
```

## Frontend Scripts

- `npm run build` - Build once for production
- `npm run watch` - Build and watch for changes (development)
- `npm run dev` - Alias for `npm run watch`

## Dependencies

This example uses the `inertia-gleam` library as a local path dependency from the parent directory. The library provides:

- Inertia.js middleware for Wisp
- HTML template generation
- JSON response handling for XHR requests
- Helper functions for props and rendering