import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option
import gleeunit
import inertia_wisp/inertia
import inertia_wisp/internal/types
import wisp
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Test data types
pub type User {
  User(name: String, email: String, age: Int)
}

pub type CreateUserRequest {
  CreateUserRequest(name: String, email: String, age: Int, active: Bool)
}

// Decoders using the correct syntax
fn user_decoder() -> decode.Decoder(User) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use age <- decode.field("age", decode.int)
  decode.success(User(name: name, email: email, age: age))
}

fn create_user_decoder() -> decode.Decoder(CreateUserRequest) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use age <- decode.field("age", decode.int)
  use active <- decode.field("active", decode.bool)
  decode.success(CreateUserRequest(name: name, email: email, age: age, active: active))
}

// Helper to create context with JSON body
fn create_context_with_json(json_data: json.Json) -> types.InertiaContext(Nil) {
  let config = inertia.default_config()
  let req = wisp_testing.post_json("/test", [], json_data)
  
  types.InertiaContext(
    config: config,
    request: req,
    props: dict.new(),
    prop_encoder: fn(_) { json.null() },
    errors: dict.new(),
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: option.None,
  )
}

// Test 1: require_json should successfully decode valid JSON
pub fn require_json_valid_test() {
  let json_data = json.object([
    #("name", json.string("John Doe")),
    #("email", json.string("john@example.com")),
    #("age", json.int(30)),
  ])
  
  let ctx = create_context_with_json(json_data)
  
  let response = inertia.require_json(ctx, user_decoder(), fn(user: User) {
    assert user.name == "John Doe"
    assert user.email == "john@example.com"
    assert user.age == 30
    
    wisp.ok()
  })
  
  assert response.status == 200
}

// Test 2: require_json should handle malformed JSON
pub fn require_json_malformed_test() {
  // Create a request with malformed JSON body
  let config = inertia.default_config()
  let req = wisp_testing.post("/test", [], "{ invalid json")
  
  let ctx = types.InertiaContext(
    config: config,
    request: req,
    props: dict.new(),
    prop_encoder: fn(_) { json.null() },
    errors: dict.new(),
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: option.None,
  )
  
  let response = inertia.require_json(ctx, user_decoder(), fn(_user: User) {
    panic as "Should not reach continuation with malformed JSON"
  })
  
  assert response.status == 415
}

// Test 3: require_json should handle JSON with wrong structure
pub fn require_json_wrong_structure_test() {
  let json_data = json.object([
    #("wrong_field", json.string("value")),
    #("another_field", json.int(123)),
  ])
  
  let ctx = create_context_with_json(json_data)
  
  let response = inertia.require_json(ctx, user_decoder(), fn(_user: User) {
    panic as "Should not reach continuation with wrong JSON structure"
  })
  
  assert response.status == 400
}

// Test 4: require_json should handle missing required fields
pub fn require_json_missing_fields_test() {
  let json_data = json.object([
    #("name", json.string("John")),
    // Missing email and age fields
  ])
  
  let ctx = create_context_with_json(json_data)
  
  let response = inertia.require_json(ctx, user_decoder(), fn(_user: User) {
    panic as "Should not reach continuation with missing fields"
  })
  
  assert response.status == 400
}

// Test 5: require_json should handle type mismatches
pub fn require_json_type_mismatch_test() {
  let json_data = json.object([
    #("name", json.string("John")),
    #("email", json.string("john@example.com")),
    #("age", json.string("thirty")), // Should be int, not string
  ])
  
  let ctx = create_context_with_json(json_data)
  
  let response = inertia.require_json(ctx, user_decoder(), fn(_user: User) {
    panic as "Should not reach continuation with type mismatch"
  })
  
  assert response.status == 400
}

// Test 6: require_json should handle complex nested JSON
pub fn require_json_complex_test() {
  let json_data = json.object([
    #("name", json.string("Jane Smith")),
    #("email", json.string("jane@example.com")),
    #("age", json.int(25)),
    #("active", json.bool(True)),
  ])
  
  let ctx = create_context_with_json(json_data)
  
  let response = inertia.require_json(ctx, create_user_decoder(), fn(req: CreateUserRequest) {
    assert req.name == "Jane Smith"
    assert req.email == "jane@example.com"
    assert req.age == 25
    assert req.active == True
    
    wisp.ok()
  })
  
  assert response.status == 200
}

// Test 7: require_json should handle empty JSON object
pub fn require_json_empty_object_test() {
  let json_data = json.object([])
  let ctx = create_context_with_json(json_data)
  
  let response = inertia.require_json(ctx, user_decoder(), fn(_user: User) {
    panic as "Should not reach continuation with empty object"
  })
  
  assert response.status == 400
}

// Test 8: require_json should handle null values
pub fn require_json_null_values_test() {
  let json_data = json.object([
    #("name", json.null()),
    #("email", json.string("test@example.com")),
    #("age", json.int(30)),
  ])
  
  let ctx = create_context_with_json(json_data)
  
  let response = inertia.require_json(ctx, user_decoder(), fn(_user: User) {
    panic as "Should not reach continuation with null name"
  })
  
  assert response.status == 400
}

// Test 9: require_json should handle different decoders correctly
pub fn require_json_different_decoders_test() {
  // Test with simple string decoder
  let json_data = json.string("Hello World")
  let ctx = create_context_with_json(json_data)
  
  let response = inertia.require_json(ctx, decode.string, fn(text: String) {
    assert text == "Hello World"
    wisp.ok()
  })
  
  assert response.status == 200
}

// Test 10: require_json continuation can return different response types
pub fn require_json_continuation_responses_test() {
  let json_data = json.object([
    #("name", json.string("Test User")),
    #("email", json.string("test@example.com")),
    #("age", json.int(25)),
  ])
  
  let ctx = create_context_with_json(json_data)
  
  // Test returning different status codes from continuation
  let response = inertia.require_json(ctx, user_decoder(), fn(user: User) {
    case user.age {
      age if age < 18 -> wisp.response(403) // Forbidden
      _ -> wisp.response(201) // Created
    }
  })
  
  assert response.status == 201
}

// Test 11: require_json should work with context that has existing props
pub fn require_json_with_existing_context_test() {
  let json_data = json.object([
    #("name", json.string("Context User")),
    #("email", json.string("context@example.com")),
    #("age", json.int(35)),
  ])
  
  let config = inertia.default_config()
  let req = wisp_testing.post_json("/test", [], json_data)
  
  // Create context with some existing state
  let ctx = types.InertiaContext(
    config: config,
    request: req,
    props: dict.from_list([#("existing", types.Prop(fn() { "value" }, types.IncludeDefault))]),
    prop_encoder: fn(_) { json.string("test") },
    errors: dict.from_list([#("field", "error")]),
    clear_history: True,
    encrypt_history: True,
    ssr_supervisor: option.None,
  )
  
  let response = inertia.require_json(ctx, user_decoder(), fn(user: User) {
    // Context should still be accessible
    assert user.name == "Context User"
    assert dict.size(ctx.props) == 1
    assert dict.size(ctx.errors) == 1
    assert ctx.clear_history == True
    
    wisp.ok()
  })
  
  assert response.status == 200
}

// Test 12: require_json should handle integer decoders
pub fn require_json_integer_test() {
  let json_data = json.int(42)
  let ctx = create_context_with_json(json_data)
  
  let response = inertia.require_json(ctx, decode.int, fn(number: Int) {
    assert number == 42
    wisp.ok()
  })
  
  assert response.status == 200
}