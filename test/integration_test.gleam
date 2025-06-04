import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option
import gleeunit
import inertia_wisp/inertia

import inertia_wisp/testing
import wisp
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Integration test prop types
pub type IntegrationProp {
  PageTitle(title: String)
  UserData(name: String, email: String)
  PostData(id: Int, title: String, content: String)
  NavigationData(items: List(String))
  FormData(fields: List(String))
}

fn encode_integration_prop(prop: IntegrationProp) -> json.Json {
  case prop {
    PageTitle(title) -> json.string(title)
    UserData(name, email) -> json.object([
      #("name", json.string(name)),
      #("email", json.string(email)),
    ])
    PostData(id, title, content) -> json.object([
      #("id", json.int(id)),
      #("title", json.string(title)),
      #("content", json.string(content)),
    ])
    NavigationData(items) -> json.array(items, json.string)
    FormData(fields) -> json.array(fields, json.string)
  }
}

// User creation request decoder for JSON tests
pub type CreateUserRequest {
  CreateUserRequest(name: String, email: String, age: Int)
}

fn create_user_decoder() -> decode.Decoder(CreateUserRequest) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use age <- decode.field("age", decode.int)
  decode.success(CreateUserRequest(name: name, email: email, age: age))
}

// Test 1: Complete middleware -> render workflow (Inertia request)
pub fn complete_inertia_workflow_test() {
  let config = inertia.config(
    version: "1",
    ssr: False,
    encrypt_history: True,
  )
  
  let req = testing.inertia_request()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.with_encoder(encode_integration_prop)
    |> inertia.prop("title", PageTitle("Integration Test"))
    |> inertia.prop("user", UserData("John Doe", "john@example.com"))
    |> inertia.always_prop("navigation", NavigationData(["Home", "About", "Contact"]))
    |> inertia.render("IntegrationPage")
  })
  
  assert response.status == 200
  assert testing.component(response) == Ok("IntegrationPage")
  assert testing.prop(response, "title", decode.string) == Ok("Integration Test")
  assert testing.prop(response, "user", decode.at(["name"], decode.string)) == Ok("John Doe")
  assert testing.prop(response, "user", decode.at(["email"], decode.string)) == Ok("john@example.com")
  assert testing.prop(response, "navigation", decode.list(decode.string)) == Ok(["Home", "About", "Contact"])
  assert testing.version(response) == Ok("1")
  assert testing.encrypt_history(response) == Ok(True)
}

// Test 2: Complete middleware -> render workflow (HTML request)
pub fn complete_html_workflow_test() {
  let config = inertia.default_config()
  let req = wisp_testing.get("/blog/post/123", [])
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.with_encoder(encode_integration_prop)
    |> inertia.prop("title", PageTitle("Blog Post"))
    |> inertia.prop("post", PostData(123, "My Blog Post", "This is the content"))
    |> inertia.always_prop("navigation", NavigationData(["Blog", "Archive", "About"]))
    |> inertia.render("BlogPost")
  })
  
  assert response.status == 200
  assert testing.component(response) == Ok("BlogPost")
  assert testing.prop(response, "title", decode.string) == Ok("Blog Post")
  assert testing.prop(response, "post", decode.at(["id"], decode.int)) == Ok(123)
  assert testing.prop(response, "post", decode.at(["title"], decode.string)) == Ok("My Blog Post")
  assert testing.url(response) == Ok("/blog/post/123")
}

// Test 3: Partial reload integration test
pub fn partial_reload_integration_test() {
  let config = inertia.default_config()
  let req = testing.inertia_request()
    |> testing.partial_data(["post", "navigation"])
    |> testing.partial_component("BlogPost")
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.with_encoder(encode_integration_prop)
    |> inertia.prop("title", PageTitle("Not Requested"))
    |> inertia.prop("post", PostData(456, "Updated Post", "Updated content"))
    |> inertia.always_prop("navigation", NavigationData(["Updated", "Navigation"]))
    |> inertia.optional_prop("debug", fn() { FormData(["debug", "info"]) })
    |> inertia.render("BlogPost")
  })
  
  assert response.status == 200
  assert testing.component(response) == Ok("BlogPost")
  
  // Should include requested props
  assert testing.prop(response, "post", decode.at(["title"], decode.string)) == Ok("Updated Post")
  assert testing.prop(response, "navigation", decode.list(decode.string)) == Ok(["Updated", "Navigation"])
  
  // Should NOT include non-requested props
  case testing.prop(response, "title", decode.string) {
    Error(_) -> Nil  // Expected
    Ok(_) -> panic as "Should not include non-requested prop"
  }
  
  case testing.prop(response, "debug", decode.list(decode.string)) {
    Error(_) -> Nil  // Expected
    Ok(_) -> panic as "Should not include non-requested optional prop"
  }
}

// Test 4: Form submission with JSON and validation errors
pub fn form_submission_integration_test() {
  let config = inertia.default_config()
  let json_data = json.object([
    #("name", json.string("")),  // Invalid - empty
    #("email", json.string("invalid-email")),  // Invalid format
    #("age", json.int(15)),  // Valid
  ])
  
  let req = wisp_testing.post_json("/users", [], json_data)
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    inertia.require_json(ctx, create_user_decoder(), fn(_user_request) {
      // Simulate validation
      let validation_errors = dict.from_list([
        #("name", "Name cannot be empty"),
        #("email", "Email format is invalid"),
      ])
      
      ctx
      |> inertia.with_encoder(encode_integration_prop)
      |> inertia.prop("title", PageTitle("Create User"))
      |> inertia.prop("form", FormData(["name", "email", "age"]))
      |> inertia.errors(validation_errors)
      |> inertia.render("UserForm")
    })
  })
  
  assert response.status == 200
  assert testing.component(response) == Ok("UserForm")
  assert testing.prop(response, "title", decode.string) == Ok("Create User")
  assert testing.prop(response, "form", decode.list(decode.string)) == Ok(["name", "email", "age"])
  assert testing.prop(response, "errors", decode.at(["name"], decode.string)) == Ok("Name cannot be empty")
  assert testing.prop(response, "errors", decode.at(["email"], decode.string)) == Ok("Email format is invalid")
}

// Test 5: Redirect integration test
pub fn redirect_integration_test() {
  let config = inertia.default_config()
  let req = testing.inertia_request()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    // Simulate successful form submission -> redirect
    inertia.redirect(ctx.request, "/dashboard")
  })
  
  assert response.status == 303
  
  let location = case get_header(response, "location") {
    Ok(loc) -> loc
    Error(_) -> panic as "Should have location header"
  }
  assert location == "/dashboard"
}

// Test 6: External redirect integration test
pub fn external_redirect_integration_test() {
  let config = inertia.default_config()
  let req = testing.inertia_request()
  
  let response = inertia.middleware(req, config, option.None, fn(_ctx) {
    // Simulate OAuth redirect
    inertia.external_redirect("https://oauth.provider.com/authorize?client_id=123")
  })
  
  assert response.status == 409
  
  let location = case get_header(response, "x-inertia-location") {
    Ok(loc) -> loc
    Error(_) -> panic as "Should have x-inertia-location header"
  }
  assert location == "https://oauth.provider.com/authorize?client_id=123"
}

// Test 7: Version mismatch integration test
pub fn version_mismatch_integration_test() {
  let config = inertia.config(
    version: "2.0.0",
    ssr: False,
    encrypt_history: False,
  )
  
  let req = wisp_testing.get("/", [
    #("accept", "application/json"),
    #("x-inertia", "true"),
    #("x-inertia-version", "1.0.0"),  // Mismatched version
  ])
  
  let response = inertia.middleware(req, config, option.None, fn(_ctx) {
    panic as "Should not reach handler on version mismatch"
  })
  
  assert response.status == 409
}

// Test 8: Complex multi-step workflow
pub fn complex_workflow_integration_test() {
  let config = inertia.config(
    version: "1",
    ssr: True,
    encrypt_history: True,
  )
  
  let req = testing.inertia_request()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.with_encoder(encode_integration_prop)
    // Step 1: Set page metadata
    |> inertia.prop("title", PageTitle("Dashboard"))
    // Step 2: Add user data
    |> inertia.prop("user", UserData("Admin User", "admin@company.com"))
    // Step 3: Add navigation (always visible)
    |> inertia.always_prop("navigation", NavigationData([
      "Dashboard", "Users", "Reports", "Settings"
    ]))
    // Step 4: Add optional debug info
    |> inertia.optional_prop("debug", fn() { 
      FormData(["debug", "performance", "logs"]) 
    })
    // Step 5: Simulate some validation errors from previous form
    |> inertia.errors(dict.from_list([
      #("last_action", "Previous action failed - please try again"),
    ]))
    // Step 6: Render the dashboard
    |> inertia.render("Dashboard")
  })
  
  assert response.status == 200
  assert testing.component(response) == Ok("Dashboard")
  assert testing.prop(response, "title", decode.string) == Ok("Dashboard")
  assert testing.prop(response, "user", decode.at(["name"], decode.string)) == Ok("Admin User")
  assert testing.prop(response, "navigation", decode.list(decode.string)) == Ok([
    "Dashboard", "Users", "Reports", "Settings"
  ])
  assert testing.prop(response, "errors", decode.at(["last_action"], decode.string)) == Ok("Previous action failed - please try again")
  assert testing.version(response) == Ok("1")
  assert testing.encrypt_history(response) == Ok(True)
  
  // Optional prop should not be included in regular render
  case testing.prop(response, "debug", decode.list(decode.string)) {
    Error(_) -> Nil  // Expected
    Ok(_) -> panic as "Optional prop should not be included"
  }
}

// Test 9: Mixed request types in sequence
pub fn mixed_request_types_test() {
  let config = inertia.default_config()
  
  // First: HTML request
  let html_req = wisp_testing.get("/app", [])
  let html_response = inertia.middleware(html_req, config, option.None, fn(ctx) {
    ctx
    |> inertia.with_encoder(encode_integration_prop)
    |> inertia.prop("title", PageTitle("App Home"))
    |> inertia.render("AppHome")
  })
  
  // Second: Inertia request
  let inertia_req = testing.inertia_request()
  let inertia_response = inertia.middleware(inertia_req, config, option.None, fn(ctx) {
    ctx
    |> inertia.with_encoder(encode_integration_prop)
    |> inertia.prop("title", PageTitle("App Home"))
    |> inertia.render("AppHome")
  })
  
  // Both should have same component and props, different response format
  assert html_response.status == 200
  assert inertia_response.status == 200
  assert testing.component(html_response) == Ok("AppHome")
  assert testing.component(inertia_response) == Ok("AppHome")
  assert testing.prop(html_response, "title", decode.string) == Ok("App Home")
  assert testing.prop(inertia_response, "title", decode.string) == Ok("App Home")
}

// Test 10: Edge case combinations
pub fn edge_case_combinations_test() {
  let config = inertia.config(
    version: "",  // Empty version
    ssr: False,
    encrypt_history: False,
  )
  
  let req = wisp_testing.get("/edge-case", [
    #("accept", "application/json"),
    #("x-inertia", "true"),
    #("x-inertia-version", ""),  // Empty version (should match)
  ])
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.with_encoder(encode_integration_prop)
    |> inertia.prop("title", PageTitle(""))  // Empty title
    |> inertia.errors(dict.new())  // Empty errors
    |> inertia.render("")  // Empty component name
  })
  
  assert response.status == 200
  assert testing.component(response) == Ok("")
  assert testing.prop(response, "title", decode.string) == Ok("")
  assert testing.version(response) == Ok("")
  
  // Should not have errors field when empty
  case testing.prop(response, "errors", decode.dynamic) {
    Error(_) -> Nil  // Expected
    Ok(_) -> panic as "Should not have errors field when empty"
  }
}

// Helper function to get header from response (copied from redirect_test)
fn get_header(response: wisp.Response, name: String) -> Result(String, Nil) {
  list.find_map(response.headers, fn(header) {
    case header {
      #(header_name, value) if header_name == name -> Ok(value)
      _ -> Error(Nil)
    }
  })
}