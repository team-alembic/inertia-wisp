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
    #(
      "admin_stats",
      json.object([#("count", json.int(props.admin_stats.count))]),
    ),
    #("posts", json.array(props.posts, json.string)),
    #("comments", json.array(props.comments, json.string)),
    #("sidebar", json.string(props.sidebar)),
    #("specific_data", json.string(props.specific_data)),
    #("other_data", json.string(props.other_data)),
    #("sensitive_data", json.string(props.sensitive_data)),
    #("data", json.string(props.data)),
    #("user", user_to_json(props.user)),
    #("settings", settings_to_json(props.settings)),
  ])
}

// Individual type encoders
pub fn user_to_json(user: User) -> json.Json {
  json.object([
    #("id", json.int(user.id)),
    #("name", json.string(user.name)),
    #("profile", profile_to_json(user.profile)),
    #("tags", json.array(user.tags, json.string)),
  ])
}

pub fn profile_to_json(profile: Profile) -> json.Json {
  json.object([
    #("email", json.string(profile.email)),
    #("verified", json.bool(profile.verified)),
  ])
}

pub fn settings_to_json(settings: Settings) -> json.Json {
  json.object([
    #("theme", json.string(settings.theme)),
    #("notifications", json.bool(settings.notifications)),
  ])
}

// Helper functions for typed prop assignment
fn title(t: String) {
  #("title", fn(p) { MainTestProps(..p, title: t) })
}

fn count(c: Int) {
  #("count", fn(p) { MainTestProps(..p, count: c) })
}

fn active(a: Bool) {
  #("active", fn(p) { MainTestProps(..p, active: a) })
}

fn name(n: String) {
  #("name", fn(p) { MainTestProps(..p, name: n) })
}

fn csrf_token(token: String) {
  #("csrf_token", fn(p) { MainTestProps(..p, csrf_token: token) })
}

fn expensive_data(data: List(String)) {
  #("expensive_data", fn(p) { MainTestProps(..p, expensive_data: data) })
}

fn notifications(n: Int) {
  #("notifications", fn(p) { MainTestProps(..p, notifications: n) })
}

fn debug_info(info: fn() -> String) {
  #("debug_info", fn(p) { MainTestProps(..p, debug_info: info()) })
}

fn admin_stats(stats: AdminStats) {
  #("admin_stats", fn(p) { MainTestProps(..p, admin_stats: stats) })
}

fn posts(p: List(String)) {
  #("posts", fn(props) { MainTestProps(..props, posts: p) })
}

fn comments(c: List(String)) {
  #("comments", fn(p) { MainTestProps(..p, comments: c) })
}

fn sidebar(s: String) {
  #("sidebar", fn(p) { MainTestProps(..p, sidebar: s) })
}

fn specific_data(data: String) {
  #("specific_data", fn(p) { MainTestProps(..p, specific_data: data) })
}

fn other_data(data: String) {
  #("other_data", fn(p) { MainTestProps(..p, other_data: data) })
}

fn sensitive_data(data: String) {
  #("sensitive_data", fn(p) { MainTestProps(..p, sensitive_data: data) })
}

fn user(u: User) {
  #("user", fn(p) { MainTestProps(..p, user: u) })
}

fn settings(s: Settings) {
  #("settings", fn(p) { MainTestProps(..p, settings: s) })
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
    user: User(
      id: 0,
      name: "",
      profile: Profile(email: "", verified: False),
      tags: [],
    ),
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
      |> inertia.prop(title("Test Page"))
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
      |> inertia.prop(title("Complex Page"))
      |> inertia.prop(posts(["Post 1", "Post 2"]))
      |> inertia.prop(count(42))
      |> inertia.prop(active(True))
      |> inertia.render("ComplexComponent")
    })

  testing.component(response) |> should.equal(Ok("ComplexComponent"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Complex Page"))
  testing.prop(response, "count", decode.int) |> should.equal(Ok(42))
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
      |> inertia.always_prop(csrf_token("abc123"))
      |> inertia.prop(title("Always Props Test"))
      |> inertia.render("AlwaysPropsComponent")
    })

  testing.component(response) |> should.equal(Ok("AlwaysPropsComponent"))
  testing.prop(response, "csrf_token", decode.string)
  |> should.equal(Ok("abc123"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Always Props Test"))
}

// Test expensive computation props (replaces lazy props)

pub fn assign_expensive_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.prop(expensive_data(["data1", "data2"]))
      |> inertia.prop(title("Expensive Data Test"))
      |> inertia.render("ExpensiveDataComponent")
    })

  testing.component(response) |> should.equal(Ok("ExpensiveDataComponent"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Expensive Data Test"))
  testing.prop(response, "expensive_data", decode.list(decode.string))
  |> should.equal(Ok(["data1", "data2"]))
}

pub fn assign_always_expensive_prop_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.always_prop(notifications(5))
      |> inertia.render("NotificationsComponent")
    })

  testing.component(response) |> should.equal(Ok("NotificationsComponent"))
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
      |> inertia.optional_prop(debug_info(fn() { "Debug data" }))
      |> inertia.prop(title("Optional Props Test"))
      |> inertia.render("OptionalPropsComponent")
    })

  testing.component(response) |> should.equal(Ok("OptionalPropsComponent"))
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Optional Props Test"))
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
      |> inertia.optional_prop(admin_stats(AdminStats(count: 100)))
      |> inertia.prop(title("Admin Dashboard"))
      |> inertia.render("AdminComponent")
    })

  testing.component(response) |> should.equal(Ok("AdminComponent"))
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
      |> inertia.prop(posts(["Post A", "Post B"]))
      |> inertia.prop(comments(["Comment 1", "Comment 2"]))
      |> inertia.prop(sidebar("Sidebar content"))
      |> inertia.render("BlogComponent")
    })

  testing.component(response) |> should.equal(Ok("BlogComponent"))
  testing.prop(response, "posts", decode.list(decode.string))
  |> should.equal(Ok(["Post A", "Post B"]))
  testing.prop(response, "comments", decode.list(decode.string))
  |> should.equal(Ok(["Comment 1", "Comment 2"]))
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
      |> inertia.always_prop(csrf_token("token123"))
      |> inertia.prop(specific_data("specific"))
      |> inertia.prop(other_data("other"))
      |> inertia.render("PartialRequestComponent")
    })

  testing.component(response) |> should.equal(Ok("PartialRequestComponent"))
  // Always props should be included even in partial requests
  testing.prop(response, "csrf_token", decode.string)
  |> should.equal(Ok("token123"))
  testing.prop(response, "specific_data", decode.string)
  |> should.equal(Ok("specific"))
  // Non-requested regular props should not be included
  testing.prop(response, "other_data", decode.string) |> should.be_error()
}

// Test error handling (now using regular props)

pub fn erros_test() {
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
      |> inertia.errors(errors)
      |> inertia.prop(title("Form with Errors"))
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
      |> inertia.errors(errors)
      |> inertia.render("RegisterForm")
    })

  testing.component(response) |> should.equal(Ok("RegisterForm"))
  testing.prop(response, "errors", decode.at(["username"], decode.string))
  |> should.equal(Ok("Username already taken"))
}

pub fn erros_only_test() {
  let req = testing.inertia_request()
  let config = inertia.default_config()

  let errors =
    dict.new()
    |> dict.insert("general", "Something went wrong")

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.errors(errors)
      |> inertia.render("ErrorPage")
    })

  testing.component(response) |> should.equal(Ok("ErrorPage"))
  testing.prop(response, "errors", decode.at(["general"], decode.string))
  |> should.equal(Ok("Something went wrong"))
  // Verify that no other props are included
  testing.prop(response, "title", decode.string) |> should.be_error()
}

pub fn erros_with_partial_reload_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["title", "count"])
  let config = inertia.default_config()

  let errors =
    dict.new()
    |> dict.insert("name", "Name is required")
    |> dict.insert("email", "Invalid email")

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.errors(errors)
      |> inertia.prop(title("Partial with Errors"))
      |> inertia.prop(count(42))
      |> inertia.prop(name("Should not be included"))
      |> inertia.render("PartialErrorPage")
    })

  testing.component(response) |> should.equal(Ok("PartialErrorPage"))
  // Requested props should be included
  testing.prop(response, "title", decode.string)
  |> should.equal(Ok("Partial with Errors"))
  testing.prop(response, "count", decode.int) |> should.equal(Ok(42))
  // Errors should always be included
  testing.prop(response, "errors", decode.at(["name"], decode.string))
  |> should.equal(Ok("Name is required"))
  testing.prop(response, "errors", decode.at(["email"], decode.string))
  |> should.equal(Ok("Invalid email"))
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
      |> inertia.prop(sensitive_data("sensitive info"))
      |> inertia.render("SensitiveComponent")
    })

  testing.component(response) |> should.equal(Ok("SensitiveComponent"))
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

  let user_data =
    User(
      id: 123,
      name: "Alice",
      profile: Profile(email: "alice@example.com", verified: True),
      tags: ["admin", "user"],
    )
  let settings_data = Settings(theme: "dark", notifications: False)

  let response =
    inertia.middleware(req, config, option.None, fn(ctx) {
      ctx
      |> inertia.set_props(initial_props(), encode_main_props)
      |> inertia.prop(user(user_data))
      |> inertia.prop(settings(settings_data))
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
      |> inertia.prop(title("Test"))
      |> inertia.render("TestPage")
    })

  testing.url(response) |> should.equal(Ok("/"))
  testing.version(response) |> should.equal(Ok("1"))
}
