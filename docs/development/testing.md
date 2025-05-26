# Testing Guide for Inertia Gleam

This guide covers testing strategies for both the Inertia Gleam library itself and applications built with it.

## Quick Start

### Testing Your Application

```gleam
import gleam/dynamic/decode
import gleeunit/should
import inertia_gleam/testing

pub fn my_handler_test() {
  let req = testing.inertia_request()
  let response = my_handler(req)
  
  // Test component
  testing.component(response) |> should.equal(Ok("HomePage"))
  
  // Test props
  testing.prop(response, "title", decode.string) 
  |> should.equal(Ok("Welcome"))
  
  testing.prop(response, "count", decode.int) 
  |> should.equal(Ok(42))
}
```

### Manual Testing

1. **Start the example server:**
   ```bash
   cd examples/minimal
   gleam run
   ```

2. **Test browser requests (should return HTML):**
   ```bash
   curl http://localhost:8000/
   curl http://localhost:8000/about
   ```

3. **Test Inertia XHR requests (should return JSON):**
   ```bash
   curl -H "X-Inertia: true" http://localhost:8000/
   curl -H "X-Inertia: true" http://localhost:8000/about
   ```

## Testing API Reference

### Creating Test Requests

#### `testing.inertia_request()`
Creates a mock Inertia XHR request with proper headers:
- `x-inertia: true`
- `x-inertia-version: 1`
- `accept: application/json`

```gleam
let req = testing.inertia_request()
```

#### `testing.partial_data(request, props)`
Adds partial data headers to request only specific props:

```gleam
let req = testing.inertia_request()
  |> testing.partial_data(["posts", "user"])
// Will only request "posts" and "user" props
```

### Testing Responses

#### `testing.component(response)`
Extracts and verifies the component name:

```gleam
testing.component(response) |> should.equal(Ok("Dashboard"))
```

#### `testing.prop(response, key, decoder)`
Extracts and decodes a specific prop value:

```gleam
// String prop
testing.prop(response, "message", decode.string)
|> should.equal(Ok("Hello World"))

// Integer prop
testing.prop(response, "count", decode.int)
|> should.equal(Ok(123))

// Boolean prop
testing.prop(response, "active", decode.bool)
|> should.equal(Ok(True))

// Missing prop (returns Error)
testing.prop(response, "missing", decode.string)
|> should.be_error
```

#### `testing.url(response)` and `testing.version(response)`
Extract URL and version from responses:

```gleam
testing.url(response) |> should.equal(Ok("/dashboard"))
testing.version(response) |> should.equal(Ok("1"))
```

## Manual Testing Scenarios

### Expected Behavior

#### ✅ Success Criteria

- **Initial Load**: Browser requests return HTML with embedded JSON in `data-page`
- **Navigation**: XHR requests with `X-Inertia: true` return JSON only
- **Props**: Props are correctly serialized and available in React components
- **Routing**: Multiple routes work ("/", "/about")
- **Headers**: Responses include `X-Inertia: true` and `Vary: X-Inertia` for XHR requests

### Manual Test Cases

#### Test 1: Basic HTML Response
```bash
curl -v http://localhost:8000/
```
Should contain:
- `Content-Type: text/html`
- `<div id="app" data-page="{...}">`
- JSON in data-page with component "Home"

#### Test 2: Basic JSON Response  
```bash
curl -v -H "X-Inertia: true" http://localhost:8000/
```
Should contain:
- `Content-Type: application/json`
- `X-Inertia: true` header
- `Vary: X-Inertia` header
- JSON body with component, props, url, version

#### Test 3: Props Serialization
```bash
curl -H "X-Inertia: true" http://localhost:8000/ | jq .props
```
Should show properly serialized props:
```json
{
  "message": "Hello from Gleam!",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

#### Test 4: Different Routes
```bash
curl -H "X-Inertia: true" http://localhost:8000/about | jq .component
```
Should return: `"About"`

## Frontend Integration Testing

### Setup
1. **Build and start the frontend:**
   ```bash
   cd examples/minimal/frontend
   npm install
   npm run build
   ```

2. **Start the Gleam server:**
   ```bash
   cd examples/minimal
   gleam run
   ```

3. **Open http://localhost:8000 in browser**

### Test Scenarios
- Initial page load should show content without errors
- Click navigation links - should navigate without full page reload
- Check browser Network tab for XHR requests with proper headers
- Verify props are correctly passed to React components

## Testing Complex Props

### Testing Object Props

```gleam
// Test nested object properties
let user_decoder = decode.field("name", decode.string)
testing.prop(response, "user", user_decoder)
|> should.equal(Ok("John Doe"))

// Test multiple fields
let user_decoder = decode.decode2(
  User,
  decode.field("name", decode.string),
  decode.field("age", decode.int)
)
testing.prop(response, "user", user_decoder)
|> should.equal(Ok(User("John", 30)))
```

### Testing Array Props

```gleam
// Test array of strings
let tags_decoder = decode.list(decode.string)
testing.prop(response, "tags", tags_decoder)
|> should.equal(Ok(["gleam", "inertia", "web"]))

// Test array length
let count_decoder = decode.list(decode.dynamic) 
  |> decode.map(list.length)
testing.prop(response, "items", count_decoder)
|> should.equal(Ok(5))
```

## Testing Different Request Types

### Testing Full Page vs XHR Requests

```gleam
// Regular browser request (non-XHR)
let req = testing.request(http.Get, "/", [], <<>>)
let response = my_handler(req)
// Should return HTML with data-page attribute

// Inertia XHR request
let req = testing.inertia_request()
let response = my_handler(req)
// Should return JSON response
```

### Testing Partial Reloads

```gleam
// Request only specific props
let req = testing.inertia_request()
  |> testing.partial_data(["posts"])

let response = blog_handler(req)

// Should include requested props
testing.prop(response, "posts", decode.list(decode.dynamic))
|> should.be_ok

// Should not include non-requested props
testing.prop(response, "sidebar", decode.dynamic)
|> should.be_error
```

## Testing Advanced Features

### Testing Always Props

Always props should be present in every response:

```gleam
pub fn test_always_props() {
  let req = testing.inertia_request()
  let response = my_handler(req)
  
  // Always props should be present
  testing.prop(response, "csrf_token", decode.string)
  |> should.be_ok
  
  testing.prop(response, "auth", decode.bool)
  |> should.equal(Ok(True))
}
```

### Testing Form Handling

```gleam
pub fn test_form_submission() {
  let form_data = [#("name", "John"), #("email", "john@example.com")]
  let req = testing.form_request("POST", "/users", form_data)
  let response = create_user_handler(req)
  
  // Should redirect on success
  testing.is_redirect(response) |> should.be_true
  testing.redirect_location(response) |> should.equal(Ok("/users"))
}

pub fn test_form_validation_errors() {
  let form_data = [#("name", ""), #("email", "invalid")]
  let req = testing.form_request("POST", "/users", form_data)
  let response = create_user_handler(req)
  
  // Should return form with errors
  testing.component(response) |> should.equal(Ok("CreateUser"))
  testing.has_errors(response) |> should.be_true
  testing.error(response, "name") |> should.equal(Ok("Name is required"))
}
```

### Testing File Uploads

```gleam
pub fn test_file_upload() {
  let files = [testing.mock_file("test.jpg", "image/jpeg", 1024)]
  let req = testing.upload_request("/upload", files)
  let response = upload_handler(req)
  
  testing.component(response) |> should.equal(Ok("UploadSuccess"))
  testing.prop(response, "uploaded_files", decode.list(decode.dynamic))
  |> should.be_ok
}
```

## Running Tests

### Library Tests
```bash
gleam test
```

### Example Application Tests
```bash
cd examples/minimal
gleam test
```

### Frontend Tests
```bash
cd examples/minimal/frontend
npm test  # if test script is configured
```

## Complete Example

```gleam
import gleam/dynamic/decode
import gleeunit/should
import inertia_gleam/testing

pub type Post {
  Post(id: Int, title: String, content: String)
}

pub fn blog_post_handler_test() {
  // Test full response
  let req = testing.inertia_request()
  let response = blog_post_handler(req, 123)
  
  // Verify component
  testing.component(response) |> should.equal(Ok("BlogPost"))
  
  // Verify post data
  let post_decoder = decode.decode3(
    Post,
    decode.field("id", decode.int),
    decode.field("title", decode.string),
    decode.field("content", decode.string)
  )
  
  testing.prop(response, "post", post_decoder)
  |> should.equal(Ok(Post(123, "My Post", "Post content...")))
  
  // Verify always props are present
  testing.prop(response, "csrf_token", decode.string)
  |> should.be_ok
}

pub fn blog_post_partial_test() {
  // Test partial reload requesting only comments
  let req = testing.inertia_request()
    |> testing.partial_data(["comments"])
  
  let response = blog_post_handler(req, 123)
  
  // Should include comments
  testing.prop(response, "comments", decode.list(decode.dynamic))
  |> should.be_ok
  
  // Should not include post content (not requested)
  testing.prop(response, "post", decode.dynamic)
  |> should.be_error
  
  // But always props should still be present
  testing.prop(response, "csrf_token", decode.string)
  |> should.be_ok
}
```

## Troubleshooting

### Server Issues
- Check port 8000 isn't in use: `lsof -i :8000`
- Verify dependencies: `gleam deps download`

### JSON Issues
- Check prop serialization in logs
- Validate with: `curl ... | jq`

### Frontend Issues
- Check browser console for errors
- Verify frontend assets: `ls examples/minimal/static/js/`
- Check component names match exactly
- Ensure ESBuild is running for development

### Navigation Issues
- Verify `X-Inertia` header in requests
- Check response headers include `X-Inertia: true`
- Ensure component resolver finds components

## Best Practices

1. **Test both full and partial requests** - Ensure handlers work for both scenarios
2. **Use specific decoders** - Avoid `decode.dynamic` unless necessary
3. **Test edge cases** - Missing props, invalid data, error conditions
4. **Test always props separately** - Verify global props in all responses
5. **Keep tests focused** - One concern per test function
6. **Use descriptive test names** - Make test purpose clear