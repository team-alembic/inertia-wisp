# Minimal Inertia Gleam Example

This is a complete, standalone Gleam application demonstrating how to use the `inertia-gleam` library with React frontend components. It showcases the full capabilities of building modern single-page applications with server-side routing.

## Overview

The minimal example demonstrates:

- **Navigation**: Seamless SPA navigation using Inertia.js
- **Props System**: Server-side data passing to React components
- **Forms & Validation**: User creation and editing with validation
- **File Uploads**: Complete file upload system with drag & drop support
- **Error Handling**: Form validation errors with field-level feedback
- **Redirects**: Proper redirect handling after form submissions
- **CRUD Operations**: Complete user management (Create, Read, Update, Delete)
- **Always Props**: Authentication and CSRF tokens on every request

## Quick Start

1. **Install frontend dependencies:**
```bash
cd examples/minimal/frontend
npm install
```

2. **Build frontend assets:**
```bash
npm run build
```

3. **Run the Gleam server:**
```bash
cd examples/minimal
gleam run
```

4. **Visit http://localhost:8000**

## Project Structure

### Backend Structure (Gleam)

```
examples/minimal/
├── src/
│   ├── minimal_inertia_example.gleam    # Main application entry point
│   ├── types/
│   │   └── user.gleam                   # User-related type definitions
│   ├── data/
│   │   └── users.gleam                  # Data access and state management
│   ├── validators/
│   │   └── user_validator.gleam         # User input validation logic
│   └── handlers/
│       ├── utils.gleam                  # Shared handler utilities
│       ├── users.gleam                  # Aggregated user handlers
│       ├── uploads.gleam                # File upload handlers
│       └── users/                       # Individual user operation handlers
│           ├── create_handler.gleam
│           ├── list_handler.gleam
│           ├── show_handler.gleam
│           ├── edit_handler.gleam
│           └── delete_handler.gleam
├── static/
│   └── js/                              # Built frontend assets
│       └── main.js
└── gleam.toml                           # Gleam project configuration
```

### Frontend Structure (React + TypeScript)

```
examples/minimal/frontend/
├── src/
│   ├── main.tsx                         # Application entry point
│   ├── types/
│   │   └── index.ts                     # TypeScript type definitions
│   └── Pages/                           # Inertia page components
│       ├── Home.tsx                     # Welcome page with navigation
│       ├── About.tsx                    # About page
│       ├── Users.tsx                    # User list with CRUD actions
│       ├── CreateUser.tsx               # User creation form
│       ├── ShowUser.tsx                 # User detail view
│       ├── EditUser.tsx                 # User editing form
│       ├── UploadForm.tsx               # File upload interface
│       └── UploadSuccess.tsx            # Upload success page
├── package.json                         # Frontend dependencies
└── esbuild.config.js                    # Build configuration
```

## Available Routes

### User Management
- `GET /` - Home page with navigation
- `GET /about` - About page
- `GET /users` - List all users
- `GET /users/create` - User creation form
- `POST /users` - Create new user (with validation)
- `GET /users/:id` - Show user details
- `GET /users/:id/edit` - User editing form
- `POST /users/:id` - Update user (with validation)
- `POST /users/:id/delete` - Delete user

### File Upload
- `GET /upload` - File upload form
- `POST /upload` - Process file upload (with validation)

## Key Features Demonstrated

### Core Inertia Features
- **HTML template generation** for initial page loads
- **JSON response handling** for XHR requests
- **Context-based prop assignment** with pipe-friendly API
- **Multiple component routing** with seamless navigation

### Form Handling
- **Validation error handling** with `assign_errors()`
- **Form data preservation** on validation failures
- **Redirect after successful submissions** with `redirect()`
- **CSRF token support** via always props

### File Upload System
- **Multipart form handling** with validation
- **File type and size restrictions**
- **Drag & drop interface** with progress indicators
- **Comprehensive error handling**

### Advanced Props
- **Always props** for authentication and CSRF tokens
- **Regular props** for page-specific data
- **Old input preservation** for form re-submission

## Development Workflow

### Active Development with Auto-rebuild

1. **Start frontend watcher (Terminal 1):**
```bash
cd examples/minimal/frontend
npm run watch
```

2. **Start Gleam server (Terminal 2):**
```bash
cd examples/minimal
gleam run
```

3. **Make changes and refresh browser**

### Frontend Scripts
- `npm run build` - Build once for production
- `npm run watch` - Build and watch for changes (development)
- `npm run dev` - Alias for `npm run watch`
- `npm run type-check` - TypeScript type checking
- `npm run type-check:watch` - Type checking in watch mode

## TypeScript Integration

The frontend uses TypeScript for type safety between frontend and backend:

### Type Definitions

```typescript
// src/types/index.ts
export interface User {
  id: number;
  name: string;
  email: string;
}

export interface CreateUserRequest {
  name: string;
  email: string;
}

export interface BasePageProps {
  auth?: { authenticated: boolean; user: string };
  csrf_token: string;
  errors?: Record<string, string>;
}
```

### Page Component Example

```typescript
// src/Pages/CreateUser.tsx
interface CreateUserPageProps extends BasePageProps {
  old?: CreateUserRequest;
}

export default function CreateUser({ auth, csrf_token, errors, old }: CreateUserPageProps) {
  // Component implementation with full type safety
}
```

## Form Handling Example

### Backend Handler

```gleam
fn create_user(req: inertia_gleam.InertiaContext) -> wisp.Response {
  use form_data <- wisp.require_form(req)

  let name = wisp.get_form_value(form_data, "name") |> result.unwrap("")
  let email = wisp.get_form_value(form_data, "email") |> result.unwrap("")

  let errors = validate_user_input(name, email, None)

  case dict.size(errors) {
    0 -> inertia_gleam.redirect(req, "/users")
    _ ->
      req
      |> utils.assign_common_props()
      |> inertia_gleam.assign_errors(errors)
      |> inertia_gleam.assign_prop("old", json.object([
           #("name", json.string(name)),
           #("email", json.string(email)),
         ]))
      |> inertia_gleam.render("CreateUser")
  }
}
```

### Frontend Form

```typescript
// src/Pages/CreateUser.tsx
const handleSubmit = (e: React.FormEvent) => {
  e.preventDefault();
  router.post("/users", formData);
};
```

## File Upload Features

### Upload Configuration

```gleam
let config = inertia_gleam.upload_config(
  max_file_size: 5_000_000,  // 5MB
  allowed_types: ["image/jpeg", "image/png", "image/gif", "application/pdf"],
  max_files: 3
)
```

### Upload UI Features
- **Drag & Drop Interface** - Modern file selection experience
- **File Validation** - Size, type, and count restrictions
- **Progress Indicators** - Visual feedback during uploads
- **Error Handling** - Clear validation error messages
- **File Preview** - Shows selected files with metadata

## Testing the Example

### Manual Testing Commands

```bash
# Start the server
cd examples/minimal
gleam run

# Test basic endpoints
curl http://localhost:8000/                    # Home page (HTML)
curl http://localhost:8000/users               # Users list (HTML)
curl -H "X-Inertia: true" http://localhost:8000/users  # Same page (JSON)
curl http://localhost:8000/users/1             # Individual user
```

### Interactive Testing Scenarios

1. **Navigate between pages** - Notice no full page reloads
2. **Create a user** - Try invalid data to see validation:
   - Empty name/email → validation errors
   - Short name → "Name must be at least 2 characters"
   - Invalid email → "Email must contain @"
   - Duplicate email → "Email already exists"
3. **Edit existing users** - Form pre-population and validation
4. **Delete users** - Confirmation and redirect handling
5. **Upload files** - Test drag & drop, validation, and success flow
6. **Use browser back/forward** - SPA navigation works correctly

## Adding New Pages

### 1. Create React Component

```typescript
// frontend/src/Pages/Contact.tsx
interface ContactPageProps extends BasePageProps {
  email: string;
}

export default function Contact({ email, auth, csrf_token }: ContactPageProps) {
  return <div>Contact us at: {email}</div>;
}
```

### 2. Add Gleam Route

```gleam
// src/minimal_inertia_example.gleam
case wisp.path_segments(req), req.method {
  [], http.Get -> home_page(req)
  ["about"], http.Get -> about_page(req)
  ["contact"], http.Get -> contact_page(req)  // Add this
  // ...
}

fn contact_page(req: inertia_gleam.InertiaContext) -> wisp.Response {
  req
  |> utils.assign_common_props()
  |> inertia_gleam.assign_prop("email", json.string("hello@example.com"))
  |> inertia_gleam.render("Contact")
}
```

## Expected Behaviors

- **Full page loads**: Initial visits return HTML with `<div id="app" data-page="...">`
- **XHR navigation**: Subsequent clicks return JSON `{"component": "...", "props": {...}, ...}`
- **Form validation**: Invalid submissions return to form with errors preserved
- **Successful forms**: Valid submissions redirect to success page
- **Always props**: Auth and CSRF tokens included on every request
- **File uploads**: Complete validation and success flow

## Architecture Benefits

### Modular Structure
- **Separation of Concerns**: Each module has well-defined responsibility
- **Reusability**: Validation and data access logic shared across handlers
- **Maintainability**: Changes to specific operations only affect their modules
- **Testability**: Individual handlers and validators tested in isolation

### Type Safety
- **Compile-time error detection**: TypeScript catches frontend/backend mismatches
- **IntelliSense support**: Full autocomplete for props and form data
- **Refactoring safety**: Backend type changes surface as TypeScript errors
- **Living documentation**: Types serve as API contract documentation

This example serves as a comprehensive template for building Inertia.js applications with Gleam, demonstrating production-ready patterns for forms, validation, file uploads, and SPA navigation.
