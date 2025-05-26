# Frontend Development Guide

This guide covers developing React frontends for Inertia Gleam applications using TypeScript and ESBuild.

## Overview

The frontend development setup provides:

- **TypeScript Integration** - Type safety between frontend and backend
- **React Components** - Modern JSX with automatic imports
- **ESBuild Bundling** - Fast development builds with watch mode
- **Code Splitting** - Automatic component-level code splitting
- **Type Checking** - Compile-time error detection

## Setup

### Dependencies

```bash
cd examples/minimal/frontend
npm install
```

Core dependencies:
- `@inertiajs/react` - Inertia.js React adapter
- `react` & `react-dom` - React framework
- `typescript` - TypeScript compiler
- `esbuild` - Fast JavaScript bundler

### Build Scripts

```json
{
  "scripts": {
    "dev": "npm run watch",
    "watch": "node esbuild.config.js --watch",
    "build": "node esbuild.config.js",
    "type-check": "tsc --noEmit",
    "type-check:watch": "tsc --noEmit --watch"
  }
}
```

## Project Structure

```
frontend/
├── src/
│   ├── main.tsx                    # Application entry point
│   ├── types/
│   │   └── index.ts                # Shared type definitions
│   └── Pages/                      # Inertia page components
│       ├── Home.tsx
│       ├── About.tsx
│       ├── Users.tsx
│       ├── CreateUser.tsx
│       ├── ShowUser.tsx
│       ├── EditUser.tsx
│       ├── UploadForm.tsx
│       └── UploadSuccess.tsx
├── package.json
├── tsconfig.json                   # TypeScript configuration
└── esbuild.config.js              # Build configuration
```

## TypeScript Integration

### Type Definitions

Types in `src/types/index.ts` correspond directly to Gleam backend types:

```typescript
// Base props included on every page
export interface BasePageProps {
  auth?: {
    authenticated: boolean;
    user: string;
  };
  csrf_token: string;
  errors?: Record<string, string>;
}

// Backend entity types
export interface User {
  id: number;
  name: string;
  email: string;
}

// Form request types
export interface CreateUserRequest {
  name: string;
  email: string;
}

// Page-specific prop interfaces
export interface UsersPageProps extends BasePageProps {
  users: User[];
}

export interface ShowUserPageProps extends BasePageProps {
  user: User;
}

export interface CreateUserPageProps extends BasePageProps {
  old?: CreateUserRequest;
}
```

### Type Safety Benefits

- **Compile-time validation**: Catches prop mismatches before runtime
- **IntelliSense**: Full autocomplete for props and form data
- **Refactoring safety**: Backend changes surface as TypeScript errors
- **Documentation**: Types serve as living API documentation

## Component Development

### Basic Page Component

```typescript
import { BasePageProps } from "../types";

interface AboutPageProps extends BasePageProps {
  message: string;
}

export default function About({ message, auth, csrf_token }: AboutPageProps) {
  return (
    <div>
      <h1>About Page</h1>
      <p>{message}</p>
      {auth?.authenticated && <p>Welcome, {auth.user}!</p>}
    </div>
  );
}
```

### Form Component with Validation

```typescript
import { useState, FormEvent } from "react";
import { router } from "@inertiajs/react";
import { CreateUserPageProps, CreateUserRequest } from "../types";

export default function CreateUser({
  auth,
  csrf_token,
  errors = {},
  old = { name: "", email: "" }
}: CreateUserPageProps) {
  const [formData, setFormData] = useState<CreateUserRequest>(old);

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    router.post("/users", formData);
  };

  const handleChange = (field: keyof CreateUserRequest) => (
    e: React.ChangeEvent<HTMLInputElement>
  ) => {
    setFormData(prev => ({ ...prev, [field]: e.target.value }));
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="_token" type="hidden" value={csrf_token} />

      <div>
        <label htmlFor="name">Name:</label>
        <input
          id="name"
          type="text"
          value={formData.name}
          onChange={handleChange("name")}
          className={errors.name ? "error" : ""}
        />
        {errors.name && <span className="error">{errors.name}</span>}
      </div>

      <div>
        <label htmlFor="email">Email:</label>
        <input
          id="email"
          type="email"
          value={formData.email}
          onChange={handleChange("email")}
          className={errors.email ? "error" : ""}
        />
        {errors.email && <span className="error">{errors.email}</span>}
      </div>

      <button type="submit">Create User</button>
    </form>
  );
}
```

### File Upload Component

```typescript
import { useState, DragEvent, ChangeEvent } from "react";
import { router } from "@inertiajs/react";

interface UploadFormPageProps extends BasePageProps {
  max_files: number;
  max_size_mb: number;
  allowed_types?: string[];
}

export default function UploadForm({
  auth,
  csrf_token,
  errors = {},
  max_files,
  max_size_mb,
  allowed_types = []
}: UploadFormPageProps) {
  const [files, setFiles] = useState<File[]>([]);
  const [isDragOver, setIsDragOver] = useState(false);

  const handleDrop = (e: DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragOver(false);

    const droppedFiles = Array.from(e.dataTransfer.files);
    validateAndSetFiles(droppedFiles);
  };

  const handleFileSelect = (e: ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const selectedFiles = Array.from(e.target.files);
      validateAndSetFiles(selectedFiles);
    }
  };

  const validateAndSetFiles = (fileList: File[]) => {
    // Client-side validation
    const validFiles = fileList.filter(file => {
      if (file.size > max_size_mb * 1024 * 1024) return false;
      if (allowed_types.length > 0 && !allowed_types.includes(file.type)) return false;
      return true;
    });

    setFiles(prev => [...prev, ...validFiles].slice(0, max_files));
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();

    const formData = new FormData();
    formData.append("_token", csrf_token);
    files.forEach((file, index) => {
      formData.append(`files[${index}]`, file);
    });

    router.post("/upload", formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <div
        className={`upload-area ${isDragOver ? "drag-over" : ""}`}
        onDrop={handleDrop}
        onDragOver={(e) => { e.preventDefault(); setIsDragOver(true); }}
        onDragLeave={() => setIsDragOver(false)}
        onClick={() => document.getElementById("file-input")?.click()}
      >
        <input
          id="file-input"
          type="file"
          multiple
          accept={allowed_types.join(",")}
          onChange={handleFileSelect}
          style={{ display: "none" }}
        />

        <p>Drop files here or click to browse</p>
        <p>Max {max_files} files, {max_size_mb}MB each</p>
      </div>

      {files.length > 0 && (
        <div className="file-list">
          {files.map((file, index) => (
            <div key={index} className="file-item">
              <span>{file.name}</span>
              <span>{(file.size / 1024).toFixed(1)} KB</span>
              <button
                type="button"
                onClick={() => setFiles(prev => prev.filter((_, i) => i !== index))}
              >
                ×
              </button>
            </div>
          ))}
        </div>
      )}

      {Object.keys(errors).length > 0 && (
        <div className="errors">
          {Object.entries(errors).map(([field, message]) => (
            <div key={field} className="error">{message}</div>
          ))}
        </div>
      )}

      <button type="submit" disabled={files.length === 0}>
        Upload Files
      </button>
    </form>
  );
}
```

## Development Workflow

### Starting Development

1. **Start asset watcher:**
```bash
cd frontend
npm run watch
```

2. **Start Gleam server (separate terminal):**
```bash
cd examples/minimal
gleam run
```

3. **Make changes and refresh browser**

### Type Checking

Run TypeScript type checking separately from building:

```bash
# Check once
npm run type-check

# Watch mode
npm run type-check:watch
```

### Build Process

ESBuild configuration (`esbuild.config.js`):

```javascript
const esbuild = require('esbuild');

const isWatch = process.argv.includes('--watch');

const config = {
  entryPoints: ['src/main.tsx'],
  bundle: true,
  outdir: '../static/js',
  splitting: true,
  format: 'esm',
  jsx: 'automatic',
  loader: {
    '.tsx': 'tsx',
    '.ts': 'ts'
  },
  external: [],
  define: {
    'process.env.NODE_ENV': '"development"'
  }
};

if (isWatch) {
  esbuild.context(config).then(ctx => ctx.watch());
} else {
  esbuild.build(config);
}
```

## Styling

### CSS Integration

```typescript
// Import CSS in components
import "./ComponentName.css";

export default function ComponentName() {
  return <div className="component-name">...</div>;
}
```

### Tailwind CSS (Optional)

Add Tailwind for utility-first styling:

```bash
npm install -D tailwindcss
npx tailwindcss init
```

Configure in `tailwind.config.js`:

```javascript
module.exports = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

## Navigation

### Using Inertia Links

```typescript
import { Link } from "@inertiajs/react";

export default function Navigation() {
  return (
    <nav>
      <Link href="/">Home</Link>
      <Link href="/about">About</Link>
      <Link href="/users">Users</Link>
    </nav>
  );
}
```

### Programmatic Navigation

```typescript
import { router } from "@inertiajs/react";

const handleClick = () => {
  router.visit("/users");
  // or
  router.get("/users");
  // or
  router.post("/users", formData);
};
```

## Error Handling

### Global Error Handling

```typescript
// src/main.tsx
import { createInertiaApp } from "@inertiajs/react";

createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('./Pages/**/*.tsx', { eager: true });
    return pages[`./Pages/${name}.tsx`];
  },
  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />);
  },
  onError: (error) => {
    console.error('Inertia error:', error);
  },
});
```

### Component Error Boundaries

```typescript
import { ErrorBoundary } from "react-error-boundary";

function ErrorFallback({ error }: { error: Error }) {
  return (
    <div className="error-boundary">
      <h2>Something went wrong:</h2>
      <pre>{error.message}</pre>
    </div>
  );
}

export default function App({ children }: { children: React.ReactNode }) {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      {children}
    </ErrorBoundary>
  );
}
```

## Testing

### Component Testing with Jest

```bash
npm install -D jest @testing-library/react @testing-library/jest-dom
```

Example test:

```typescript
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Home from '../Pages/Home';

test('renders welcome message', () => {
  const props = {
    message: "Hello World",
    auth: { authenticated: true, user: "John" },
    csrf_token: "abc123"
  };

  render(<Home {...props} />);

  expect(screen.getByText('Hello World')).toBeInTheDocument();
  expect(screen.getByText('Welcome, John!')).toBeInTheDocument();
});
```

## Adding New Pages

### 1. Define Types

```typescript
// src/types/index.ts
export interface ContactPageProps extends BasePageProps {
  email: string;
  phone: string;
}
```

### 2. Create Component

```typescript
// src/Pages/Contact.tsx
import { ContactPageProps } from "../types";

export default function Contact({ email, phone, auth }: ContactPageProps) {
  return (
    <div>
      <h1>Contact Us</h1>
      <p>Email: {email}</p>
      <p>Phone: {phone}</p>
    </div>
  );
}
```

### 3. Update Backend Route

The corresponding Gleam handler should render this component:

```gleam
req
|> inertia_gleam.assign_prop("email", json.string("contact@example.com"))
|> inertia_gleam.assign_prop("phone", json.string("555-0123"))
|> inertia_gleam.render("Contact")
```

## Best Practices

1. **Keep types in sync** - Update TypeScript types when Gleam types change
2. **Use specific prop types** - Avoid `any` or overly generic interfaces
3. **Handle loading states** - Show appropriate UI during navigation
4. **Validate client-side** - Provide immediate feedback before server validation
5. **Use semantic HTML** - Ensure accessibility and SEO
6. **Extract reusable components** - Share common UI patterns
7. **Test components** - Write unit tests for complex logic

## Troubleshooting

### TypeScript Errors

```bash
# Check for type errors
npm run type-check

# Common issues:
# - Missing prop in interface
# - Incorrect prop type from backend
# - Missing null checks for optional props
```

### Build Issues

```bash
# Clear build cache
rm -rf ../static/js/*
npm run build

# Check ESBuild output for errors
# Verify file paths and imports
```

### Runtime Errors

- Check browser console for component errors
- Verify component names match between frontend and backend
- Ensure props match expected TypeScript interfaces
- Check that Inertia.js is properly initialized

This frontend development setup provides a robust foundation for building type-safe, modern React applications with Inertia.js and Gleam backends.
