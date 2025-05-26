# Always Props in Inertia Gleam

Always props are properties that are automatically included in every Inertia response, regardless of the specific page or component being rendered. This is useful for data that should be available globally across your application, such as authentication status, CSRF tokens, or user preferences.

## Basic Usage

### Adding Always Props

Use `assign_always_prop()` to add a single always prop:

```gleam
import inertia_gleam
import gleam/json

pub fn handle_request(req: inertia_gleam.InertiaContext) -> wisp.Response {
  req
  |> inertia_gleam.assign_always_prop("csrf_token", json.string("abc123"))
  |> inertia_gleam.assign_prop("page_data", json.string("specific data"))
  |> inertia_gleam.render("HomePage")
}
```

### Adding Multiple Always Props

Use `assign_always_props()` to add multiple always props at once:

```gleam
pub fn handle_request(req: inertia_gleam.InertiaContext) -> wisp.Response {
  let global_props = [
    #("auth", json.string("authenticated")),
    #("csrf_token", json.string("abc123")),
    #("app_version", json.string("1.2.3")),
  ]

  req
  |> inertia_gleam.assign_always_props(global_props)
  |> inertia_gleam.assign_prop("posts", json.array([], json.string))
  |> inertia_gleam.render("BlogIndex")
}
```

### Lazy Always Props

For expensive calculations that should be available globally but only computed when needed:

```gleam
pub fn handle_request(req: inertia_gleam.InertiaContext) -> wisp.Response {
  let get_user_permissions = fn() {
    // Expensive database query or computation
    json.string("admin,editor,viewer")
  }

  req
  |> inertia_gleam.assign_always_lazy_prop("permissions", get_user_permissions)
  |> inertia_gleam.assign_prop("content", json.string("page content"))
  |> inertia_gleam.render("Dashboard")
}
```

## Behavior with Different Request Types

### Full Page Requests

On initial page loads (non-XHR requests), all always props are included along with page-specific props:

```json
{
  "component": "HomePage",
  "props": {
    "csrf_token": "abc123",
    "auth": "authenticated",
    "page_data": "specific data"
  },
  "url": "/",
  "version": "1"
}
```

### XHR Requests

On Inertia XHR requests, always props are still included:

```json
{
  "component": "AboutPage",
  "props": {
    "csrf_token": "abc123",
    "auth": "authenticated",
    "about_content": "About us content"
  },
  "url": "/about",
  "version": "1"
}
```

### Partial Reloads

**Important**: Always props are included even during partial reloads, ensuring critical global data is always available:

```javascript
// Frontend request for only "posts" prop
fetch('/blog', {
  headers: {
    'X-Inertia': 'true',
    'X-Inertia-Partial-Data': 'posts'
  }
})
```

Response includes always props + requested props:

```json
{
  "component": "BlogIndex",
  "props": {
    "csrf_token": "abc123",
    "auth": "authenticated",
    "posts": [...]
  },
  "url": "/blog",
  "version": "1"
}
```

## Prop Precedence

When the same key exists in both always props and regular props, **regular props take precedence**:

```gleam
req
|> inertia_gleam.assign_always_prop("title", json.string("Default Title"))
|> inertia_gleam.assign_prop("title", json.string("Page Specific Title"))
|> inertia_gleam.render("SomePage")
// Result: title = "Page Specific Title"
```

## Common Use Cases

### Authentication Data

```gleam
let auth_props = case get_current_user(req) {
  Ok(user) -> [
    #("auth", json.object([
      #("authenticated", json.bool(True)),
      #("user_id", json.int(user.id)),
      #("username", json.string(user.name))
    ]))
  ]
  Error(_) -> [
    #("auth", json.object([
      #("authenticated", json.bool(False))
    ]))
  ]
}

req
|> inertia_gleam.assign_always_props(auth_props)
|> inertia_gleam.render("AnyPage")
```

### CSRF Protection

```gleam
import gleam/crypto

pub fn handle_request(req: inertia_gleam.InertiaContext) -> wisp.Response {
  let csrf_token = crypto.strong_random_bytes(32) |> crypto.encode_base64()

  req
  |> inertia_gleam.assign_always_prop("csrf_token", json.string(csrf_token))
  |> inertia_gleam.render("FormPage")
}
```

### Application Configuration

```gleam
let app_config = [
  #("app_name", json.string("My App")),
  #("version", json.string("1.0.0")),
  #("environment", json.string("production")),
  #("feature_flags", json.object([
    #("new_ui", json.bool(True)),
    #("beta_features", json.bool(False))
  ]))
]

req
|> inertia_gleam.assign_always_props(app_config)
|> inertia_gleam.render("HomePage")
```

## Performance Considerations

### Lazy Always Props for Expensive Operations

Use lazy always props for data that's expensive to compute but might not always be needed:

```gleam
// Only computed when the prop is actually included in the response
let expensive_calculation = fn() {
  // Database queries, API calls, complex computations
  calculate_user_dashboard_stats()
  |> json.object()
}

req
|> inertia_gleam.assign_always_lazy_prop("dashboard_stats", expensive_calculation)
|> inertia_gleam.render("SomePage")
```

### Minimize Always Props Size

Keep always props lightweight since they're included in every request:

```gleam
// Good: Essential data only
|> assign_always_prop("user_id", json.int(123))
|> assign_always_prop("csrf", json.string("token"))

// Avoid: Large datasets that aren't always needed
// |> assign_always_prop("all_users", json.array(huge_list, encode_user))
```

## Testing Always Props

The testing module includes helpers for verifying always props behavior:

```gleam
import inertia_gleam/testing

pub fn test_always_props() {
  let req = testing.mock_inertia_request()
  let response =
    req
    |> inertia_gleam.assign_always_prop("csrf", json.string("test_token"))
    |> inertia_gleam.assign_prop("content", json.string("page_content"))
    |> inertia_gleam.render("TestPage")

  // Verify both always props and regular props are present
  testing.assert_string_prop(response, "csrf", "test_token")
  testing.assert_string_prop(response, "content", "page_content")
}
```

## Best Practices

1. **Keep always props minimal** - Only include data that's truly needed on every page
2. **Use lazy always props** for expensive computations
3. **Prefer regular props** for page-specific data
4. **Use consistent naming** for always props across your application
5. **Document your always props** so team members know what's globally available
