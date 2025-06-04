import gleam/dict
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/json
import gleam/option
import gleeunit
import inertia_wisp/inertia
import inertia_wisp/testing

import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Test prop type for middleware tests
pub type MiddlewareProp {
  TestData(data: String)
}

fn encode_middleware_prop(prop: MiddlewareProp) -> json.Json {
  case prop {
    TestData(data) -> json.string(data)
  }
}

// Test 1: middleware should create context for Inertia request
pub fn middleware_inertia_request_test() {
  let config = inertia.config(
    version: "1",
    ssr: False,
    encrypt_history: False,
  )
  
  let req = testing.inertia_request()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    // Check that context is properly initialized
    assert ctx.config == config
    assert ctx.request == req
    assert dict.is_empty(ctx.props)
    assert dict.is_empty(ctx.errors)
    assert ctx.clear_history == False
    assert ctx.encrypt_history == False
    assert ctx.ssr_supervisor == option.None
    
    // Return a simple response to complete the middleware
    ctx
    |> inertia.with_encoder(encode_middleware_prop)
    |> inertia.prop("test", TestData("middleware test"))
    |> inertia.render("TestComponent")
  })
  
  // Should be a valid response with component and props
  assert testing.component(response) == Ok("TestComponent")
  assert testing.prop(response, "test", decode.string) == Ok("middleware test")
}

// Test 2: middleware should create context for non-Inertia request
pub fn middleware_non_inertia_request_test() {
  let config = inertia.default_config()
  let req = wisp_testing.get("/", [])
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    // Check that context is properly initialized
    assert ctx.config == config
    assert ctx.request == req
    assert dict.is_empty(ctx.props)
    assert dict.is_empty(ctx.errors)
    
    // Return a response
    ctx
    |> inertia.with_encoder(encode_middleware_prop)
    |> inertia.prop("test", TestData("non-inertia test"))
    |> inertia.render("TestComponent")
  })
  
  // Should be a valid response with component and props
  assert testing.component(response) == Ok("TestComponent")
  assert testing.prop(response, "test", decode.string) == Ok("non-inertia test")
}

// Test 3: middleware should handle version checking
pub fn middleware_version_check_test() {
  let config = inertia.config(
    version: "v2.0.0",
    ssr: False,
    encrypt_history: False,
  )
  
  // Request with mismatched version
  let req = wisp_testing.get("/", [
    #("accept", "application/json"),
    #("x-inertia", "true"),
    #("x-inertia-version", "v1.0.0"),  // Different version
  ])
  
  let response = inertia.middleware(req, config, option.None, fn(_ctx) {
    // This handler should not be called due to version mismatch
    panic as "Handler should not be called on version mismatch"
  })
  
  // Should return a 409 status for version mismatch
  assert response.status == 409
}

// Test 4: middleware should handle SSR supervisor
pub fn middleware_with_ssr_supervisor_test() {
  let config = inertia.config(
    version: "1",
    ssr: True,
    encrypt_history: False,
  )
  
  // Create a mock SSR supervisor (we can't easily test actual SSR without a real supervisor)
  let mock_supervisor = process.new_subject()
  let req = testing.inertia_request()
  
  let response = inertia.middleware(req, config, option.Some(mock_supervisor), fn(ctx) {
    // Check that SSR supervisor is set
    assert ctx.ssr_supervisor == option.Some(mock_supervisor)
    assert ctx.config.ssr == True
    
    ctx
    |> inertia.with_encoder(encode_middleware_prop)
    |> inertia.prop("ssr_test", TestData("with ssr"))
    |> inertia.render("SSRComponent")
  })
  
  // For this test, we can't easily create a real SSR supervisor
  // so we'll just verify the context receives the supervisor reference
  // The actual response will be a regular response since we don't have real SSR
  assert testing.component(response) == Ok("SSRComponent")
  assert testing.prop(response, "ssr_test", decode.string) == Ok("with ssr")
}

// Test 5: middleware should handle encrypt_history configuration
pub fn middleware_encrypt_history_test() {
  let config = inertia.config(
    version: "1",
    ssr: False,
    encrypt_history: True,
  )
  
  let req = testing.inertia_request()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    assert ctx.encrypt_history == True
    
    ctx
    |> inertia.with_encoder(encode_middleware_prop)
    |> inertia.prop("encrypt_test", TestData("encrypted"))
    |> inertia.render("EncryptComponent")
  })
  
  assert testing.encrypt_history(response) == Ok(True)
}

// Test 6: middleware should handle partial reload headers
pub fn middleware_partial_reload_test() {
  let config = inertia.default_config()
  
  let req = testing.inertia_request()
    |> testing.partial_data(["requested_prop"])
    |> testing.partial_component("PartialComponent")
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.with_encoder(encode_middleware_prop)
    |> inertia.prop("requested_prop", TestData("requested"))
    |> inertia.prop("other_prop", TestData("not requested"))
    |> inertia.optional_prop("optional_prop", fn() { TestData("optional") })
    |> inertia.render("PartialComponent")
  })
  
  // Should include only requested prop
  assert testing.prop(response, "requested_prop", decode.string) == Ok("requested")
  
  // Should not include non-requested default prop
  case testing.prop(response, "other_prop", decode.string) {
    Error(_) -> Nil
    Ok(_) -> panic as "Should not include non-requested prop"
  }
  
  // Should not include optional prop unless requested
  case testing.prop(response, "optional_prop", decode.string) {
    Error(_) -> Nil
    Ok(_) -> panic as "Should not include unrequested optional prop"
  }
}

// Test 7: default_config should return expected values
pub fn default_config_test() {
  let config = inertia.default_config()
  
  assert config.version == "1"
  assert config.ssr == False
  assert config.encrypt_history == False
}

// Test 8: config function should set all values correctly
pub fn config_creation_test() {
  let config = inertia.config(
    version: "custom-version",
    ssr: True,
    encrypt_history: True,
  )
  
  assert config.version == "custom-version"
  assert config.ssr == True
  assert config.encrypt_history == True
}

// Test 9: middleware should preserve request path in URL
pub fn middleware_url_preservation_test() {
  let config = inertia.default_config()
  let req = wisp_testing.get("/users/123/edit", [
    #("accept", "application/json"),
    #("x-inertia", "true"),
    #("x-inertia-version", "1"),
  ])
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.with_encoder(encode_middleware_prop)
    |> inertia.prop("path_test", TestData("path preserved"))
    |> inertia.render("PathComponent")
  })
  
  assert testing.url(response) == Ok("/users/123/edit")
}

// Test 10: middleware should handle missing headers gracefully
pub fn middleware_missing_headers_test() {
  let config = inertia.default_config()
  let req = wisp_testing.get("/", [])  // No special headers
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    // Should still work for regular requests
    ctx
    |> inertia.with_encoder(encode_middleware_prop)
    |> inertia.prop("no_headers", TestData("works fine"))
    |> inertia.render("NoHeadersComponent")
  })
  
  assert testing.component(response) == Ok("NoHeadersComponent")
  assert testing.prop(response, "no_headers", decode.string) == Ok("works fine")
}