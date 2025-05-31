# Typed Demo - Statically Typed Props System

This demo showcases the new statically typed props system for Inertia.js with Gleam, providing compile-time type safety across the full stack.

## Features

- **🔒 Type Safety**: Compile-time type checking for props across Gleam backend and TypeScript frontend
- **📝 Shared Types**: Single source of truth for data structures, defined in Gleam and auto-generated for TypeScript
- **🔄 Transformation-Based**: Build props incrementally using type-safe transformation functions
- **⚡ Partial Reloads**: Maintains all Inertia.js benefits while adding static type checking
- **🎯 Zero Runtime Overhead**: All type checking happens at compile time

## Project Structure

```
typed-demo/
├── src/
│   ├── backend/          # Gleam backend server
│   │   ├── src/
│   │   │   ├── typed_demo_backend.gleam  # Main server
│   │   │   └── handlers.gleam            # Typed request handlers
│   │   └── static/       # Built frontend assets
│   ├── frontend/         # React + TypeScript frontend
│   │   └── src/
│   │       ├── *.tsx     # React components
│   │       ├── main.tsx  # Client entry point
│   │       └── ssr.tsx   # Server-side rendering
│   └── shared/           # Shared type definitions
│       └── src/
│           └── types.gleam  # Gleam type definitions
```

## Quick Start

### 1. Build Shared Types

```bash
cd src/shared
gleam build
```

### 2. Build Frontend Assets

```bash
cd src/frontend
npm install
npm run build
```

### 3. Start Backend Server

```bash
cd src/backend
gleam run
```

### 4. Visit the Demo

Open http://localhost:8001 to explore the typed demo.

## Demo Pages

- **Home** (`/`) - Project overview with feature highlights
- **User Profile** (`/user/1`) - User data with bio and interests  
- **Blog Post** (`/blog/1`) - Article with metadata and tags
- **Dashboard** (`/dashboard`) - Admin stats and recent activity

## How It Works

### 1. Define Types in Gleam

```gleam
// src/shared/src/types.gleam
pub type UserProfilePageProps {
  UserProfilePageProps(
    name: String,
    email: String, 
    id: Int,
    interests: List(String),
    bio: String,
  )
}
```

### 2. Use in Backend Handlers

```gleam
// src/backend/src/handlers.gleam
pub fn user_profile_handler(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  user_id: Int,
) -> wisp.Response {
  let typed_ctx = ctx
    |> inertia.set_props(
      UserProfilePageProps("", "", 0, [], ""), // zero value
      encode_user_profile_props,
    )

  let user = get_user_by_id(user_id)
  
  typed_ctx
  // Always included props (essential user data)
  |> inertia.assign_always_prop("name", fn(props) { 
    UserProfilePageProps(..props, name: user.name) 
  })
  |> inertia.assign_always_prop("id", fn(props) { 
    UserProfilePageProps(..props, id: user.id) 
  })
  // Default props (included in initial load and when requested)
  |> inertia.assign_prop("email", fn(props) { 
    UserProfilePageProps(..props, email: user.email) 
  })
  // Optional props (only included when specifically requested)
  |> inertia.assign_optional_prop("interests", fn(props) { 
    UserProfilePageProps(..props, interests: user.interests) 
  })
  |> inertia.render("UserProfile")
}
```

### 3. Type-Safe Frontend Components

```tsx
// src/frontend/src/UserProfile.tsx
import { UserProfilePageProps } from '../../shared/build/dev/javascript/shared_types/types.mjs';

export default function UserProfile(props: UserProfilePageProps) {
  return (
    <div>
      <h1>{props.name}</h1>
      <p>{props.email}</p>
      {/* TypeScript knows all prop types! */}
    </div>
  );
}
```

## Key Benefits

### Compile-Time Safety
All prop types are validated at compile time in both Gleam and TypeScript, preventing runtime errors from type mismatches.

### Single Source of Truth
Types are defined once in Gleam and automatically generate TypeScript definitions, eliminating duplicate type definitions.

### Direct Type Sharing
Frontend components receive the exact same types defined in Gleam, with no wrapper interfaces or intermediate abstractions. This ensures complete type alignment between backend and frontend.

### Transformation-Based Assignment
Props are built incrementally using transformation functions, maintaining immutability and type safety throughout.

### Advanced Prop Inclusion Patterns
Three distinct prop inclusion behaviors for optimal performance:
- **Always Props**: Critical data included in every response (user info, system status)
- **Default Props**: Standard inclusion in initial loads and when requested (main content)
- **Optional Props**: Expensive data only loaded when specifically requested (analytics, detailed lists)

### Zero Runtime Cost
All type information is erased at runtime - no performance impact compared to regular Inertia.js usage.

### Performance Optimization
Optional props enable lazy loading of expensive computations and database queries, improving initial page load times while maintaining full data access when needed.

### Handling Optional Props
When using optional props, frontend components should handle cases where the data might not be loaded:

```tsx
// Handle optional lists gracefully
{props.interests.toArray().length > 0 ? (
  props.interests.toArray().map((interest: string, index: number) => (
    <span key={index}>{interest}</span>
  ))
) : (
  <p>No interests loaded. This data is only included when specifically requested.</p>
)}

// Handle optional numerical data
{props.view_count > 0 ? `${props.view_count.toLocaleString()} views` : 'Views not loaded'}
```

Optional props use the zero values from your type definition when not requested:
- `List(String)` becomes empty list `[]`
- `Int` becomes `0`
- `String` becomes `""`

## Development

### Frontend Development
```bash
cd src/frontend
npm run dev        # Watch mode with hot reloading
npm run type-check # TypeScript validation
```

### Backend Development
```bash
cd src/backend
gleam run          # Start server
gleam test         # Run tests
```

## Technology Stack

- **Backend**: Gleam + Wisp + Mist
- **Frontend**: React + TypeScript + ESBuild + Tailwind CSS
- **Build**: ESBuild for bundling, Tailwind CLI for CSS
- **Types**: Gleam → TypeScript code generation

## Related

- [Main Demo](../demo/) - Original Inertia.js Gleam demo
- [Inertia Wisp](../../) - Core Inertia.js integration for Gleam