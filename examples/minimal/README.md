# Minimal Inertia Gleam Example

This is a complete, standalone Gleam application demonstrating how to use the `inertia-gleam` library with React frontend components. It showcases form handling, validation, redirects, and full CRUD operations.

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

## Features Demonstrated

- **Navigation**: Seamless SPA navigation using Inertia.js
- **Props System**: Server-side data passing to React components
- **Forms & Validation**: User creation and editing with validation
- **Error Handling**: Form validation errors with field-level feedback
- **Redirects**: Proper redirect handling after form submissions
- **CRUD Operations**: Complete user management (Create, Read, Update, Delete)
- **Always Props**: Authentication and CSRF tokens on every request

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
│   └── minimal_inertia_example.gleam  # Gleam web server with CRUD routes
├── frontend/
│   ├── src/
│   │   ├── main.jsx         # React entry point
│   │   └── Pages/           # Inertia page components
│   │       ├── Home.jsx     # Welcome page with navigation
│   │       ├── About.jsx    # About page
│   │       ├── Users.jsx    # User list with CRUD actions
│   │       ├── CreateUser.jsx # User creation form
│   │       ├── ShowUser.jsx # User detail view
│   │       └── EditUser.jsx # User editing form
│   └── package.json
├── static/
│   └── js/
│       └── main.js          # Built frontend assets
├── gleam.toml               # Gleam project config
└── README.md
```

## How It Works

1. **Frontend**: React components in `frontend/src/Pages/` are bundled by ESBuild into `static/js/` with automatic code splitting
2. **Backend**: Gleam server handles both GET and POST requests, with form validation and redirects
3. **Routing**: HTTP method-based routing handles different actions (GET for pages, POST for forms)
4. **Forms**: Form submissions use Inertia.js POST requests with validation and error handling
5. **Static Assets**: The Gleam server serves static files from the `static/` directory

## Available Routes

- `GET /` - Home page
- `GET /about` - About page  
- `GET /users` - List all users
- `GET /users/create` - User creation form
- `POST /users` - Create new user (with validation)
- `GET /users/:id` - Show user details
- `GET /users/:id/edit` - User editing form
- `POST /users/:id` - Update user (with validation)
- `POST /users/:id/delete` - Delete user

## Form Handling Example

The user management system demonstrates complete form handling:

1. **Form Creation:**
```gleam
fn create_user(req: wisp.Request) -> wisp.Response {
  use form_data <- wisp.require_form(req)
  
  let name = wisp.get_form_value(form_data, "name") |> result.unwrap("")
  let email = wisp.get_form_value(form_data, "email") |> result.unwrap("")
  
  let errors = validate_user_input(name, email, None)
  
  case dict.size(errors) {
    0 -> inertia_gleam.redirect_after_form(req, "/users")
    _ -> 
      inertia_gleam.context(req)
      |> inertia_gleam.assign_errors(errors)
      |> inertia_gleam.assign_prop("old", json.object([
           #("name", json.string(name)),
           #("email", json.string(email)),
         ]))
      |> inertia_gleam.render("CreateUser")
  }
}
```

2. **Frontend Form:**
```jsx
// frontend/src/Pages/CreateUser.jsx
const handleSubmit = (e) => {
  e.preventDefault();
  router.post("/users", formData);
};
```

## Adding New Pages

1. **Create React component:**
```jsx
// frontend/src/Pages/Contact.jsx
export default function Contact({ email }) {
    return <div>Contact us at: {email}</div>
}
```

2. **Add Gleam route:**
```gleam
// src/minimal_inertia_example.gleam
case wisp.path_segments(req), req.method {
  [], http.Get -> home_page(req)
  ["about"], http.Get -> about_page(req)
  ["contact"], http.Get -> contact_page(req)  // Add this
  // ...
}

fn contact_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> inertia_gleam.assign_prop("email", json.string("hello@example.com"))
  |> inertia_gleam.render("Contact")
}
```

## Frontend Scripts

- `npm run build` - Build once for production
- `npm run watch` - Build and watch for changes (development)
- `npm run dev` - Alias for `npm run watch`

## Key Features Used

This example demonstrates the full capabilities of the `inertia-gleam` library:

### Core Features
- **Inertia.js middleware** for Wisp web framework
- **HTML template generation** for initial page loads
- **JSON response handling** for XHR requests
- **Context-based prop assignment** with pipe-friendly API

### Form Features
- **Validation error handling** with `assign_errors()`
- **Form data preservation** on validation failures
- **Redirect after successful submissions** with `redirect_after_form()`
- **CSRF token support** via always props

### Advanced Props
- **Always props** for authentication and CSRF tokens
- **Regular props** for page-specific data
- **Old input preservation** for form re-submission

## Demo Walkthrough

### Quick Test Commands

Start the server:
```bash
cd examples/minimal
gleam run
```

Test basic endpoints:
```bash
# Home page (HTML response)
curl http://localhost:8000/

# Users list (HTML response)
curl http://localhost:8000/users

# Same page via Inertia XHR (JSON response)
curl -H "X-Inertia: true" http://localhost:8000/users

# User creation form
curl http://localhost:8000/users/create

# Individual user page
curl http://localhost:8000/users/1
```

### Interactive Testing

1. **Navigate between pages** - Notice no full page reloads
2. **Create a user** - Try invalid data to see validation
   - Empty name/email → validation errors
   - Short name → "Name must be at least 2 characters"
   - Invalid email → "Email must contain @"
   - Duplicate email (alice@example.com) → "Email already exists"
3. **Edit existing users** - Form pre-population and validation
4. **Delete users** - Confirmation and redirect handling
5. **Use browser back/forward** - SPA navigation works correctly

### Expected Behaviors

- **Full page loads**: Initial visits return HTML with `<div id="app" data-page="...">` 
- **XHR navigation**: Subsequent clicks return JSON `{"component": "...", "props": {...}, ...}`
- **Form validation**: Invalid submissions return to form with errors preserved
- **Successful forms**: Valid submissions redirect to success page
- **Always props**: Auth and CSRF tokens included on every request
</edits>

## Dependencies

This example uses the `inertia-gleam` library as a local path dependency from the parent directory.