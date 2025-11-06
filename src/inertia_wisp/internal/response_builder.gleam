//// Response builder API v2 for creating Inertia.js responses with generic props.
////
//// This module provides a type-safe, fluent API for building Inertia responses
//// using record-based props with generic type parameter for complete type safety.

import gleam/dict.{type Dict}
import gleam/json
import gleam/list
import gleam/option.{type Option}
import inertia_wisp/internal/prop_behavior.{type MergeOptions, type PropBehavior}
import inertia_wisp/internal/props
import inertia_wisp/internal/protocol
import inertia_wisp/internal/render
import wisp.{type Request, type Response}

/// Generic builder for constructing Inertia responses
/// Type parameter ensures all operations work with the same props type
pub opaque type InertiaResponseBuilder(props) {
  InertiaResponseBuilder(
    request: Request,
    component: String,
    prop_data: props,
    json_encoder: fn(props) -> Dict(String, json.Json),
    prop_behaviors: Dict(String, PropBehavior(props)),
    merge_metadata: Dict(String, MergeOptions),
    errors: Dict(String, String),
    redirect_url: Option(String),
    clear_history: Bool,
    encrypt_history: Bool,
    version: Option(String),
  )
}

/// Start building an Inertia response without props
/// Returns a builder with Nil type parameter that must be set via props()
pub fn response_builder(
  req: Request,
  component: String,
) -> InertiaResponseBuilder(Nil) {
  InertiaResponseBuilder(
    request: req,
    component: component,
    prop_data: Nil,
    json_encoder: fn(_) { dict.new() },
    prop_behaviors: dict.new(),
    merge_metadata: dict.new(),
    errors: dict.new(),
    redirect_url: option.None,
    clear_history: False,
    encrypt_history: False,
    version: option.None,
  )
}

/// Set the props for this response
/// Changes the type parameter from any type to the specific props type
pub fn props(
  builder: InertiaResponseBuilder(_),
  initial_props: props,
  encoder: fn(props) -> Dict(String, json.Json),
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(
    request: builder.request,
    component: builder.component,
    prop_data: initial_props,
    json_encoder: encoder,
    prop_behaviors: dict.new(),
    merge_metadata: dict.new(),
    errors: builder.errors,
    redirect_url: builder.redirect_url,
    clear_history: builder.clear_history,
    encrypt_history: builder.encrypt_history,
    version: builder.version,
  )
}

/// Configure a prop to be lazily evaluated
/// Resolver receives current props and returns updated props
pub fn lazy(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  resolver: fn(props) -> Result(props, Dict(String, String)),
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(
    ..builder,
    prop_behaviors: dict.insert(
      builder.prop_behaviors,
      field_name,
      prop_behavior.LazyBehavior(resolver),
    ),
  )
}

/// Mark a prop as optional - only included when explicitly requested in partial reloads
pub fn optional(
  builder: InertiaResponseBuilder(props),
  field_name: String,
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(
    ..builder,
    prop_behaviors: dict.insert(
      builder.prop_behaviors,
      field_name,
      prop_behavior.OptionalBehavior,
    ),
  )
}

/// Mark a prop as always included, even in partial reloads
pub fn always(
  builder: InertiaResponseBuilder(props),
  field_name: String,
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(
    ..builder,
    prop_behaviors: dict.insert(
      builder.prop_behaviors,
      field_name,
      prop_behavior.AlwaysBehavior,
    ),
  )
}

/// Configure a prop to be deferred - loaded in a separate request from the client
pub fn defer(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  resolver: fn(props) -> Result(props, Dict(String, String)),
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(
    ..builder,
    prop_behaviors: dict.insert(
      builder.prop_behaviors,
      field_name,
      prop_behavior.DeferBehavior(group: option.None, resolver: resolver),
    ),
  )
}

/// Configure a deferred prop with a specific group name
/// Allows fetching multiple deferred props in one request
pub fn defer_in_group(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  group: String,
  resolver: fn(props) -> Result(props, Dict(String, String)),
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(
    ..builder,
    prop_behaviors: dict.insert(
      builder.prop_behaviors,
      field_name,
      prop_behavior.DeferBehavior(group: option.Some(group), resolver: resolver),
    ),
  )
}

/// Configure client-side merging for a prop
pub fn merge(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  match_on match_on: Option(List(String)),
  deep deep: Bool,
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(
    ..builder,
    merge_metadata: dict.insert(
      builder.merge_metadata,
      field_name,
      prop_behavior.MergeOptions(match_on: match_on, deep: deep),
    ),
  )
}

/// Set validation errors for the response
pub fn errors(
  builder: InertiaResponseBuilder(props),
  errors: Dict(String, String),
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(..builder, errors: errors)
}

/// Set redirect URL and return redirect response immediately
pub fn redirect(builder: InertiaResponseBuilder(props), url: String) -> Response {
  // Create HTTP redirect response with 303 status (Inertia.js standard)
  let redirect_response =
    wisp.response(303)
    |> wisp.set_header("location", url)

  // Store errors in cookie if any exist
  case dict.is_empty(builder.errors) {
    False ->
      protocol.store_errors(redirect_response, builder.request, builder.errors)
    True -> redirect_response
  }
}

/// Clear browser history for this response
pub fn clear_history(
  builder: InertiaResponseBuilder(props),
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(..builder, clear_history: True)
}

/// Encrypt browser history for this response
pub fn encrypt_history(
  builder: InertiaResponseBuilder(props),
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(..builder, encrypt_history: True)
}

/// Set version for this response
pub fn version(
  builder: InertiaResponseBuilder(props),
  version: String,
) -> InertiaResponseBuilder(props) {
  InertiaResponseBuilder(..builder, version: option.Some(version))
}

/// Build the final Inertia response
pub fn response(
  builder: InertiaResponseBuilder(props),
  status: Int,
  layout: fn(String, json.Json) -> String,
) -> Response {
  // Resolve which errors to use (from builder or cookie)
  let #(errors_to_use, retrieved_from_cookie) =
    resolve_errors_for_response(builder)

  // Check for partial reload
  let partial_component = protocol.partial_component(builder.request)
  let partial_data = case partial_component {
    option.Some(component) if component == builder.component ->
      option.Some(protocol.partial_data(builder.request))
    _ -> option.None
  }

  // Step 1: Determine which props to include based on partial reload
  let props_to_include = props.to_include(builder.prop_behaviors, partial_data)

  // Step 2: Evaluate behaviors for the props that need evaluation
  let evaluated_props =
    props.resolve(builder.prop_data, builder.prop_behaviors, props_to_include)

  // Extract evaluation errors and merge with existing errors
  let #(final_props, all_errors) = case evaluated_props {
    Ok(props) -> #(props, errors_to_use)
    Error(eval_errors) -> {
      // Merge evaluation errors with existing errors
      // Precedence: builder/cookie errors override evaluation errors
      let merged_errors = dict.merge(eval_errors, errors_to_use)
      #(builder.prop_data, merged_errors)
    }
  }

  // Step 3: Encode props to Dict and filter based on behaviors
  let props_dict = builder.json_encoder(final_props)
  let filtered_props_dict =
    props.filter(props_dict, builder.prop_behaviors, partial_data)

  // Add errors to props
  let props_with_errors = case dict.is_empty(all_errors) {
    True -> filtered_props_dict
    False -> {
      let errors_json =
        all_errors
        |> dict.to_list()
        |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })
        |> json.object()
      dict.insert(filtered_props_dict, "errors", errors_json)
    }
  }

  let props_json = json.object(dict.to_list(props_with_errors))

  // Step 4: Collect deferred props metadata
  let deferred_props =
    protocol.collect_deferred_props(builder.prop_behaviors, partial_data)

  let url = protocol.url_from_request(builder.request)
  let version_string = option.unwrap(builder.version, "1")

  // Step 5: Build response JSON with metadata
  let response_json =
    [
      #("component", json.string(builder.component)),
      #("props", props_json),
      #("url", json.string(url)),
      #("version", json.string(version_string)),
      #("encryptHistory", json.bool(builder.encrypt_history)),
      #("clearHistory", json.bool(builder.clear_history)),
    ]
    |> protocol.add_deferred_metadata(deferred_props)
    |> protocol.add_merge_metadata(builder.merge_metadata)
    |> json.object()

  // Choose response format based on request type
  let final_response = case protocol.is_inertia_request(builder.request) {
    True -> render.json(response_json, status)
    False -> render.html(response_json, builder.component, status, layout)
  }

  // Clear cookie if we retrieved errors from it (unless redirect/409 status)
  handle_cookie_cleanup(
    final_response,
    builder.request,
    retrieved_from_cookie,
    status,
  )
}

// Helper functions

/// Resolve which errors to use and whether they came from cookie
fn resolve_errors_for_response(
  builder: InertiaResponseBuilder(props),
) -> #(Dict(String, String), Bool) {
  case dict.is_empty(builder.errors) {
    False -> #(builder.errors, False)
    // Use builder errors
    True -> {
      case protocol.retrieve_errors(builder.request) {
        option.Some(errors) -> #(errors, True)
        // Cookie was present
        option.None -> #(dict.new(), False)
        // No cookie present
      }
    }
  }
}

/// Handle cookie cleanup after response is built
fn handle_cookie_cleanup(
  response: Response,
  request: Request,
  retrieved_from_cookie: Bool,
  status: Int,
) -> Response {
  case retrieved_from_cookie && !protocol.is_redirect_or_conflict(status) {
    True -> protocol.clear_errors(response, request)
    False -> response
  }
}
