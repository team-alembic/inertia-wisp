# Frontend Development

This directory contains the React frontend for the Inertia Gleam project, built with TypeScript and ESBuild.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Build assets for development with watch mode:
```bash
npm run watch
```

This will bundle the TypeScript and watch for changes, automatically rebuilding when files change.

## Scripts

- `npm run dev` - Alias for `npm run watch`
- `npm run watch` - Build and watch for changes (development)
- `npm run build` - Build once (production)
- `npm run type-check` - Run TypeScript type checking without emitting files
- `npm run type-check:watch` - Run TypeScript type checking in watch mode

## Project Structure

```
src/
├── main.tsx          # Application entry point
├── types/            # TypeScript type definitions
│   └── index.ts      # Shared types that match Gleam backend
└── Pages/            # Inertia page components (TypeScript)
    ├── Home.tsx      # Home page component
    ├── About.tsx     # About page component
    ├── Users.tsx     # Users list page
    ├── ShowUser.tsx  # User detail page
    ├── CreateUser.tsx # Create user form
    └── EditUser.tsx  # Edit user form
```

## TypeScript Integration

This project uses TypeScript for type safety between the frontend and backend. The types in `src/types/index.ts` correspond directly to the Gleam types defined in the backend:

### Backend → Frontend Type Mapping

| Gleam Type | TypeScript Type | Description |
|------------|-----------------|-------------|
| `User` | `User` | User entity with id, name, email |
| `CreateUserRequest` | `CreateUserRequest` | Form data for creating users |
| Auth object | `Auth` | Authentication state |
| Validation errors | `ValidationErrors` | Form validation error messages |

### Page Component Props

Each page component has strongly typed props that match what the Gleam backend sends:

```typescript
// Example: ShowUser page expects these exact props
interface ShowUserPageProps extends BasePageProps {
  user: User;  // Matches User type from Gleam backend
}
```

### Form State Management

Form components use typed state management:

```typescript
interface CreateUserFormData {
  name: string;
  email: string;
}
```

This ensures form data matches the backend's expected `CreateUserRequest` structure.

## Development Workflow

1. **Type check your code:**
```bash
npm run type-check
```

2. **Start the asset watcher:**
```bash
npm run watch
```

3. **Start the Gleam server:**
```bash
cd ../..
gleam run
```

4. **Access your app at `http://localhost:8000`**

## Type Safety Benefits

- **Compile-time error detection**: TypeScript catches mismatches between frontend and backend
- **IntelliSense support**: Full autocomplete for props and form data
- **Refactoring safety**: Changes to backend types surface as TypeScript errors
- **Documentation**: Types serve as living documentation of the API contract

## How It Works

- ESBuild compiles TypeScript and watches your source files automatically
- TypeScript provides type checking without affecting the build output
- Bundled assets are written to `../static/js/` with automatic code splitting
- The Gleam server serves static files from the `static/` directory
- React imports are handled automatically with `--jsx=automatic`

## Building for Production

```bash
npm run build
```

This creates a production-optimized bundle in `../static/js/`.

## Adding New Pages

1. **Define types** in `src/types/index.ts` that match your Gleam backend types
2. **Create a new component** in `src/Pages/` (e.g., `Contact.tsx`)
3. **Use the defined prop types** for your component
4. **Export as default** (no React import needed with automatic JSX)
5. **Add the corresponding route** in your Gleam server

Example:
```typescript
import { MyPageProps } from "../types";

export default function MyPage({ myProp, auth, csrf_token }: MyPageProps) {
  return <div>My page content</div>;
}
```

## Keeping Types in Sync

The TypeScript types in this project should always match the Gleam backend types. When you:

- Add new fields to Gleam types → Add them to TypeScript types
- Change field names in Gleam → Update TypeScript types
- Add new page props in Gleam handlers → Update corresponding TypeScript page props

Run `npm run type-check` after backend changes to catch any type mismatches.