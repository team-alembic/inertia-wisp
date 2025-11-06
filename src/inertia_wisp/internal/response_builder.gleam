//// Response builder API v2 for creating Inertia.js responses with generic props.
////
//// This module provides a type-safe, fluent API for building Inertia responses
//// using record-based props with generic type parameter for complete type safety.

import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/http/request
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import inertia_wisp/internal/middleware
import inertia_wisp/internal/prop_behavior.{
  type MergeOptions, type PropBehavior, DeferBehavior,
}
import inertia_wisp/internal/props
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
      store_errors_in_cookie(redirect_response, builder.request, builder.errors)
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
pub fn response(builder: InertiaResponseBuilder(props), status: Int) -> Response {
  // Resolve which errors to use (from builder or cookie)
  let #(errors_to_use, retrieved_from_cookie) =
    resolve_errors_for_response(builder)

  // Check for partial reload
  let partial_component = get_partial_component(builder.request)
  let partial_data = case partial_component {
    option.Some(component) if component == builder.component ->
      option.Some(get_partial_data(builder.request))
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
    collect_deferred_props(builder.prop_behaviors, partial_data)

  let url = build_url_from_request(builder.request)
  let version_string = option.unwrap(builder.version, "1")

  // Step 5: Build response JSON with metadata
  let base_response = [
    #("component", json.string(builder.component)),
    #("props", props_json),
    #("url", json.string(url)),
    #("version", json.string(version_string)),
    #("encryptHistory", json.bool(builder.encrypt_history)),
    #("clearHistory", json.bool(builder.clear_history)),
  ]

  let with_deferred = add_deferred_props_metadata(base_response, deferred_props)
  let with_merge = add_merge_metadata(with_deferred, builder.merge_metadata)

  let response_json = json.object(with_merge)

  // Choose response format based on request type
  let final_response = case middleware.is_inertia_request(builder.request) {
    True -> build_json_response(response_json, status)
    False -> build_html_response(response_json, builder.component, status)
  }

  // Clear cookie if we retrieved errors from it (unless redirect/409 status)
  handle_cookie_cleanup(
    final_response,
    builder.request,
    retrieved_from_cookie,
    status,
  )
}

/// Build JSON response for Inertia XHR requests
fn build_json_response(response_json: json.Json, status: Int) -> Response {
  json.to_string(response_json)
  |> wisp.json_response(status)
  |> middleware.add_inertia_headers()
}

/// Build HTML response for initial page loads
fn build_html_response(
  response_json: json.Json,
  component_name: String,
  status: Int,
) -> Response {
  let json_string = json.to_string(response_json)
  let escaped_json = escape_html(json_string)

  let html_content = "<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>" <> component_name <> "</title>
    <link rel=\"stylesheet\" href=\"/static/css/styles.css\">
</head>
<body>
    <div id=\"app\" data-page=\"" <> escaped_json <> "\"></div>
    <script type=\"module\" src=\"/static/js/main.js\"></script>
</body>
</html>"

  wisp.html_response(html_content, status)
}

/// Escape HTML characters for safe insertion into attributes
fn escape_html(text: String) -> String {
  text
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
  |> string.replace("\"", "&quot;")
  |> string.replace("'", "&#x27;")
}

// Helper functions

/// Get partial component from request headers
fn get_partial_component(req: Request) -> Option(String) {
  case request.get_header(req, "x-inertia-partial-component") {
    Ok(component) -> option.Some(component)
    _ -> option.None
  }
}

/// Get partial data (requested prop names) from request headers
fn get_partial_data(req: Request) -> List(String) {
  case request.get_header(req, "x-inertia-partial-data") {
    Ok(data) -> string.split(data, ",") |> list.map(string.trim)
    _ -> []
  }
}

/// Collect deferred props grouped by group name
fn collect_deferred_props(
  behaviors: Dict(String, PropBehavior(props)),
  partial_data: Option(List(String)),
) -> Dict(String, List(String)) {
  behaviors
  |> dict.filter(fn(_name, behavior) {
    case behavior {
      DeferBehavior(_, _) -> {
        // Only advertise deferred props on initial page loads (no partial reload)
        // On partial reloads, deferred props are not advertised again
        case partial_data {
          option.Some(_) -> False
          option.None -> True
        }
      }
      _ -> False
    }
  })
  |> dict.fold(dict.new(), fn(acc, name, behavior) {
    case behavior {
      DeferBehavior(group, _) -> {
        let group_name = option.unwrap(group, "default")
        let current_props = dict.get(acc, group_name) |> result.unwrap([])
        dict.insert(acc, group_name, [name, ..current_props])
      }
      _ -> acc
    }
  })
}

/// Add deferred props metadata to response JSON
fn add_deferred_props_metadata(
  response: List(#(String, json.Json)),
  deferred_props: Dict(String, List(String)),
) -> List(#(String, json.Json)) {
  case dict.is_empty(deferred_props) {
    True -> response
    False -> {
      let deferred_json =
        deferred_props
        |> dict.to_list()
        |> list.map(fn(pair) {
          #(pair.0, json.array(list.reverse(pair.1), json.string))
        })
        |> json.object()
      [#("deferredProps", deferred_json), ..response]
    }
  }
}

/// Add merge metadata to response JSON
fn add_merge_metadata(
  response: List(#(String, json.Json)),
  merge_metadata: Dict(String, MergeOptions),
) -> List(#(String, json.Json)) {
  case dict.is_empty(merge_metadata) {
    True -> response
    False -> {
      // Collect merge props (non-deep merge)
      let merge_props =
        merge_metadata
        |> dict.filter(fn(_name, opts) { !opts.deep })
        |> dict.keys()

      // Collect deep merge props
      let deep_merge_props =
        merge_metadata
        |> dict.filter(fn(_name, opts) { opts.deep })
        |> dict.keys()

      // Collect match_on rules
      let match_props_on =
        merge_metadata
        |> dict.to_list()
        |> list.flat_map(fn(pair) {
          let #(name, opts) = pair
          case opts.match_on {
            option.Some(keys) -> list.map(keys, fn(key) { name <> "." <> key })
            option.None -> []
          }
        })

      let with_merge = case merge_props {
        [] -> response
        _ -> [
          #("mergeProps", json.array(list.reverse(merge_props), json.string)),
          ..response
        ]
      }

      let with_deep_merge = case deep_merge_props {
        [] -> with_merge
        _ -> [
          #(
            "deepMergeProps",
            json.array(list.reverse(deep_merge_props), json.string),
          ),
          ..with_merge
        ]
      }

      case match_props_on {
        [] -> with_deep_merge
        _ -> [
          #(
            "matchPropsOn",
            json.array(list.reverse(match_props_on), json.string),
          ),
          ..with_deep_merge
        ]
      }
    }
  }
}

fn build_url_from_request(req: Request) -> String {
  let path = wisp.path_segments(req) |> string.join("/")
  let base_url = "/" <> path

  case req.query {
    option.Some(query) if query != "" -> base_url <> "?" <> query
    _ -> base_url
  }
}

/// Resolve which errors to use and whether they came from cookie
fn resolve_errors_for_response(
  builder: InertiaResponseBuilder(props),
) -> #(Dict(String, String), Bool) {
  case dict.is_empty(builder.errors) {
    False -> #(builder.errors, False)
    // Use builder errors
    True -> {
      case retrieve_errors_from_cookie(builder.request) {
        option.Some(errors) -> #(errors, True)
        // Cookie was present
        option.None -> #(dict.new(), False)
        // No cookie present
      }
    }
  }
}

/// Retrieve validation errors from cookie
/// Returns Some(errors_dict) if cookie was present, None if no cookie
fn retrieve_errors_from_cookie(
  request: Request,
) -> option.Option(Dict(String, String)) {
  case wisp.get_cookie(request, "inertia_errors", wisp.Signed) {
    Ok(errors_json) -> {
      case
        json.parse(
          from: errors_json,
          using: decode.dict(decode.string, decode.string),
        )
      {
        Ok(errors) -> option.Some(errors)
        Error(_) -> option.Some(dict.new())
        // Cookie was present but malformed
      }
    }
    Error(_) -> option.None
    // No cookie present
  }
}

/// Handle cookie cleanup after response is built
fn handle_cookie_cleanup(
  response: Response,
  request: Request,
  retrieved_from_cookie: Bool,
  status: Int,
) -> Response {
  case retrieved_from_cookie && !is_redirect_or_conflict_status(status) {
    True -> clear_errors_cookie(response, request)
    False -> response
  }
}

/// Check if status code is a redirect (301-308) or conflict (409)
fn is_redirect_or_conflict_status(status: Int) -> Bool {
  status >= 301 && status <= 308 || status == 409
}

/// Clear the inertia_errors cookie by setting it to expire immediately
fn clear_errors_cookie(response: Response, request: Request) -> Response {
  wisp.set_cookie(
    response,
    request,
    "inertia_errors",
    "",
    wisp.Signed,
    0,
    // Expire immediately
  )
}

/// Store validation errors in a cookie for later retrieval
fn store_errors_in_cookie(
  response: Response,
  request: Request,
  errors: Dict(String, String),
) -> Response {
  let errors_json =
    errors
    |> dict.to_list()
    |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })
    |> json.object()
    |> json.to_string()

  wisp.set_cookie(
    response,
    request,
    "inertia_errors",
    errors_json,
    wisp.Signed,
    600,
    // 10 minutes
  )
}
