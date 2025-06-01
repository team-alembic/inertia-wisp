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

// Props type for main inertia tests
pub type MainTestProps {
  MainTestProps(
    title: String,
    count: Int,
    active: Bool,
    name: String,
    age: Int,
    email: String,
    csrf_token: String,
    page_data: String,
    user_id: Int,
    app_name: String,
    version: String,
    expensive_data: List(String),
    notifications: Int,
    debug_info: String,
    admin_stats: AdminStats,
    posts: List(String),
    comments: List(String),
    sidebar: String,
    specific_data: String,
    other_data: String,
    sensitive_data: String,
    data: String,
    user: User,
    settings: Settings,
  )
}

pub type AdminStats {
  AdminStats(count: Int)
}

pub type User {
  User(id: Int, name: String, profile: Profile, tags: List(String))
}

pub type Profile {
  Profile(email: String, verified: Bool)
}

pub type Settings {
  Settings(theme: String, notifications: Bool)
}

// Encoder for main test props
pub fn encode_main_props(props: MainTestProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("count", json.int(props.count)),
    #("active", json.bool(props.active)),
    #("name", json.string(props.name)),
    #("age", json.int(props.age)),
    #("email", json.string(props.email)),
    #("csrf_token", json.string(props.csrf_token)),
    #("page_data", json.string(props.page_data)),
    #("user_id", json.int(props.user_id)),
    #("app_name", json.string(props.app_name)),
    #("version", json.string(props.version)),
    #("expensive_data", json.array(props.expensive_data, json.string)),
    #("notifications", json.int(props.notifications)),
    #("debug_info", json.string(props.debug_info)),
    #("admin_stats", json.object([#("count", json.int(props.admin_stats.count))])),
    #("posts", json.array(props.posts, json.string)),
    #("comments", json.array(props.comments, json.string)),
    #("sidebar", json.string(props.sidebar)),
    #("specific_data", json.string(props.specific_data)),
    #("other_data", json.string(props.other_data)),
    #("sensitive_data", json.string(props.sensitive_data)),
    #("data", json.string(props.data)),
    #("user", json.object([
      #("id", json.int(props.user.id)),
      #("name", json.string(props.user.name)),
      #("profile", json.object([
        #("email", json.string(props.user.profile.email)),
        #("verified", json.bool(props.user.profile.verified)),
      ])),
      #("tags", json.array(props.user.tags, json.string)),
    ])),
    #("settings", json.object([
      #("theme", json.string(props.settings.theme)),
      #("notifications", json.bool(props.settings.notifications)),
    ])),
  ])
}

// Helper to create initial props
fn initial_props() -> MainTestProps {
  MainTestProps(
    title: "",
    count: 0,
    active: False,
    name: "",
    age: 0,
    email: "",
    csrf_token: "",
    page_data: "",
    user_id: 0,
    app_name: "",
    version: "",
    expensive_data: [],
    notifications: 0,
    debug_info: "",
    admin_stats: AdminStats(count: 0),
    posts: [],
    comments: [],
    sidebar: "",
    specific_data: "",
    other_data: "",
    sensitive_data: "",
    data: "",
    user: User(id: 0, name: "", profile: Profile(email: "", verified: False), tags: []),
    settings: Settings(theme: "", notifications: False),
  )
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
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_prop("title", fn(props) {
        MainTestProps(..props, title: "Test Page")
      })
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
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_prop("title", fn(props) {
        MainTestProps(..props, title: "Multiple Props")
      })
      |> inertia.assign_prop("posts", fn(props) {
        MainTestProps(..props, posts: ["Alice", "Bob"])
      })
      |> inertia.assign_prop("count", fn(props) {
        MainTestProps(..props, count: 2)
      })
      |> inertia.assign_prop("active", fn(props) {
        MainTestProps(..props, active: True)
      })
      |> inertia.render("MultiPropComponent")
    })

  testing.component(response) |> should.equal(Ok("MultiPropComponent"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Multiple Props"))
  testing.prop(response, "count", decode.int) |> should.equal(Ok(2))
  testing.prop(response, "active", decode.bool) |> should.equal(Ok(True))
}

// Test always props

pub fn assign_always_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_always_prop("csrf_token", fn(props) {
        MainTestProps(..props, csrf_token: "abc123")
      })
      |> inertia.assign_prop("title", fn(props) {
        MainTestProps(..props, title: "Secure Page")
      })
      |> inertia.render("SecurePage")
    })

  testing.component(response) |> should.equal(Ok("SecurePage"))
  testing.prop(response, "csrf_token", decode.string)
  |> should.equal(Ok("abc123"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Secure Page"))
}

// Test expensive computation props (replaces lazy props)

pub fn assign_expensive_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_prop("expensive_data", fn(props) {
        MainTestProps(..props, expensive_data: ["item1", "item2"])
      })
      |> inertia.assign_prop("title", fn(props) {
        MainTestProps(..props, title: "Expensive Component")
      })
      |> inertia.render("ExpensiveComponent")
    })

  testing.component(response) |> should.equal(Ok("ExpensiveComponent"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Expensive Component"))
  testing.prop(response, "expensive_data", decode.list(decode.string))
  |> should.equal(Ok(["item1", "item2"]))
}

pub fn assign_always_expensive_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_always_prop("notifications", fn(props) {
        MainTestProps(..props, notifications: 5)
      })
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
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_optional_prop("debug_info", fn(props) {
        MainTestProps(..props, debug_info: "debug data")
      })
      |> inertia.assign_prop("title", fn(props) {
        MainTestProps(..props, title: "Debug Page")
      })
      |> inertia.render("DebugPage")
    })

  testing.component(response) |> should.equal(Ok("DebugPage"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Debug Page"))
  // Optional props should not be included unless specifically requested
  testing.prop(response, "debug_info", decode.string) |> should.be_error()
}

pub fn assign_optional_expensive_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_optional_prop("admin_stats", fn(props) {
        MainTestProps(..props, admin_stats: AdminStats(count: 100))
      })
      |> inertia.assign_prop("title", fn(props) {
        MainTestProps(..props, title: "Admin Dashboard")
      })
      |> inertia.render("AdminDashboard")
    })

  testing.component(response) |> should.equal(Ok("AdminDashboard"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Admin Dashboard"))
  // Optional props should not be included unless specifically requested
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
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_prop("posts", fn(props) {
        MainTestProps(..props, posts: ["post1"])
      })
      |> inertia.assign_prop("comments", fn(props) {
        MainTestProps(..props, comments: ["comment1"])
      })
      |> inertia.assign_prop("sidebar", fn(props) {
        MainTestProps(..props, sidebar: "sidebar content")
      })
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
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_always_prop("csrf_token", fn(props) {
        MainTestProps(..props, csrf_token: "token123")
      })
      |> inertia.assign_prop("specific_data", fn(props) {
        MainTestProps(..props, specific_data: "requested data")
      })
      |> inertia.assign_prop("other_data", fn(props) {
        MainTestProps(..props, other_data: "not requested")
      })
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

// Test error handling (now using regular props)

pub fn assign_errors_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let errors =
    dict.new()
    |> dict.insert("email", "Invalid email")
    |> dict.insert("password", "Password too short")

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_errors(errors)
      |> inertia.assign_prop("title", fn(props) {
        MainTestProps(..props, title: "Form with Errors")
      })
      |> inertia.render("ErrorForm")
    })

  testing.component(response) |> should.equal(Ok("ErrorForm"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Form with Errors"))
  testing.prop(response, "errors", decode.at(["email"], decode.string))
  |> should.equal(Ok("Invalid email"))
  testing.prop(response, "errors", decode.at(["password"], decode.string))
  |> should.equal(Ok("Password too short"))
}

pub fn assign_error_single_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let errors = dict.new() |> dict.insert("username", "Username already taken")

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_errors(errors)
      |> inertia.render("RegisterForm")
    })

  testing.component(response) |> should.equal(Ok("RegisterForm"))
  testing.prop(response, "errors", decode.at(["username"], decode.string))
  |> should.equal(Ok("Username already taken"))
}

pub fn assign_errors_only_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let errors = dict.new()
    |> dict.insert("general", "Something went wrong")

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_errors(errors)
      |> inertia.render("ErrorPage")
    })

  testing.component(response) |> should.equal(Ok("ErrorPage"))
  testing.prop(response, "errors", decode.at(["general"], decode.string))
  |> should.equal(Ok("Something went wrong"))
  // Verify that no other props are included
  testing.prop(response, "title", decode.string) |> should.be_error()
}

pub fn assign_errors_with_partial_reload_test() {
  let req = testing.inertia_request()
    |> testing.partial_data(["title", "count"])
  let config = inertia.default_config()

  let errors = dict.new()
    |> dict.insert("name", "Name is required")
    |> dict.insert("email", "Invalid email")

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_errors(errors)
      |> inertia.assign_prop("title", fn(props) {
        MainTestProps(..props, title: "Partial with Errors")
      })
      |> inertia.assign_prop("count", fn(props) {
        MainTestProps(..props, count: 42)
      })
      |> inertia.assign_prop("name", fn(props) {
        MainTestProps(..props, name: "Should not be included")
      })
      |> inertia.render("PartialErrorPage")
    })

  testing.component(response) |> should.equal(Ok("PartialErrorPage"))
  // Requested props should be included
  testing.prop(response, "title", decode.string) |> should.equal(Ok("Partial with Errors"))
  testing.prop(response, "count", decode.int) |> should.equal(Ok(42))
  // Errors should always be included
  testing.prop(response, "errors", decode.at(["name"], decode.string)) |> should.equal(Ok("Name is required"))
  testing.prop(response, "errors", decode.at(["email"], decode.string)) |> should.equal(Ok("Invalid email"))
  // Non-requested props should not be included
  testing.prop(response, "name", decode.string) |> should.be_error()
}

// Test redirects

pub fn redirect_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(_ctx) {
      inertia.redirect(req, to: "/dashboard")
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

// Test history management (using config instead of context functions)

pub fn encrypt_history_test() {
  let req = testing.inertia_request()
  let config = inertia.config(version: "1", ssr: False, encrypt_history: True)

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_prop("sensitive_data", fn(props) {
        MainTestProps(..props, sensitive_data: "secret")
      })
      |> inertia.render("SecurePage")
    })

  testing.component(response) |> should.equal(Ok("SecurePage"))
  testing.encrypt_history(response) |> should.equal(Ok(True))
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

  let user_data = User(
    id: 123,
    name: "Alice",
    profile: Profile(email: "alice@example.com", verified: True),
    tags: ["admin", "user"]
  )
  let settings_data = Settings(theme: "dark", notifications: False)

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_prop("user", fn(props) {
        MainTestProps(..props, user: user_data)
      })
      |> inertia.assign_prop("settings", fn(props) {
        MainTestProps(..props, settings: settings_data)
      })
      |> inertia.render("UserDashboard")
    })

  testing.component(response) |> should.equal(Ok("UserDashboard"))
  testing.prop(response, "user", decode.at(["id"], decode.int))
  |> should.equal(Ok(123))
  testing.prop(response, "user", decode.at(["name"], decode.string))
  |> should.equal(Ok("Alice"))
  testing.prop(response, "user", decode.at(["profile", "email"], decode.string))
  |> should.equal(Ok("alice@example.com"))
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
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.assign_prop("title", fn(props) {
        MainTestProps(..props, title: "Test")
      })
      |> inertia.render("TestPage")
    })

  testing.url(response) |> should.equal(Ok("/"))
  testing.version(response) |> should.equal(Ok("1"))
}