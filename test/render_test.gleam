import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option
import gleeunit
import inertia_wisp/inertia
import inertia_wisp/internal/types
import inertia_wisp/testing
import wisp
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Test prop types for render tests
pub type RenderProp {
  Title(title: String)
  Count(count: Int)
  Message(message: String)
  Active(active: Bool)
  Items(items: List(String))
}

fn encode_render_prop(prop: RenderProp) -> json.Json {
  case prop {
    Title(title) -> json.string(title)
    Count(count) -> json.int(count)
    Message(message) -> json.string(message)
    Active(active) -> json.bool(active)
    Items(items) -> json.array(items, json.string)
  }
}

// Manual context creation (like partial_reload_test.gleam)
fn create_manual_context(req: wisp.Request) -> types.InertiaContext(RenderProp) {
  let config = inertia.default_config()
  
  types.InertiaContext(
    config: config,
    request: req,
    props: dict.new(),
    prop_encoder: encode_render_prop,
    errors: dict.new(),
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: option.None,
  )
}

// Test 1: render should create JSON response for Inertia requests
pub fn render_inertia_json_response_test() {
  let req = testing.inertia_request()
  let ctx = create_manual_context(req)
    |> inertia.prop("title", Title("JSON Test"))
    |> inertia.prop("count", Count(42))
  
  let response = inertia.render(ctx, "JSONComponent")
  
  // Should be JSON response
  assert response.status == 200
  assert testing.component(response) == Ok("JSONComponent")
  assert testing.prop(response, "title", decode.string) == Ok("JSON Test")
  assert testing.prop(response, "count", decode.int) == Ok(42)
  assert testing.version(response) == Ok("1")
}

// Test 2: render should create HTML response for non-Inertia requests
pub fn render_non_inertia_html_response_test() {
  let req = wisp_testing.get("/", [])
  let ctx = create_manual_context(req)
    |> inertia.prop("title", Title("HTML Test"))
    |> inertia.prop("message", Message("Server-side rendered"))
  
  let response = inertia.render(ctx, "HTMLComponent")
  
  // Should be HTML response
  assert response.status == 200
  assert testing.component(response) == Ok("HTMLComponent")
  assert testing.prop(response, "title", decode.string) == Ok("HTML Test")
  assert testing.prop(response, "message", decode.string) == Ok("Server-side rendered")
}

// Test 3: render should include errors in response
pub fn render_with_errors_test() {
  let req = testing.inertia_request()
  let validation_errors = dict.from_list([
    #("name", "Name is required"),
    #("email", "Invalid email format"),
  ])
  
  let ctx = create_manual_context(req)
    |> inertia.prop("title", Title("Form with Errors"))
    |> inertia.errors(validation_errors)
  
  let response = inertia.render(ctx, "FormComponent")
  
  assert testing.component(response) == Ok("FormComponent")
  assert testing.prop(response, "title", decode.string) == Ok("Form with Errors")
  
  // Check that errors are included
  assert testing.prop(response, "errors", decode.at(["name"], decode.string)) == Ok("Name is required")
  assert testing.prop(response, "errors", decode.at(["email"], decode.string)) == Ok("Invalid email format")
}

// Test 4: render should handle empty props
pub fn render_empty_props_test() {
  let req = testing.inertia_request()
  let ctx = create_manual_context(req)
  
  let response = inertia.render(ctx, "EmptyComponent")
  
  assert testing.component(response) == Ok("EmptyComponent")
  assert testing.version(response) == Ok("1")
  
  // Should have no custom props (only standard Inertia fields)
  case testing.prop(response, "title", decode.string) {
    Error(_) -> Nil  // Expected - no title prop set
    Ok(_) -> panic as "Should not have title prop when none set"
  }
}

// Test 5: render should handle complex prop types
pub fn render_complex_props_test() {
  let req = testing.inertia_request()
  let ctx = create_manual_context(req)
    |> inertia.prop("title", Title("Complex Test"))
    |> inertia.prop("active", Active(True))
    |> inertia.prop("items", Items(["apple", "banana", "cherry"]))
    |> inertia.prop("count", Count(999))
  
  let response = inertia.render(ctx, "ComplexComponent")
  
  assert testing.component(response) == Ok("ComplexComponent")
  assert testing.prop(response, "title", decode.string) == Ok("Complex Test")
  assert testing.prop(response, "active", decode.bool) == Ok(True)
  assert testing.prop(response, "count", decode.int) == Ok(999)
  assert testing.prop(response, "items", decode.list(decode.string)) == Ok(["apple", "banana", "cherry"])
}

// Test 6: render should handle clear_history flag
pub fn render_clear_history_test() {
  let req = testing.inertia_request()
  let ctx = create_manual_context(req)
    |> inertia.prop("title", Title("Clear History Test"))
  
  // Manually set clear_history flag
  let ctx_with_clear = types.InertiaContext(
    ..ctx,
    clear_history: True,
  )
  
  let response = inertia.render(ctx_with_clear, "ClearHistoryComponent")
  
  assert testing.component(response) == Ok("ClearHistoryComponent")
  assert testing.clear_history(response) == Ok(True)
}

// Test 7: render should handle encrypt_history flag
pub fn render_encrypt_history_test() {
  let req = testing.inertia_request()
  let config = inertia.config(
    version: "1",
    ssr: False,
    encrypt_history: True,
  )
  
  let ctx = types.InertiaContext(
    config: config,
    request: req,
    props: dict.new(),
    prop_encoder: encode_render_prop,
    errors: dict.new(),
    clear_history: False,
    encrypt_history: True,
    ssr_supervisor: option.None,
  )
    |> inertia.prop("title", Title("Encrypt History Test"))
  
  let response = inertia.render(ctx, "EncryptComponent")
  
  assert testing.component(response) == Ok("EncryptComponent")
  assert testing.encrypt_history(response) == Ok(True)
}

// Test 8: render should preserve URL correctly
pub fn render_url_preservation_test() {
  let req = wisp_testing.get("/users/123/profile", [
    #("accept", "application/json"),
    #("x-inertia", "true"),
    #("x-inertia-version", "1"),
  ])
  
  let ctx = create_manual_context(req)
    |> inertia.prop("title", Title("User Profile"))
  
  let response = inertia.render(ctx, "UserProfile")
  
  assert testing.component(response) == Ok("UserProfile")
  assert testing.url(response) == Ok("/users/123/profile")
}

// Test 9: render should handle partial reload correctly
pub fn render_partial_reload_test() {
  let req = testing.inertia_request()
    |> testing.partial_data(["title", "active"])
    |> testing.partial_component("PartialComponent")
  
  let ctx = create_manual_context(req)
    |> inertia.prop("title", Title("Partial Title"))
    |> inertia.prop("count", Count(100))
    |> inertia.always_prop("active", Active(True))
    |> inertia.optional_prop("debug", fn() { Message("Debug Info") })
  
  let response = inertia.render(ctx, "PartialComponent")
  
  // Should include requested default prop
  assert testing.prop(response, "title", decode.string) == Ok("Partial Title")
  
  // Should include always prop
  assert testing.prop(response, "active", decode.bool) == Ok(True)
  
  // Should NOT include non-requested default prop
  case testing.prop(response, "count", decode.int) {
    Error(_) -> Nil
    Ok(_) -> panic as "Should not include non-requested prop in partial reload"
  }
  
  // Should NOT include non-requested optional prop
  case testing.prop(response, "debug", decode.string) {
    Error(_) -> Nil
    Ok(_) -> panic as "Should not include non-requested optional prop"
  }
}

// Test 10: render should handle partial reload with optional prop requested
pub fn render_partial_reload_with_optional_test() {
  let req = testing.inertia_request()
    |> testing.partial_data(["debug", "active"])
    |> testing.partial_component("OptionalComponent")
  
  let ctx = create_manual_context(req)
    |> inertia.prop("title", Title("Not Requested"))
    |> inertia.always_prop("active", Active(False))
    |> inertia.optional_prop("debug", fn() { Message("Optional Debug") })
  
  let response = inertia.render(ctx, "OptionalComponent")
  
  // Should include always prop
  assert testing.prop(response, "active", decode.bool) == Ok(False)
  
  // Should include requested optional prop
  assert testing.prop(response, "debug", decode.string) == Ok("Optional Debug")
  
  // Should NOT include non-requested default prop
  case testing.prop(response, "title", decode.string) {
    Error(_) -> Nil
    Ok(_) -> panic as "Should not include non-requested default prop"
  }
}