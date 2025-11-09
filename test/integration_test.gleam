import gleam/dict
import gleam/dynamic/decode
import gleam/http/response
import gleam/json
import gleam/option
import inertia_wisp/html
import inertia_wisp/inertia
import inertia_wisp/testing
import wisp.{type Request, type Response}
import wisp/simulate

// Test props types for our handlers
type HomeProps {
  HomeProps(title: String, message: String)
}

type UserProps {
  UserProps(
    name: String,
    email: String,
    posts: option.Option(List(String)),
    comments: option.Option(Int),
  )
}

type DashboardProps {
  DashboardProps(
    user: String,
    notifications: Int,
    expensive_data: option.Option(String),
  )
}

// Prop encoders
fn encode_home_props(props: HomeProps) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
  ])
}

fn encode_user_props(props: UserProps) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("name", json.string(props.name)),
    #("email", json.string(props.email)),
    #(
      "posts",
      json.nullable(props.posts, json.array(_, fn(post) { json.string(post) })),
    ),
    #("comments", json.nullable(props.comments, json.int)),
  ])
}

fn encode_dashboard_props(props: DashboardProps) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("user", json.string(props.user)),
    #("notifications", json.int(props.notifications)),
    #("expensive_data", json.nullable(props.expensive_data, json.string)),
  ])
}

// Handler functions that we'll test
fn home_handler(req: Request) -> Response {
  let props = HomeProps(title: "Welcome", message: "Hello, Inertia!")

  req
  |> inertia.response_builder("Home")
  |> inertia.props(props, encode_home_props)
  |> inertia.response(200, html.default_layout)
}

fn user_profile_handler(req: Request) -> Response {
  let props =
    UserProps(
      name: "Alice Smith",
      email: "alice@example.com",
      posts: option.None,
      comments: option.None,
    )

  req
  |> inertia.response_builder("Users/Profile")
  |> inertia.props(props, encode_user_props)
  |> inertia.lazy("posts", fn(props) {
    Ok(
      UserProps(
        ..props,
        posts: option.Some([
          "Post 1",
          "Post 2",
          "Post 3",
        ]),
      ),
    )
  })
  |> inertia.lazy("comments", fn(props) {
    Ok(UserProps(..props, comments: option.Some(42)))
  })
  |> inertia.response(200, html.default_layout)
}

fn dashboard_handler(req: Request) -> Response {
  let props =
    DashboardProps(user: "Bob", notifications: 5, expensive_data: option.None)

  req
  |> inertia.response_builder("Dashboard")
  |> inertia.props(props, encode_dashboard_props)
  |> inertia.always("user")
  |> inertia.defer("expensive_data", fn(props) {
    Ok(DashboardProps(..props, expensive_data: option.Some("loaded-data")))
  })
  |> inertia.response(200, html.default_layout)
}

fn create_user_handler(req: Request) -> Response {
  // Simulate validation errors
  let errors =
    dict.from_list([
      #("name", "Name is required"),
      #("email", "Invalid email format"),
    ])

  req
  |> inertia.response_builder("Users/Create")
  |> inertia.errors(errors)
  |> inertia.redirect("/users/new")
}

// Tests demonstrating usage of inertia_wisp/testing module

pub fn can_extract_component_and_props_from_inertia_response_test() {
  let req = testing.inertia_request()
  let response = home_handler(req)

  assert Ok("Home") == testing.component(response)
  assert Ok("Welcome") == testing.prop(response, "title", decode.string)
  assert Ok("Hello, Inertia!")
    == testing.prop(response, "message", decode.string)
}

pub fn can_extract_component_and_props_from_html_response_test() {
  let req = testing.regular_request()
  let response = home_handler(req)

  assert Ok("Home") == testing.component(response)
  assert Ok("Welcome") == testing.prop(response, "title", decode.string)
}

pub fn url_extraction_includes_path_and_query_params_test() {
  let req = testing.inertia_request_to("/users?page=2&sort=name")
  let response = user_profile_handler(req)

  assert Ok("/users?page=2&sort=name") == testing.url(response)
}

pub fn prop_extraction_returns_error_for_missing_field_test() {
  let req = testing.inertia_request()
  let response = home_handler(req)

  let assert Error(_) = testing.prop(response, "nonexistent", decode.string)
}

pub fn version_extraction_test() {
  let props = HomeProps(title: "Test", message: "Version test")

  // Use version "1" to match what testing.inertia_request() sends
  let req = testing.inertia_request()
  let response =
    req
    |> inertia.response_builder("Home")
    |> inertia.props(props, encode_home_props)
    |> inertia.version("1")
    |> inertia.response(200, html.default_layout)

  assert Ok("1") == testing.version(response)
}

pub fn encrypt_history_flag_test() {
  let props = HomeProps(title: "Test", message: "Encrypt test")

  let req = testing.inertia_request()
  let response =
    req
    |> inertia.response_builder("Home")
    |> inertia.props(props, encode_home_props)
    |> inertia.encrypt_history()
    |> inertia.response(200, html.default_layout)

  assert Ok(True) == testing.encrypt_history(response)
}

pub fn clear_history_flag_test() {
  let props = HomeProps(title: "Test", message: "Clear test")

  let req = testing.inertia_request()
  let response =
    req
    |> inertia.response_builder("Home")
    |> inertia.props(props, encode_home_props)
    |> inertia.clear_history()
    |> inertia.response(200, html.default_layout)

  assert Ok(True) == testing.clear_history(response)
}

pub fn inertia_post_helper_creates_redirect_on_validation_errors_test() {
  let data =
    json.object([
      #("name", json.string("John Doe")),
      #("email", json.string("john@example.com")),
    ])

  let req = testing.inertia_post("/users", data)
  let response = create_user_handler(req)

  assert 303 == response.status
  assert Ok("/users/new") == response.get_header(response, "location")
  let assert Ok(_) = response.get_header(response, "set-cookie")
}

// Tests exercising response_builder behavior (lazy, defer, partial reload, etc.)

pub fn lazy_props_evaluated_on_standard_visit_test() {
  let req = testing.inertia_request()
  let response = user_profile_handler(req)

  // Lazy props ARE evaluated and included on standard (non-partial) visits
  assert Ok(["Post 1", "Post 2", "Post 3"])
    == testing.prop(response, "posts", decode.list(decode.string))
  assert Ok(42) == testing.prop(response, "comments", decode.int)
}

pub fn partial_reload_evaluates_only_requested_lazy_props_test() {
  let req =
    testing.inertia_request_to("/users/123")
    |> testing.partial_component("Users/Profile")
    |> testing.partial_data(["posts"])

  let response = user_profile_handler(req)

  // Requested lazy prop should be evaluated
  assert Ok(["Post 1", "Post 2", "Post 3"])
    == testing.prop(response, "posts", decode.list(decode.string))

  // Non-requested props should not be present
  let assert Error(_) = testing.prop(response, "comments", decode.int)
  let assert Error(_) = testing.prop(response, "name", decode.string)
}

pub fn partial_reload_with_component_mismatch_includes_all_props_test() {
  let req =
    testing.inertia_request_to("/users/123")
    |> testing.partial_component("WrongComponent")
    |> testing.partial_data(["posts"])

  let response = user_profile_handler(req)

  // Component mismatch = no filtering, treated as full visit
  // All default props present
  assert Ok("Alice Smith") == testing.prop(response, "name", decode.string)
  assert Ok("alice@example.com")
    == testing.prop(response, "email", decode.string)

  // Lazy props ARE evaluated since it's treated as a full visit
  assert Ok(["Post 1", "Post 2", "Post 3"])
    == testing.prop(response, "posts", decode.list(decode.string))
}

pub fn always_prop_included_in_partial_reload_test() {
  let req =
    testing.inertia_request_to("/dashboard")
    |> testing.partial_component("Dashboard")
    |> testing.partial_data(["notifications"])

  let response = dashboard_handler(req)

  // "user" is marked as "always", so it should be included
  assert Ok("Bob") == testing.prop(response, "user", decode.string)
  assert Ok(5) == testing.prop(response, "notifications", decode.int)
}

pub fn deferred_props_not_evaluated_initially_test() {
  let req = testing.inertia_request()
  let response = dashboard_handler(req)

  // Deferred prop should not be present in initial response
  let assert Error(_) = testing.prop(response, "expensive_data", decode.string)

  // Should have deferredProps metadata
  assert Ok(["expensive_data"])
    == testing.deferred_props(response, "default", decode.list(decode.string))
}

pub fn deferred_props_evaluated_when_explicitly_requested_test() {
  let req =
    testing.inertia_request_to("/dashboard")
    |> testing.partial_component("Dashboard")
    |> testing.partial_data(["expensive_data"])

  let response = dashboard_handler(req)

  // Deferred prop should now be evaluated
  assert Ok("loaded-data")
    == testing.prop(response, "expensive_data", decode.string)

  // Should not re-advertise deferredProps metadata
  let assert Error(_) =
    testing.deferred_props(response, "default", decode.list(decode.string))
}

pub fn version_mismatch_returns_409_conflict_test() {
  // Create a handler with version "v2"
  let props = HomeProps(title: "Test", message: "Version test")

  let versioned_handler = fn(req: Request) -> Response {
    req
    |> inertia.response_builder("Home")
    |> inertia.props(props, encode_home_props)
    |> inertia.version("v2")
    |> inertia.response(200, html.default_layout)
  }

  // Client sends request with old version "v1"
  let req =
    testing.inertia_request()
    |> simulate.header("x-inertia-version", "v1")

  let response = versioned_handler(req)

  // Should return 409 Conflict when versions don't match
  assert 409 == response.status

  // Should include X-Inertia-Location header for client to reload
  let assert Ok(_) = response.get_header(response, "x-inertia-location")
}

pub fn version_match_returns_normal_response_test() {
  // Create a handler with version "v2"
  let props = HomeProps(title: "Test", message: "Version test")

  let versioned_handler = fn(req: Request) -> Response {
    req
    |> inertia.response_builder("Home")
    |> inertia.props(props, encode_home_props)
    |> inertia.version("v2")
    |> inertia.response(200, html.default_layout)
  }

  // Client sends request with matching version "v2"
  let req =
    testing.inertia_request()
    |> simulate.header("x-inertia-version", "v2")

  let response = versioned_handler(req)

  // Should return normal 200 response when versions match
  assert 200 == response.status
  assert Ok("Home") == testing.component(response)
}

pub fn version_mismatch_on_post_returns_normal_response_test() {
  // Per Inertia protocol: "409 Conflict responses are only sent for GET requests,
  // and not for POST/PUT/PATCH/DELETE requests"
  let props = HomeProps(title: "Test", message: "Version test")

  let versioned_handler = fn(req: Request) -> Response {
    req
    |> inertia.response_builder("Home")
    |> inertia.props(props, encode_home_props)
    |> inertia.version("v2")
    |> inertia.response(200, html.default_layout)
  }

  // Client sends POST request with old version "v1"
  let req =
    testing.inertia_post("/", json.null())
    |> simulate.header("x-inertia-version", "v1")

  let response = versioned_handler(req)

  // Should return normal 200 response, NOT 409
  assert 200 == response.status
  assert Ok("Home") == testing.component(response)
}

pub fn version_mismatch_on_put_returns_normal_response_test() {
  let props = HomeProps(title: "Test", message: "Version test")

  let versioned_handler = fn(req: Request) -> Response {
    req
    |> inertia.response_builder("Home")
    |> inertia.props(props, encode_home_props)
    |> inertia.version("v2")
    |> inertia.response(200, html.default_layout)
  }

  // Client sends PUT request with old version "v1"
  let req =
    testing.inertia_put("/", json.null())
    |> simulate.header("x-inertia-version", "v1")

  let response = versioned_handler(req)

  // Should return normal 200 response, NOT 409
  assert 200 == response.status
  assert Ok("Home") == testing.component(response)
}

pub fn version_mismatch_on_patch_returns_normal_response_test() {
  let props = HomeProps(title: "Test", message: "Version test")

  let versioned_handler = fn(req: Request) -> Response {
    req
    |> inertia.response_builder("Home")
    |> inertia.props(props, encode_home_props)
    |> inertia.version("v2")
    |> inertia.response(200, html.default_layout)
  }

  // Client sends PATCH request with old version "v1"
  let req =
    testing.inertia_patch("/", json.null())
    |> simulate.header("x-inertia-version", "v1")

  let response = versioned_handler(req)

  // Should return normal 200 response, NOT 409
  assert 200 == response.status
  assert Ok("Home") == testing.component(response)
}

pub fn version_mismatch_on_delete_returns_normal_response_test() {
  let props = HomeProps(title: "Test", message: "Version test")

  let versioned_handler = fn(req: Request) -> Response {
    req
    |> inertia.response_builder("Home")
    |> inertia.props(props, encode_home_props)
    |> inertia.version("v2")
    |> inertia.response(200, html.default_layout)
  }

  // Client sends DELETE request with old version "v1"
  let req =
    testing.inertia_delete("/")
    |> simulate.header("x-inertia-version", "v1")

  let response = versioned_handler(req)

  // Should return normal 200 response, NOT 409
  assert 200 == response.status
  assert Ok("Home") == testing.component(response)
}
