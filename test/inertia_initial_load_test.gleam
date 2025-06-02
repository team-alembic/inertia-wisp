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

// Props type for initial load tests
pub type InitialLoadProps {
  InitialLoadProps(
    title: String,
    message: String,
    csrf_token: String,
    user: User,
    dashboard_data: String,
    expensive_report: ExpensiveReport,
    notifications: Int,
    name: String,
    debug_info: String,
    admin_panel: Bool,
    amount: Int,
    users: List(UserData),
    pagination: Pagination,
    data: String,
  )
}

pub type User {
  User(id: Int, name: String)
}

pub type ExpensiveReport {
  ExpensiveReport(total: Int, items: List(String))
}

pub type UserData {
  UserData(id: Int, name: String, roles: List(String))
}

pub type Pagination {
  Pagination(current_page: Int, total_pages: Int, per_page: Int)
}

// Encoder for initial load props
pub fn encode_initial_props(props: InitialLoadProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
    #("csrf_token", json.string(props.csrf_token)),
    #("user", json.object([
      #("id", json.int(props.user.id)),
      #("name", json.string(props.user.name)),
    ])),
    #("dashboard_data", json.string(props.dashboard_data)),
    #("expensive_report", json.object([
      #("total", json.int(props.expensive_report.total)),
      #("items", json.array(props.expensive_report.items, json.string)),
    ])),
    #("notifications", json.int(props.notifications)),
    #("name", json.string(props.name)),
    #("debug_info", json.string(props.debug_info)),
    #("admin_panel", json.bool(props.admin_panel)),
    #("amount", json.int(props.amount)),
    #("users", json.array(props.users, fn(user) {
      json.object([
        #("id", json.int(user.id)),
        #("name", json.string(user.name)),
        #("roles", json.array(user.roles, json.string)),
      ])
    })),
    #("pagination", json.object([
      #("current_page", json.int(props.pagination.current_page)),
      #("total_pages", json.int(props.pagination.total_pages)),
      #("per_page", json.int(props.pagination.per_page)),
    ])),
    #("data", json.string(props.data)),
  ])
}

// Helper to create initial props
fn initial_props() -> InitialLoadProps {
  InitialLoadProps(
    title: "",
    message: "",
    csrf_token: "",
    user: User(id: 0, name: ""),
    dashboard_data: "",
    expensive_report: ExpensiveReport(total: 0, items: []),
    notifications: 0,
    name: "",
    debug_info: "",
    admin_panel: False,
    amount: 0,
    users: [],
    pagination: Pagination(current_page: 1, total_pages: 1, per_page: 10),
    data: "",
  )
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
    |> inertia.set_props(initial_props(), encode_initial_props)
    |> inertia.assign_prop("title", fn(props) {
      InitialLoadProps(..props, title: "Home Page")
    })
    |> inertia.assign_prop("message", fn(props) {
      InitialLoadProps(..props, message: "Welcome!")
    })
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
    |> inertia.set_props(initial_props(), encode_initial_props)
    |> inertia.assign_always_prop("csrf_token", fn(props) {
      InitialLoadProps(..props, csrf_token: "abc123")
    })
    |> inertia.assign_always_prop("user", fn(props) {
      InitialLoadProps(..props, user: User(id: 42, name: "Alice"))
    })
    |> inertia.assign_prop("dashboard_data", fn(props) {
      InitialLoadProps(..props, dashboard_data: "dashboard content")
    })
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
    |> inertia.set_props(initial_props(), encode_initial_props)
    |> inertia.assign_prop("title", fn(props) {
      InitialLoadProps(..props, title: "Reports")
    })
    |> inertia.assign_prop("expensive_report", fn(props) {
      InitialLoadProps(..props, expensive_report: ExpensiveReport(
        total: 1000,
        items: ["item1", "item2"]
      ))
    })
    |> inertia.assign_always_prop("notifications", fn(props) {
      InitialLoadProps(..props, notifications: 3)
    })
    |> inertia.render("ReportsPage")
  })
  
  response.status |> should.equal(200)
  testing.component(response) |> should.equal(Ok("ReportsPage"))
  testing.prop(response, "title", decode.string) |> should.equal(Ok("Reports"))
  // Props should be evaluated and included in initial loads
  testing.prop(response, "expensive_report", decode.at(["total"], decode.int)) |> should.equal(Ok(1000))
  testing.prop(response, "notifications", decode.int) |> should.equal(Ok(3))
}

pub fn initial_page_load_with_optional_props_test() {
  let req = wisp_testing.request(http.Get, "/profile", [], <<"">>)
  let config = inertia.default_config()
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.set_props(initial_props(), encode_initial_props)
    |> inertia.assign_prop("name", fn(props) {
      InitialLoadProps(..props, name: "John")
    })
    |> inertia.assign_optional_prop("debug_info", fn(props) {
      InitialLoadProps(..props, debug_info: "debug data")
    })
    |> inertia.assign_optional_prop("admin_panel", fn(props) {
      InitialLoadProps(..props, admin_panel: True)
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
    |> inertia.set_props(initial_props(), encode_initial_props)
    |> inertia.assign_errors(errors)
    |> inertia.assign_prop("title", fn(props) {
      InitialLoadProps(..props, title: "Contact Form")
    })
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
    |> inertia.set_props(initial_props(), encode_initial_props)
    |> inertia.assign_prop("amount", fn(props) {
      InitialLoadProps(..props, amount: 100)
    })
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
  
  let users_data = [
    UserData(id: 1, name: "Alice", roles: ["admin", "user"]),
    UserData(id: 2, name: "Bob", roles: ["user"])
  ]
  
  let response = inertia.middleware(req, config, option.None, fn(ctx) {
    ctx
    |> inertia.set_props(initial_props(), encode_initial_props)
    |> inertia.assign_prop("users", fn(props) {
      InitialLoadProps(..props, users: users_data)
    })
    |> inertia.assign_prop("pagination", fn(props) {
      InitialLoadProps(..props, pagination: Pagination(
        current_page: 1,
        total_pages: 5,
        per_page: 10
      ))
    })
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
    |> inertia.set_props(initial_props(), encode_initial_props)
    |> inertia.assign_prop("title", fn(props) {
      InitialLoadProps(..props, title: "About Us")
    })
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
  
  let response = inertia.middleware(req, config, option.None, fn(_ctx) {
    inertia.redirect(req, to: "/dashboard")
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
    |> inertia.set_props(initial_props(), encode_initial_props)
    |> inertia.assign_prop("title", fn(props) {
      InitialLoadProps(..props, title: "Test Page")
    })
    |> inertia.render("TestPage")
  }
  
  // Test regular request (should return HTML)
  let html_response = inertia.middleware(regular_req, config, option.None, test_handler)
  html_response.status |> should.equal(200)
  testing.component(html_response) |> should.equal(Ok("TestPage"))
  testing.prop(html_response, "title", decode.string) |> should.equal(Ok("Test Page"))
  
  // Test Inertia request (should return JSON)
  let json_response = inertia.middleware(inertia_req, config, option.None, test_handler)
  json_response.status |> should.equal(200)
  testing.component(json_response) |> should.equal(Ok("TestPage"))
  testing.prop(json_response, "title", decode.string) |> should.equal(Ok("Test Page"))
}