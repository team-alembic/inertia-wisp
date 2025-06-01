# Typed Demo Frontend

This is the React frontend for the typed Inertia demo, showcasing the statically typed props system.

## Features

- **Type-safe props**: Uses shared TypeScript types generated from Gleam
- **ESBuild**: Fast bundling and development experience
- **Tailwind CSS**: Utility-first CSS framework
- **Server-side rendering**: Full SSR support with Inertia.js
- **Hot reloading**: Watch mode for rapid development

## Components

- `UserProfile.tsx`: User profile page with bio and interests
- `BlogPost.tsx`: Blog post display with metadata and tags
- `Dashboard.tsx`: Admin dashboard with stats and recent activity

## Development

Install dependencies:
```bash
npm install
```

Build for development:
```bash
npm run dev
```

Build for production:
```bash
npm run build
```

Type checking:
```bash
npm run type-check
npm run validate-types
```

## Build Scripts

- `build:css`: Compile and minify Tailwind CSS
- `build:js`: Bundle JavaScript with ESBuild (ESM format)
- `build:ssr`: Bundle SSR JavaScript (CommonJS format)
- `build`: Full production build with type checking
- `build:fast`: Fast build without type checking
- `dev`: Development mode with file watching
- `watch`: Watch files and rebuild on changes
- `type-check`: TypeScript type checking only

## Output

Built files are output to `../backend/static/`:
- CSS: `../backend/static/css/styles.css`
- JavaScript: `../backend/static/js/` (multiple chunk files)
- SSR: `../backend/static/js/ssr.js`

This allows the backend server to serve static assets from the correct location using Wisp's static file serving.

## Type Safety

This demo demonstrates the new typed props system where:
1. Props types are defined in Gleam
2. TypeScript types are generated automatically
3. Both frontend and backend share the same type definitions
4. Compile-time type safety across the full stack

## Running the Demo

1. Build the frontend assets:
   ```bash
   npm run build
   ```

2. Start the backend server:
   ```bash
   cd ../backend
   gleam run
   ```

3. Visit http://localhost:8001 to see the typed demo in action

The demo includes:
- **Home page** (`/`) - Overview with navigation
- **User Profile** (`/user/1`) - Demonstrates user data props
- **Blog Post** (`/blog/1`) - Shows blog content with metadata
- **Dashboard** (`/dashboard`) - Admin interface with statistics