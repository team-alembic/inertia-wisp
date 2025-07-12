# Simple Demo Frontend

This is the frontend for the simple-demo application, showcasing the new `inertia.eval` API design with React and TypeScript.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Build the frontend assets:
```bash
npm run build
```

3. For development with watch mode:
```bash
npm run build:watch
```

## Development

The frontend uses:
- **React 18** with TypeScript
- **Inertia.js** for seamless client-server integration
- **esbuild** for fast bundling
- **CSS** for styling (no framework dependencies)

## Build Output

The build process generates:
- `../static/js/main.js` - Main JavaScript bundle
- `../static/css/styles.css` - Compiled CSS

## File Structure

```
frontend/
├── src/
│   ├── Pages/
│   │   └── Home.tsx          # Home page component
│   ├── app.tsx               # Main app entry point
│   ├── styles.css            # Global styles
│   ├── types.ts              # TypeScript interfaces
│   └── utils.ts              # Utility functions
├── package.json
├── tsconfig.json
└── README.md
```

## Usage

1. Start the Gleam backend server
2. Build the frontend assets with `npm run build`
3. Visit `http://localhost:8001` to see the demo

The page demonstrates:
- **AlwaysProp**: Navigation and CSRF token (always included in responses)
- **DefaultProp**: Welcome message, user info, and app version (included on standard visits)

## API Integration

The frontend receives props from the backend via Inertia.js:

```typescript
interface HomePageProps {
  welcome_message: string      // DefaultProp
  navigation: NavigationItem[] // AlwaysProp  
  csrf_token: string          // AlwaysProp
  app_version: string         // DefaultProp
  current_user: CurrentUser   // DefaultProp
}
```

These props are constructed using the new `inertia.eval()` API on the backend, demonstrating direct Page object construction without the InertiaContext type.