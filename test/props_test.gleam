import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option
import gleeunit
import inertia_wisp/inertia
import inertia_wisp/internal/types
import inertia_wisp/testing

pub fn main() {
  gleeunit.main()
}

// Test data types - using prop variants like the actual API
pub type TestProp {
  Title(title: String)
  Count(count: Int)
  Active(active: Bool)
  Message(message: String)
}

// Encoder function
fn encode_test_prop(prop: TestProp) -> json.Json {
  case prop {
    Title(title) -> json.string(title)
    Count(count) -> json.int(count)
    Active(active) -> json.bool(active)
    Message(message) -> json.string(message)
  }
}

// Helper to create base context
fn create_base_context() -> types.InertiaContext(Nil) {
  let config = inertia.default_config()
  let req = testing.inertia_request()
  
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

// Test 1: with_encoder should create typed context with encoder
pub fn with_encoder_test() {
  let base_ctx = create_base_context()
  let typed_ctx = inertia.with_encoder(base_ctx, encode_test_prop)
  
  // Context should maintain basic properties
  assert typed_ctx.config == base_ctx.config
  assert typed_ctx.request == base_ctx.request
  assert typed_ctx.errors == base_ctx.errors
  assert typed_ctx.clear_history == base_ctx.clear_history
  assert typed_ctx.encrypt_history == base_ctx.encrypt_history
  assert typed_ctx.ssr_supervisor == base_ctx.ssr_supervisor
  
  // Props should be empty but encoder should be set
  assert dict.size(typed_ctx.props) == 0
}

// Test 2: prop() should add default props
pub fn prop_test() {
  let ctx = create_base_context()
    |> inertia.with_encoder(encode_test_prop)
    |> inertia.prop("title", Title("Test Title"))
    |> inertia.prop("count", Count(42))
  
  // Should have 2 props
  assert dict.size(ctx.props) == 2
  
  // Check that props exist with correct include type
  case dict.get(ctx.props, "title") {
    Ok(types.Prop(prop_fn: _, include: types.IncludeDefault)) -> Nil
    _ -> panic as "Title prop should exist with IncludeDefault"
  }
  
  case dict.get(ctx.props, "count") {
    Ok(types.Prop(prop_fn: _, include: types.IncludeDefault)) -> Nil
    _ -> panic as "Count prop should exist with IncludeDefault"
  }
}

// Test 3: always_prop() should add always props
pub fn always_prop_test() {
  let ctx = create_base_context()
    |> inertia.with_encoder(encode_test_prop)
    |> inertia.always_prop("message", Message("Always visible"))
    |> inertia.always_prop("active", Active(True))
  
  // Should have 2 props
  assert dict.size(ctx.props) == 2
  
  // Check that props exist with correct include type
  case dict.get(ctx.props, "message") {
    Ok(types.Prop(prop_fn: _, include: types.IncludeAlways)) -> Nil
    _ -> panic as "Message prop should exist with IncludeAlways"
  }
  
  case dict.get(ctx.props, "active") {
    Ok(types.Prop(prop_fn: _, include: types.IncludeAlways)) -> Nil
    _ -> panic as "Active prop should exist with IncludeAlways"
  }
}

// Test 4: optional_prop() should add optional props
pub fn optional_prop_test() {
  let ctx = create_base_context()
    |> inertia.with_encoder(encode_test_prop)
    |> inertia.optional_prop("debug_info", fn() { Message("Secret Debug Data") })
    |> inertia.optional_prop("expensive_data", fn() { Count(9999) })
  
  // Should have 2 props
  assert dict.size(ctx.props) == 2
  
  // Check that props exist with correct include type
  case dict.get(ctx.props, "debug_info") {
    Ok(types.Prop(prop_fn: _, include: types.IncludeOptionally)) -> Nil
    _ -> panic as "Debug info prop should exist with IncludeOptionally"
  }
  
  case dict.get(ctx.props, "expensive_data") {
    Ok(types.Prop(prop_fn: _, include: types.IncludeOptionally)) -> Nil
    _ -> panic as "Expensive data prop should exist with IncludeOptionally"
  }
}

// Test 5: Mixed prop types should work together
pub fn mixed_props_test() {
  let ctx = create_base_context()
    |> inertia.with_encoder(encode_test_prop)
    |> inertia.prop("title", Title("Mixed Props Test"))
    |> inertia.always_prop("message", Message("Always visible"))
    |> inertia.optional_prop("debug", fn() { Count(123) })
  
  // Should have 3 props
  assert dict.size(ctx.props) == 3
  
  // Verify each prop type
  case dict.get(ctx.props, "title") {
    Ok(types.Prop(prop_fn: _, include: types.IncludeDefault)) -> Nil
    _ -> panic as "Title should be IncludeDefault"
  }
  
  case dict.get(ctx.props, "message") {
    Ok(types.Prop(prop_fn: _, include: types.IncludeAlways)) -> Nil
    _ -> panic as "Message should be IncludeAlways"
  }
  
  case dict.get(ctx.props, "debug") {
    Ok(types.Prop(prop_fn: _, include: types.IncludeOptionally)) -> Nil
    _ -> panic as "Debug should be IncludeOptionally"
  }
}

// Test 6: Prop override should work (last one wins)
pub fn prop_override_test() {
  let ctx = create_base_context()
    |> inertia.with_encoder(encode_test_prop)
    |> inertia.prop("title", Title("First Title"))
    |> inertia.prop("title", Title("Second Title"))
    |> inertia.always_prop("title", Title("Third Title"))
  
  // Should have 1 prop (overridden)
  assert dict.size(ctx.props) == 1
  
  // Should be the last one set (always_prop)
  case dict.get(ctx.props, "title") {
    Ok(types.Prop(prop_fn: _, include: types.IncludeAlways)) -> Nil
    _ -> panic as "Title should be overridden with IncludeAlways"
  }
}

// Test 7: Prop functions should be lazy (not evaluated until render)
pub fn prop_lazy_evaluation_test() {
  let ctx = create_base_context()
    |> inertia.with_encoder(encode_test_prop)
    |> inertia.optional_prop("expensive", fn() { 
      // This would panic if evaluated immediately
      panic as "Should not be evaluated until render"
    })
  
  // Should succeed - prop function not evaluated yet
  assert dict.size(ctx.props) == 1
}

// Test 8: Render with default props should include only defaults and always props
pub fn render_default_props_test() {
  let ctx = create_base_context()
    |> inertia.with_encoder(encode_test_prop)
    |> inertia.prop("title", Title("Test Page"))
    |> inertia.prop("count", Count(100))
    |> inertia.always_prop("message", Message("Always visible"))
    |> inertia.optional_prop("debug", fn() { Count(999) })
  
  let response = inertia.render(ctx, "TestPage")
  
  // Should include default and always props, but not optional
  assert testing.prop(response, "title", decode.string) == Ok("Test Page")
  assert testing.prop(response, "count", decode.int) == Ok(100)
  assert testing.prop(response, "message", decode.string) == Ok("Always visible")
  
  // Should NOT include optional prop
  case testing.prop(response, "debug", decode.int) {
    Error(_) -> Nil
    Ok(_) -> panic as "Optional prop should not be included in default render"
  }
}

// Test 9: Render with partial reload should include requested props
pub fn render_partial_reload_test() {
  let req = testing.inertia_request()
    |> testing.partial_data(["title", "debug"])
    |> testing.partial_component("TestPage")
  
  let ctx = types.InertiaContext(
    config: inertia.default_config(),
    request: req,
    props: dict.new(),
    prop_encoder: encode_test_prop,
    errors: dict.new(),
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: option.None,
  )
    |> inertia.prop("title", Title("Partial Test"))
    |> inertia.prop("count", Count(200))
    |> inertia.always_prop("message", Message("Always visible"))
    |> inertia.optional_prop("debug", fn() { Count(888) })
  
  let response = inertia.render(ctx, "TestPage")
  
  // Should include requested default prop
  assert testing.prop(response, "title", decode.string) == Ok("Partial Test")
  
  // Should include requested optional prop
  assert testing.prop(response, "debug", decode.int) == Ok(888)
  
  // Should NOT include non-requested default prop
  case testing.prop(response, "count", decode.int) {
    Error(_) -> Nil
    Ok(_) -> panic as "Non-requested prop should not be included in partial reload"
  }
  
  // Should ALWAYS include always prop (even in partial reload)
  assert testing.prop(response, "message", decode.string) == Ok("Always visible")
}

// Test 10: errors() function should set validation errors
pub fn errors_test() {
  let validation_errors = dict.from_list([
    #("email", "Email is required"),
    #("password", "Password must be at least 8 characters"),
  ])
  
  let ctx = create_base_context()
    |> inertia.with_encoder(encode_test_prop)
    |> inertia.errors(validation_errors)
  
  // Errors should be set
  assert dict.get(ctx.errors, "email") == Ok("Email is required")
  assert dict.get(ctx.errors, "password") == Ok("Password must be at least 8 characters")
  assert dict.size(ctx.errors) == 2
}