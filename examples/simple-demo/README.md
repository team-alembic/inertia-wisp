# Simple Demo - Inertia.js with Gleam

A simple demonstration application showcasing Inertia.js integration with Gleam/Wisp, featuring the new **sessionized errors** functionality.

## Key Features

- **Sessionized Error Handling**: Form validation errors are stored in signed cookies during redirects, providing a seamless user experience
- **HTTPS Support**: Required for secure cookies to work properly
- **User Management**: Complete CRUD operations for users with proper form validation
- **News Feed**: Demonstrates data fetching and display patterns

## Why HTTPS?

This demo runs on HTTPS (port 8443) because the sessionized errors feature uses **secure cookies** to store error messages across redirects. Secure cookies require HTTPS to function properly.

### Sessionized Errors Flow

1. **User submits form** with validation errors
2. **Server processes** the form and detects validation issues  
3. **Errors are stored** in a signed, secure cookie
4. **Server redirects** back to the form (HTTP 303)
5. **Next request loads** the form page with errors from the cookie
6. **Errors are displayed** and the cookie is automatically cleared

This provides a better user experience than rendering errors directly because:
- Follows proper HTTP semantics (POST → Redirect → GET)
- Users can refresh without re-submitting the form
- Clean URLs after form submission

## Setup and Installation

### 1. Install Dependencies

```bash
make install
```

This installs both backend (Gleam) and frontend (Node.js) dependencies.

### 2. Build Assets

```bash
make build
```

### 3. Start the Server

```bash
make start
```

The server will start at `https://localhost:8443`

**Important**: You'll need to accept the self-signed certificate in your browser when first visiting the site.

## Development Mode

For development with file watching:

```bash
# Terminal 1: Watch and rebuild frontend assets
make watch

# Terminal 2: Run the backend server  
gleam run
```

## SSL Certificate

The demo uses a self-signed certificate located in `priv/certs/`. These are automatically generated and suitable for development only.

For production, replace with proper SSL certificates from a trusted CA.


## Available Routes

- `/` - Home page
- `/users` - User listing
- `/users/create` - User creation form (demonstrates sessionized errors)
- `/users/:id` - User details
- `/users/:id/edit` - User editing form
- `/dashboard` - Dashboard with user stats
- `/news` - News feed

## Testing

Run the backend tests:

```bash
make test
```

## Clean Up

Remove build artifacts:

```bash
make clean
```
