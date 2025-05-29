import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option
import gleeunit
import gleeunit/should
import inertia_wisp/inertia
import inertia_wisp/testing

pub fn main() {
  gleeunit.main()
}

// Test configuration functions

pub fn default_config_test() {
  let config = inertia.default_config()
  config.version |> should.equal("1")
  config.ssr |> should.equal(False)
  config.encrypt_history |> should.equal(False)
}

pub fn custom_config_test() {
  let config =
    inertia.config(version: "2.0.0", ssr: True, encrypt_history: True)
  config.version |> should.equal("2.0.0")
  config.ssr |> should.equal(True)
  config.encrypt_history |> should.equal(True)
}

// Test basic rendering

pub fn render_basic_component_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_prop("title", json.string("Test Page"))
      |> inertia.render("TestComponent")
    })

  testing.component(response) |> should.equal(Ok("TestComponent"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Test Page"))
}

pub fn render_with_multiple_props_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_prop("title", json.string("Multiple Props"))
      |> inertia.assign_prop("count", json.int(42))
      |> inertia.assign_prop("active", json.bool(True))
      |> inertia.render("MultiPropComponent")
    })

  testing.component(response) |> should.equal(Ok("MultiPropComponent"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Multiple Props"))
  testing.prop(response, "count", decode.int) |> should.equal(Ok(42))
  testing.prop(response, "active", decode.bool) |> should.equal(Ok(True))
}

pub fn assign_props_batch_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let props = [
    #("name", json.string("John")),
    #("age", json.int(30)),
    #("email", json.string("john@example.com")),
  ]

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_props(props)
      |> inertia.render("UserProfile")
    })

  testing.component(response) |> should.equal(Ok("UserProfile"))
  testing.prop(response, "name", decode.string) |> should.equal(Ok("John"))
  testing.prop(response, "age", decode.int) |> should.equal(Ok(30))
  testing.prop(response, "email", decode.string)
  |> should.equal(Ok("john@example.com"))
}

// Test always props

pub fn assign_always_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_always_prop("csrf_token", json.string("abc123"))
      |> inertia.assign_prop("title", json.string("Page Title"))
      |> inertia.render("SecurePage")
    })

  testing.component(response) |> should.equal(Ok("SecurePage"))
  testing.prop(response, "csrf_token", decode.string)
  |> should.equal(Ok("abc123"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Page Title"))
}

pub fn assign_always_props_batch_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let always_props = [
    #("user_id", json.int(123)),
    #("app_name", json.string("Test App")),
    #("version", json.string("1.0.0")),
  ]

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_always_props(always_props)
      |> inertia.assign_prop("page_data", json.string("specific data"))
      |> inertia.render("AppLayout")
    })

  testing.component(response) |> should.equal(Ok("AppLayout"))
  testing.prop(response, "user_id", decode.int) |> should.equal(Ok(123))
  testing.prop(response, "app_name", decode.string)
  |> should.equal(Ok("Test App"))
  testing.prop(response, "version", decode.string) |> should.equal(Ok("1.0.0"))
  testing.prop(response, "page_data", decode.string)
  |> should.equal(Ok("specific data"))
}

// Test lazy props

pub fn assign_lazy_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_lazy_prop("expensive_data", fn() {
        json.array([json.string("item1"), json.string("item2")], fn(x) { x })
      })
      |> inertia.assign_prop("title", json.string("Lazy Props"))
      |> inertia.render("LazyComponent")
    })

  testing.component(response) |> should.equal(Ok("LazyComponent"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Lazy Props"))
  testing.prop(response, "expensive_data", decode.list(decode.string))
  |> should.equal(Ok(["item1", "item2"]))
}

pub fn assign_always_lazy_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_always_lazy_prop("notifications", fn() { json.int(5) })
      |> inertia.render("Dashboard")
    })

  testing.component(response) |> should.equal(Ok("Dashboard"))
  testing.prop(response, "notifications", decode.int) |> should.equal(Ok(5))
}

// Test optional props

pub fn assign_optional_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_optional_prop("debug_info", json.string("debug data"))
      |> inertia.assign_prop("title", json.string("Optional Props"))
      |> inertia.render("DebugPage")
    })

  testing.component(response) |> should.equal(Ok("DebugPage"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Optional Props"))
  // Optional props should not be included unless specifically requested
  testing.prop(response, "debug_info", decode.string) |> should.be_error()
}

pub fn assign_optional_lazy_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_optional_lazy_prop("admin_stats", fn() {
        json.object([#("count", json.int(100))])
      })
      |> inertia.assign_prop("title", json.string("Admin Panel"))
      |> inertia.render("AdminDashboard")
    })

  testing.component(response) |> should.equal(Ok("AdminDashboard"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Admin Panel"))
  // Optional lazy props should not be included unless specifically requested
  testing.prop(response, "admin_stats", decode.dynamic) |> should.be_error()
}

// Test partial data requests

pub fn partial_data_request_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["posts", "comments"])
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_prop(
        "posts",
        json.array([json.string("post1")], fn(x) { x }),
      )
      |> inertia.assign_prop(
        "comments",
        json.array([json.string("comment1")], fn(x) { x }),
      )
      |> inertia.assign_prop("sidebar", json.string("sidebar content"))
      |> inertia.render("BlogPage")
    })

  testing.component(response) |> should.equal(Ok("BlogPage"))
  testing.prop(response, "posts", decode.list(decode.string))
  |> should.equal(Ok(["post1"]))
  testing.prop(response, "comments", decode.list(decode.string))
  |> should.equal(Ok(["comment1"]))
  // Non-requested props should not be included in partial requests
  testing.prop(response, "sidebar", decode.string) |> should.be_error()
}

pub fn partial_data_with_always_props_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["specific_data"])
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_always_prop("csrf_token", json.string("token123"))
      |> inertia.assign_prop("specific_data", json.string("requested data"))
      |> inertia.assign_prop("other_data", json.string("not requested"))
      |> inertia.render("PartialPage")
    })

  testing.component(response) |> should.equal(Ok("PartialPage"))
  // Always props should be included even in partial requests
  testing.prop(response, "csrf_token", decode.string)
  |> should.equal(Ok("token123"))
  testing.prop(response, "specific_data", decode.string)
  |> should.equal(Ok("requested data"))
  // Non-requested regular props should not be included
  testing.prop(response, "other_data", decode.string) |> should.be_error()
}

// Test error handling

pub fn assign_errors_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let errors =
    dict.new()
    |> dict.insert("email", "Email is required")
    |> dict.insert("password", "Password too short")

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_errors(errors)
      |> inertia.assign_prop("title", json.string("Form with Errors"))
      |> inertia.render("ContactForm")
    })

  testing.component(response) |> should.equal(Ok("ContactForm"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Form with Errors"))
  testing.prop(response, "errors", decode.at(["email"], decode.string))
  |> should.equal(Ok("Email is required"))
  testing.prop(response, "errors", decode.at(["password"], decode.string))
  |> should.equal(Ok("Password too short"))
}

pub fn assign_error_single_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_error("username", "Username already taken")
      |> inertia.assign_prop("title", json.string("Registration"))
      |> inertia.render("RegisterForm")
    })

  testing.component(response) |> should.equal(Ok("RegisterForm"))
  testing.prop(response, "errors", decode.at(["username"], decode.string))
  |> should.equal(Ok("Username already taken"))
}

// Test redirects

pub fn redirect_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      inertia.redirect(ctx, to: "/dashboard")
    })

  response.status |> should.equal(303)
  list.contains(response.headers, #("location", "/dashboard"))
  |> should.equal(True)
}

pub fn external_redirect_test() {
  let response = inertia.external_redirect(to: "https://example.com")

  response.status |> should.equal(409)
  list.contains(response.headers, #("x-inertia-location", "https://example.com"))
  |> should.equal(True)
}

// Test history management

pub fn encrypt_history_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_prop("sensitive_data", json.string("secret"))
      |> inertia.encrypt_history()
      |> inertia.render("SecurePage")
    })

  testing.component(response) |> should.equal(Ok("SecurePage"))
  testing.encrypt_history(response) |> should.equal(Ok(True))
}

pub fn clear_history_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_prop("data", json.string("logged out"))
      |> inertia.clear_history()
      |> inertia.render("LoggedOutPage")
    })

  testing.component(response) |> should.equal(Ok("LoggedOutPage"))
  testing.clear_history(response) |> should.equal(Ok(True))
}

// Test SSR configuration

pub fn enable_ssr_test() {
  let req = testing.inertia_request()
  let config = inertia.config(version: "1", ssr: False, encrypt_history: False)

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      let updated_ctx = inertia.enable_ssr(ctx)
      updated_ctx.config.ssr |> should.equal(True)
      updated_ctx.config.version |> should.equal("1")
      updated_ctx.config.encrypt_history |> should.equal(False)
      inertia.render(updated_ctx, "TestPage")
    })

  testing.component(response) |> should.equal(Ok("TestPage"))
}

pub fn disable_ssr_test() {
  let req = testing.inertia_request()
  let config = inertia.config(version: "1", ssr: True, encrypt_history: False)

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      let updated_ctx = inertia.disable_ssr(ctx)
      updated_ctx.config.ssr |> should.equal(False)
      updated_ctx.config.version |> should.equal("1")
      updated_ctx.config.encrypt_history |> should.equal(False)
      inertia.render(updated_ctx, "TestPage")
    })

  testing.component(response) |> should.equal(Ok("TestPage"))
}

pub fn set_config_test() {
  let req = testing.inertia_request()
  let initial_config = inertia.default_config()

  let new_config =
    inertia.config(version: "2.0.0", ssr: True, encrypt_history: True)

  let response =
    inertia.middleware(req, initial_config, option.None, fn(ctx) {
      let updated_ctx = inertia.set_config(ctx, new_config)
      updated_ctx.config.version |> should.equal("2.0.0")
      updated_ctx.config.ssr |> should.equal(True)
      updated_ctx.config.encrypt_history |> should.equal(True)
      inertia.render(updated_ctx, "TestPage")
    })

  testing.component(response) |> should.equal(Ok("TestPage"))
}

// Test SSR supervisor configuration

pub fn ssr_config_test() {
  let config =
    inertia.ssr_config(
      enabled: True,
      path: "./ssr/server.js",
      module: "default",
      pool_size: 5,
      timeout_ms: 3000,
      supervisor_name: "test_ssr",
    )

  config.enabled |> should.equal(True)
  config.path |> should.equal("./ssr/server.js")
  config.module |> should.equal("default")
  config.pool_size |> should.equal(5)
  config.timeout_ms |> should.equal(3000)
  config.supervisor_name |> should.equal("test_ssr")
}

// Test complex nested data structures

pub fn complex_props_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let user_data =
    json.object([
      #("id", json.int(123)),
      #("name", json.string("John Doe")),
      #(
        "profile",
        json.object([
          #("email", json.string("john@example.com")),
          #("verified", json.bool(True)),
        ]),
      ),
      #(
        "tags",
        json.array([json.string("admin"), json.string("user")], fn(x) { x }),
      ),
    ])

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_prop("user", user_data)
      |> inertia.assign_prop(
        "settings",
        json.object([
          #("theme", json.string("dark")),
          #("notifications", json.bool(False)),
        ]),
      )
      |> inertia.render("UserDashboard")
    })

  testing.component(response) |> should.equal(Ok("UserDashboard"))
  testing.prop(response, "user", decode.at(["id"], decode.int))
  |> should.equal(Ok(123))
  testing.prop(response, "user", decode.at(["name"], decode.string))
  |> should.equal(Ok("John Doe"))
  testing.prop(response, "user", decode.at(["profile", "email"], decode.string))
  |> should.equal(Ok("john@example.com"))
  testing.prop(
    response,
    "user",
    decode.at(["tags"], decode.list(decode.string)),
  )
  |> should.equal(Ok(["admin", "user"]))
  testing.prop(response, "settings", decode.at(["theme"], decode.string))
  |> should.equal(Ok("dark"))
}

// Test URL and version extraction

pub fn url_extraction_test() {
  let req = testing.inertia_request()
  let config = inertia.config(version: "1", ssr: False, encrypt_history: False)

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.assign_prop("title", json.string("Test"))
      |> inertia.render("TestPage")
    })

  testing.url(response) |> should.equal(Ok("/"))
  testing.version(response) |> should.equal(Ok("1"))
}
