# Testing Guide for Inertia Gleam

This guide shows how to test your Inertia.js handlers using the built-in testing utilities.

## Quick Start

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

#### `testing.url(response)`
Extracts the URL from the response:

```gleam
testing.url(response) |> should.equal(Ok("/dashboard"))
```

#### `testing.version(response)`
Extracts the version from the response:

```gleam
testing.version(response) |> should.equal(Ok("1"))
```

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

### Testing Full Page Requests

```gleam
// Regular browser request (non-XHR)
let req = testing.request(http.Get, "/", [], <<>>)
let response = my_handler(req)

// Should return HTML with data-page attribute
testing.component(response) |> should.equal(Ok("HomePage"))
```

### Testing XHR Requests

```gleam
// Inertia XHR request
let req = testing.inertia_request()
let response = my_handler(req)

// Should return JSON response
testing.component(response) |> should.equal(Ok("HomePage"))
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

## Testing Always Props

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

## Testing Lazy Props

Lazy props should be evaluated when included in response:

```gleam
pub fn test_lazy_props() {
  let req = testing.inertia_request()
  let response = expensive_handler(req)
  
  // Lazy prop should be evaluated and included
  testing.prop(response, "expensive_data", decode.string)
  |> should.equal(Ok("calculated_result"))
}
```

## Complete Example

Here's a complete test for a blog post handler:

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
  
  testing.prop(response, "user", decode.field("id", decode.int))
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

## Best Practices

1. **Test both full and partial requests** - Ensure your handlers work correctly for both scenarios

2. **Use specific decoders** - Don't use `decode.dynamic` unless necessary, use specific types

3. **Test edge cases** - Test missing props, invalid data, and error conditions

4. **Test always props separately** - Verify global props are included in all responses

5. **Keep tests focused** - Test one concern per test function

6. **Use descriptive test names** - Make it clear what each test is verifying