//// Inertia.js adapter for the Gleam Wisp web framework.
////
//// This module provides a type-safe API for building Inertia.js responses.
////
//// ## Quick Example
////
//// ```gleam
//// type UserProps {
////   UserProps(name: String, email: String, posts: Option(List(Post)))
//// }
////
//// fn show_user(req: Request, user_id: Int) -> Response {
////   let props = UserProps(
////     name: "Alice",
////     email: "alice@example.com",
////     posts: None,
////   )
////
////   req
////   |> inertia.response_builder("Users/Show")
////   |> inertia.props(props, encode_user_props)
////   |> inertia.lazy("posts", fn(props) {
////       Ok(UserProps(..props, posts: Some(load_posts(user_id))))
////     })
////   |> inertia.response(200)
//// }
//// ```
////
//// ## Prop Behaviors
////
//// - **Default**: Included on standard visits, available on partial reloads
//// - **Lazy**: Evaluated only when needed (not in partial reloads unless requested)
//// - **Optional**: Excluded by default, included only when explicitly requested
//// - **Always**: Always included, even on partial reloads
//// - **Defer**: Loaded in a separate request after initial page render
//// - **Merge**: Client-side merging for efficient data updates

import gleam/dict
import gleam/json
import gleam/option.{type Option}
import inertia_wisp/internal/prop_behavior
import inertia_wisp/internal/response_builder
import wisp.{type Request, type Response}

pub type InertiaResponseBuilder(props) =
  response_builder.InertiaResponseBuilder(props)

/// Options for merge prop behavior, controlling how data is merged on the client.
pub type MergeOptions =
  prop_behavior.MergeOptions

/// Create a new Inertia response builder.
///
/// This initializes the builder with no props (type parameter is `Nil`).
/// Call `props()` to set the actual props and change the type parameter.
///
/// ## Example
///
/// ```gleam
/// req
/// |> inertia.response_builder("Dashboard")
/// |> inertia.props(dashboard_props, encode_dashboard_props)
/// |> inertia.response(200)
/// ```
pub fn response_builder(
  req: Request,
  component: String,
) -> InertiaResponseBuilder(Nil) {
  response_builder.response_builder(req, component)
}

/// Set the props data and encoder for this response.
///
/// This changes the type parameter from `_` (typically `Nil`) to your specific
/// props type, enabling type-safe configuration of prop behaviors.
///
/// The encoder function should return a `Dict(String, Json)` containing all
/// fields that should be sent to the frontend.
///
/// ## Example
///
/// ```gleam
/// fn encode_user_props(props: UserProps) -> Dict(String, Json) {
///   dict.from_list([
///     #("name", json.string(props.name)),
///     #("email", json.string(props.email)),
///   ])
/// }
/// ```
pub fn props(
  builder: InertiaResponseBuilder(_),
  props: props,
  encode: fn(props) -> dict.Dict(String, json.Json),
) -> InertiaResponseBuilder(props) {
  response_builder.props(builder, props, encode)
}

/// Configure a prop to be lazy-evaluated.
///
/// Lazy props are only evaluated when explicitly requested in a partial reload.
/// The resolver receives the current props and returns updated props.
///
/// ## Example
///
/// ```gleam
/// |> inertia.lazy("comments", fn(props) {
///   Ok(BlogPostProps(..props, comments: Some(load_comments())))
/// })
/// ```
pub fn lazy(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  resolver: fn(props) -> Result(props, dict.Dict(String, String)),
) -> InertiaResponseBuilder(props) {
  response_builder.lazy(builder, field_name, resolver)
}

/// Configure a prop to be optional (excluded by default).
///
/// Optional props are only included when explicitly requested in a partial reload.
/// Useful for expensive data that's rarely needed.
pub fn optional(
  builder: InertiaResponseBuilder(props),
  field_name: String,
) -> InertiaResponseBuilder(props) {
  response_builder.optional(builder, field_name)
}

/// Configure a prop to always be included, even in partial reloads.
///
/// Always props are included in every request, regardless of what fields
/// are requested in a partial reload. Useful for shared data like auth user.
///
/// ## Example
///
/// ```gleam
/// |> inertia.always("auth")  // Always send current user
/// ```
pub fn always(
  builder: InertiaResponseBuilder(props),
  field_name: String,
) -> InertiaResponseBuilder(props) {
  response_builder.always(builder, field_name)
}

/// Configure a prop to be deferred (loaded after initial page render).
///
/// Deferred props are advertised in the initial response metadata, and the
/// frontend automatically requests them in a subsequent request. Perfect for
/// expensive operations that shouldn't block initial page load.
///
/// ## Example
///
/// ```gleam
/// |> inertia.defer("analytics", fn(props) {
///   process.sleep(2000)  // Expensive operation
///   Ok(DashboardProps(..props, analytics: Some(generate_report())))
/// })
/// ```
pub fn defer(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  resolver: fn(props) -> Result(props, dict.Dict(String, String)),
) -> InertiaResponseBuilder(props) {
  response_builder.defer(builder, field_name, resolver)
}

/// Configure a deferred prop with a specific group name.
///
/// Grouped deferred props can be loaded together in a single request,
/// reducing the number of round trips to the server.
pub fn defer_in_group(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  group: String,
  resolver: fn(props) -> Result(props, dict.Dict(String, String)),
) -> InertiaResponseBuilder(props) {
  response_builder.defer_in_group(builder, field_name, group, resolver)
}

/// Configure a prop to use client-side merging behavior.
///
/// Merge props enable efficient data updates on the frontend, useful for
/// pagination, infinite scroll, or updating lists without replacing them.
///
/// ## Parameters
///
/// - `match_on`: Optional list of keys to match items by (e.g., `Some(["id"])`)
/// - `deep`: Whether to perform deep merging of nested objects
///
/// ## Example
///
/// ```gleam
/// |> inertia.merge("users", match_on: Some(["id"]), deep: False)
/// ```
pub fn merge(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  match_on match_on: Option(List(String)),
  deep deep: Bool,
) -> InertiaResponseBuilder(props) {
  response_builder.merge(builder, field_name, match_on, deep)
}

/// Add validation errors to the response.
///
/// Errors are automatically included in the props sent to the frontend and
/// stored in a signed cookie during redirects to support the Post/Redirect/Get pattern.
///
/// ## Example
///
/// ```gleam
/// case validate(form_data) {
///   Error(errors) -> {
///     req
///     |> inertia.response_builder("ContactForm")
///     |> inertia.errors(errors)
///     |> inertia.redirect("/contact")
///   }
/// }
/// ```
pub fn errors(
  builder: InertiaResponseBuilder(props),
  errors: dict.Dict(String, String),
) -> InertiaResponseBuilder(props) {
  response_builder.errors(builder, errors)
}

/// Create a redirect response (303 See Other).
///
/// If errors are present in the builder, they will be stored in a signed
/// cookie and automatically retrieved on the next request.
///
/// ## Example
///
/// ```gleam
/// req
/// |> inertia.response_builder("Users/Create")
/// |> inertia.redirect("/users")
/// ```
pub fn redirect(builder: InertiaResponseBuilder(props), url: String) -> Response {
  response_builder.redirect(builder, url)
}

/// Clear the browser history state after this response.
///
/// Useful for preventing authenticated responses from being seen after logout.
pub fn clear_history(
  builder: InertiaResponseBuilder(props),
) -> InertiaResponseBuilder(props) {
  response_builder.clear_history(builder)
}

/// Encrypt the history entry for this page.
///
/// Use this for authenticated responses.
pub fn encrypt_history(
  builder: InertiaResponseBuilder(props),
) -> InertiaResponseBuilder(props) {
  response_builder.encrypt_history(builder)
}

/// Set an asset version for cache busting.
///
/// When the version changes, Inertia will automatically force a full page
/// reload to ensure users get the latest assets.
///
/// ## Example
///
/// ```gleam
/// |> inertia.version("abc123")
/// ```
pub fn version(
  builder: InertiaResponseBuilder(props),
  version: String,
) -> InertiaResponseBuilder(props) {
  response_builder.version(builder, version)
}

/// Build the final HTTP response with the given status code.
///
/// This evaluates all prop resolvers, applies filtering based on the request
/// type, and generates either a JSON response (for Inertia requests) or an
/// HTML response with embedded JSON (for initial page loads).
///
/// ## Example
///
/// ```gleam
/// |> inertia.response(200)  // OK
/// |> inertia.response(201)  // Created
/// ```
pub fn response(builder: InertiaResponseBuilder(props), status: Int) -> Response {
  response_builder.response(builder, status)
}
