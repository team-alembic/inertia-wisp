import gleam/dict
import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/list
import gleam/option
import gleeunit
import gleeunit/should
import inertia_wisp/inertia
import inertia_wisp/testing
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Test initial page loads (non-Inertia requests)

pub fn initial_page_load_basic_test() {
  // Create a regular HTTP request (no Inertia headers)
  let req = wisp_testing.request(
    http.Get,
    "/",
    [],
    <<"">>
  )
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("title", json.string("Home Page"))
    |> inertia.assign_prop("message", json.string("Welcome!"))
    |> inertia.render("HomePage")
  })
  
  // Should return HTML response for initial loads
  response.status |> should.equal(200)
  
  // Extract and test data from HTML response
  testing.component(response) |> should.equal(Ok("HomePage"))
  testing.prop(response, "title", decode.string) |> should.equal(Ok("Home Page"))
  testing.prop(response, "message", decode.string) |> should.equal(Ok("Welcome!"))
}

pub fn initial_page_load_with_always_props_test() {
  let req = wisp_testing.request(http.Get, "/dashboard", [], <<"">>)
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_always_prop("csrf_token", json.string("abc123"))
    |> inertia.assign_always_prop("user", json.object([
      #("id", json.int(42)),
      #("name", json.string("Alice"))
    ]))
    |> inertia.assign_prop("dashboard_data", json.string("dashboard content"))
    |> inertia.render("Dashboard")
  })
  
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("Dashboard"))
  testing.prop(response, "csrf_token", decode.string) |> should.equal(Ok("abc123"))
  testing.prop(response, "user", decode.at(["name"], decode.string)) |> should.equal(Ok("Alice"))
  testing.prop(response, "dashboard_data", decode.string) |> should.equal(Ok("dashboard content"))
}

pub fn initial_page_load_with_lazy_props_test() {
  let req = wisp_testing.request(http.Get, "/reports", [], <<"">>)
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("title", json.string("Reports"))
    |> inertia.assign_lazy_prop("expensive_report", fn() {
      json.object([
        #("total", json.int(1000)),
        #("items", json.array([json.string("item1"), json.string("item2")], fn(x) { x }))
      ])
    })
    |> inertia.assign_always_lazy_prop("notifications", fn() {
      json.int(3)
    })
    |> inertia.render("ReportsPage")
  })
  
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("ReportsPage"))
  testing.prop(response, "title", decode.string) |> should.equal(Ok("Reports"))
  // Lazy props should be evaluated and included in initial loads
  testing.prop(response, "expensive_report", decode.at(["total"], decode.int)) |> should.equal(Ok(1000))
  testing.prop(response, "notifications", decode.int) |> should.equal(Ok(3))
}

pub fn initial_page_load_with_optional_props_test() {
  let req = wisp_testing.request(http.Get, "/profile", [], <<"">>)
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("name", json.string("John"))
    |> inertia.assign_optional_prop("debug_info", json.string("debug data"))
    |> inertia.assign_optional_lazy_prop("admin_panel", fn() {
      json.bool(True)
    })
    |> inertia.render("ProfilePage")
  })
  
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("ProfilePage"))
  testing.prop(response, "name", decode.string) |> should.equal(Ok("John"))
  // Optional props should not be included in initial loads
  testing.prop(response, "debug_info", decode.string) |> should.be_error()
  testing.prop(response, "admin_panel", decode.bool) |> should.be_error()
}

pub fn initial_page_load_with_errors_test() {
  let req = wisp_testing.request(http.Post, "/contact", [], <<"">>)
  let config = inertia.default_config()
  
  let errors = dict.new()
    |> dict.insert("email", "Invalid email format")
    |> dict.insert("message", "Message is required")
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_errors(errors)
    |> inertia.assign_prop("title", json.string("Contact Form"))
    |> inertia.render("ContactForm")
  })
  
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("ContactForm"))
  testing.prop(response, "title", decode.string) |> should.equal(Ok("Contact Form"))
  testing.prop(response, "errors", decode.at(["email"], decode.string)) 
    |> should.equal(Ok("Invalid email format"))
  testing.prop(response, "errors", decode.at(["message"], decode.string)) 
    |> should.equal(Ok("Message is required"))
}

pub fn initial_page_load_with_encrypted_history_test() {
  let req = wisp_testing.request(http.Get, "/payment", [], <<"">>)
  let config = inertia.config(version: "1", ssr: False, encrypt_history: True)
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("amount", json.int(100))
    |> inertia.encrypt_history()
    |> inertia.render("PaymentForm")
  })
  
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("PaymentForm"))
  testing.prop(response, "amount", decode.int) |> should.equal(Ok(100))
  testing.encrypt_history(response) |> should.equal(Ok(True))
}

pub fn initial_page_load_with_complex_data_test() {
  let req = wisp_testing.request(http.Get, "/users", [], <<"">>)
  let config = inertia.default_config()
  
  let users_data = json.array([
    json.object([
      #("id", json.int(1)),
      #("name", json.string("Alice")),
      #("roles", json.array([json.string("admin"), json.string("user")], fn(x) { x }))
    ]),
    json.object([
      #("id", json.int(2)),
      #("name", json.string("Bob")),
      #("roles", json.array([json.string("user")], fn(x) { x }))
    ])
  ], fn(x) { x })
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("users", users_data)
    |> inertia.assign_prop("pagination", json.object([
      #("current_page", json.int(1)),
      #("total_pages", json.int(5)),
      #("per_page", json.int(10))
    ]))
    |> inertia.render("UsersList")
  })
  
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("UsersList"))
  
  // Test complex nested data extraction
  testing.prop(response, "users", decode.list(decode.at(["name"], decode.string))) 
    |> should.equal(Ok(["Alice", "Bob"]))
  testing.prop(response, "pagination", decode.at(["current_page"], decode.int)) 
    |> should.equal(Ok(1))
  testing.prop(response, "pagination", decode.at(["total_pages"], decode.int)) 
    |> should.equal(Ok(5))
}

pub fn initial_page_load_url_and_version_test() {
  let req = wisp_testing.request(http.Get, "/about", [], <<"">>)
  let config = inertia.config(version: "v2.1.0", ssr: False, encrypt_history: False)
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.assign_prop("title", json.string("About Us"))
    |> inertia.render("AboutPage")
  })
  
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("AboutPage"))
  testing.url(response) |> should.equal(Ok("/about"))
  testing.version(response) |> should.equal(Ok("v2.1.0"))
}

// Test redirects from initial page loads

pub fn initial_page_redirect_test() {
  let req = wisp_testing.request(http.Get, "/login", [], <<"">>)
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    inertia.redirect(ctx, to: "/dashboard")
  })
  
  // For initial page loads, should return standard HTTP redirect
  response.status |> should.equal(303)
  list.contains(response.headers, #("location", "/dashboard")) |> should.equal(True)
}

pub fn initial_page_external_redirect_test() {
  let response = inertia.external_redirect(to: "https://external.com/oauth")
  
  response.status |> should.equal(409)
  list.contains(response.headers, #("x-inertia-location", "https://external.com/oauth")) |> should.equal(True)
}

// Test mixed content types

pub fn mixed_request_handling_test() {
  // Test that the same handler works for both Inertia and regular requests
  let regular_req = wisp_testing.request(http.Get, "/mixed", [], <<"">>)
  let inertia_req = testing.inertia_request()
  let config = inertia.default_config()
  
  let test_handler = fn(ctx) {
    ctx
    |> inertia.assign_prop("data", json.string("shared data"))
    |> inertia.render("MixedPage")
  }
  
  // Test regular request (should return HTML)
  let html_response = inertia.middleware(regular_req, config, option.None, test_handler)
  html_response.status |> should.equal(200)
  testing.component(html_response) |> should.equal(Ok("MixedPage"))
  testing.prop(html_response, "data", decode.string) |> should.equal(Ok("shared data"))
  
  // Test Inertia request (should return JSON)
  let json_response = inertia.middleware(inertia_req, config, option.None, test_handler)
  json_response.status |> should.equal(200)
  testing.component(json_response) |> should.equal(Ok("MixedPage"))
  testing.prop(json_response, "data", decode.string) |> should.equal(Ok("shared data"))
}