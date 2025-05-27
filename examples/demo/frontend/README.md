# Frontend

React + TypeScript frontend for the demo Inertia Gleam example.

## Setup

```bash
npm install
npm run build
```

## Development

Start the watcher for auto-rebuilding:
```bash
npm run watch
```

## Scripts

- `npm run build` - Build once
- `npm run watch` - Build and watch for changes
- `npm run type-check` - TypeScript type checking

## Structure

```
src/
├── main.tsx          # Entry point
├── types/index.ts    # Type definitions
└── Pages/            # React components
    ├── Home.tsx
    ├── Users.tsx
    ├── CreateUser.tsx
    └── UploadForm.tsx
```

## More Information

For detailed frontend development documentation, see [../../docs/examples/frontend-development.md](../../docs/examples/frontend-development.md).