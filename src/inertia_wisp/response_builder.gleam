//// Response builder API for creating Inertia.js responses.
////
//// This module provides a fluent, composable API for building Inertia responses
//// that addresses limitations of the eval-based approach, including better error
//// handling, metadata control, and the ability to create error-only responses.
//// proper form processing with validation errors in Inertia.js.

import gleam/dict.{type Dict}

import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import gleam/string_tree

import inertia_wisp/internal/middleware
import inertia_wisp/internal/types
import wisp.{type Request, type Response}

/// Result of processing a single prop
type PropEval {
  Evaluated(name: String, value: json.Json, merge_opts: MergeOpts)
  Deferred(name: String, group: String)
  PropError(name: String, errors: Dict(String, String))
}

/// Merge options for props
type MergeOpts {
  NoMerge
  Merge(match_on: option.Option(List(String)), deep: Bool)
}

/// Builder for constructing Inertia responses step by step
pub opaque type InertiaResponseBuilder {
  InertiaResponseBuilder(
    request: Request,
    component: Option(String),
    props: Dict(String, json.Json),
    errors: Dict(String, String),
    redirect_url: Option(String),
    clear_history: Bool,
    encrypt_history: Bool,
    version: Option(String),
    deferred_props: Dict(String, List(String)),
    merge_props: List(String),
    deep_merge_props: List(String),
    match_props_on: List(String),
    error_component: Option(String),
    status: Option(Int),
  )
}

/// Start building an Inertia response
pub fn response_builder(
  req: Request,
  component_name: String,
) -> InertiaResponseBuilder {
  InertiaResponseBuilder(
    request: req,
    component: option.Some(component_name),
    props: dict.new(),
    errors: dict.new(),
    redirect_url: option.None,
    clear_history: False,
    encrypt_history: False,
    version: option.None,
    deferred_props: dict.new(),
    merge_props: [],
    deep_merge_props: [],
    match_props_on: [],
    error_component: option.None,
    status: option.None,
  )
}

/// Set the component name for the response (deprecated - use response_builder with component_name)
pub fn component(
  builder: InertiaResponseBuilder,
  name: String,
) -> InertiaResponseBuilder {
  InertiaResponseBuilder(..builder, component: option.Some(name))
}

/// Add props to the response (handles evaluation and JSON encoding internally)
pub fn props(
  builder: InertiaResponseBuilder,
  props: List(types.Prop(p)),
  encode_prop: fn(p) -> json.Json,
) -> InertiaResponseBuilder {
  // Check for partial reload headers and validate component match
  let partial_component = middleware.get_partial_component(builder.request)

  // For partial reloads, only proceed if component matches
  let partial_data = case builder.component {
    option.Some(component_name)
      if option.Some(component_name) == partial_component
    -> {
      let requested_props = middleware.get_partial_data(builder.request)
      option.Some(requested_props)
    }
    _ -> option.None
  }

  // Filter props based on partial reload logic
  let filtered_props = filter_props_for_request(props, partial_data)

  let #(
    evaluated_props,
    deferred_props,
    merge_props,
    deep_merge_props,
    match_props_on,
    prop_errors,
  ) = process_props(filtered_props, encode_prop, partial_data)

  let combined_props = dict.merge(builder.props, evaluated_props)
  let combined_deferred = dict.merge(builder.deferred_props, deferred_props)
  let combined_merge = list.append(builder.merge_props, merge_props)
  let combined_deep_merge =
    list.append(builder.deep_merge_props, deep_merge_props)
  let combined_match_on = list.append(builder.match_props_on, match_props_on)
  let combined_errors = dict.merge(builder.errors, prop_errors)

  InertiaResponseBuilder(
    ..builder,
    props: combined_props,
    deferred_props: combined_deferred,
    merge_props: combined_merge,
    deep_merge_props: combined_deep_merge,
    match_props_on: combined_match_on,
    errors: combined_errors,
  )
}

/// Set validation errors for the response
pub fn errors(
  builder: InertiaResponseBuilder,
  errors: Dict(String, String),
) -> InertiaResponseBuilder {
  InertiaResponseBuilder(..builder, errors: errors)
}

/// Set redirect URL for error responses
pub fn redirect(
  builder: InertiaResponseBuilder,
  url: String,
) -> InertiaResponseBuilder {
  InertiaResponseBuilder(..builder, redirect_url: option.Some(url))
}

/// Set error component for prop resolution errors
pub fn on_error(
  builder: InertiaResponseBuilder,
  error_component: String,
) -> InertiaResponseBuilder {
  InertiaResponseBuilder(
    ..builder,
    error_component: option.Some(error_component),
  )
}

/// Clear browser history for this response
pub fn clear_history(builder: InertiaResponseBuilder) -> InertiaResponseBuilder {
  InertiaResponseBuilder(..builder, clear_history: True)
}

/// Encrypt browser history for this response
pub fn encrypt_history(
  builder: InertiaResponseBuilder,
) -> InertiaResponseBuilder {
  InertiaResponseBuilder(..builder, encrypt_history: True)
}

/// Set version for this response
pub fn version(
  builder: InertiaResponseBuilder,
  version: String,
) -> InertiaResponseBuilder {
  InertiaResponseBuilder(..builder, version: option.Some(version))
}

/// Helper function to resolve Result-based prop resolvers
fn resolve_prop_result(
  name: String,
  resolver: fn() -> Result(p, Dict(String, String)),
  encode_prop: fn(p) -> json.Json,
) -> PropEval {
  case resolver() {
    Ok(value) -> {
      let json_value = encode_prop(value)
      Evaluated(name, json_value, NoMerge)
    }
    Error(error_dict) -> {
      PropError(name, error_dict)
    }
  }
}

/// Build the final Inertia response with optional status code
pub fn response(builder: InertiaResponseBuilder, status: Int) -> Response {
  let component_name = case builder.component {
    option.Some(name) -> name
    option.None -> ""
  }

  let url = build_url_from_request(builder.request)

  let version = case builder.version {
    option.Some(v) -> v
    option.None -> "1"
  }

  let props_with_errors = case dict.is_empty(builder.errors) {
    False -> {
      let errors_json =
        builder.errors
        |> dict.to_list()
        |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })
        |> json.object()
      dict.insert(builder.props, "errors", errors_json)
    }
    True -> builder.props
  }

  let base_json = [
    #("component", json.string(component_name)),
    #("props", json.object(dict.to_list(props_with_errors))),
    #("url", json.string(url)),
    #("version", json.string(version)),
    #("encryptHistory", json.bool(builder.encrypt_history)),
    #("clearHistory", json.bool(builder.clear_history)),
  ]

  // Add optional fields if they have content
  let final_json =
    base_json
    |> maybe_add_deferred_props(builder.deferred_props)
    |> maybe_add_merge_props(builder.merge_props)
    |> maybe_add_deep_merge_props(builder.deep_merge_props)
    |> maybe_add_match_props_on(builder.match_props_on)

  case middleware.is_inertia_request(builder.request) {
    True -> build_json_response(final_json, status)
    False -> build_html_response(final_json, component_name, status)
  }
}

/// Build JSON response for Inertia requests
fn build_json_response(final_json: List(#(String, json.Json)), status: Int) -> Response {
  let json_body = json.object(final_json) |> json.to_string()

  json_body
  |> string_tree.from_string()
  |> wisp.json_response(status)
  |> middleware.add_inertia_headers()
}

/// Build HTML response for initial page loads with embedded JSON data
fn build_html_response(
  final_json: List(#(String, json.Json)),
  component_name: String,
  status: Int,
) -> Response {
  let json_string = json.object(final_json) |> json.to_string()
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

  wisp.html_response(string_tree.from_string(html_content), status)
}

/// Process props and separate them into evaluated props, deferred props, and merge metadata
fn process_props(
  props: List(types.Prop(p)),
  encode_prop: fn(p) -> json.Json,
  partial_data: option.Option(List(String)),
) -> #(
  Dict(String, json.Json),
  Dict(String, List(String)),
  List(String),
  List(String),
  List(String),
  Dict(String, String),
) {
  let #(
    evaluated,
    deferred_groups,
    merge_props,
    deep_merge_props,
    match_props_on,
    prop_errors,
  ) =
    props
    |> list.fold(
      #(dict.new(), dict.new(), [], [], [], dict.new()),
      fn(acc, prop) {
        let #(
          eval_acc,
          defer_acc,
          merge_acc,
          deep_merge_acc,
          match_acc,
          error_acc,
        ) = acc
        let prop_eval = process_single_prop(prop, encode_prop, partial_data)

        case prop_eval {
          Evaluated(name, value, merge_opts) -> {
            let new_eval_acc = dict.insert(eval_acc, name, value)
            case merge_opts {
              NoMerge -> #(
                new_eval_acc,
                defer_acc,
                merge_acc,
                deep_merge_acc,
                match_acc,
                error_acc,
              )
              Merge(match_on, deep) -> {
                let new_merge_acc = case deep {
                  False -> [name, ..merge_acc]
                  True -> merge_acc
                }
                let new_deep_merge_acc = case deep {
                  True -> [name, ..deep_merge_acc]
                  False -> deep_merge_acc
                }
                let new_match_acc = case match_on {
                  option.Some(match_keys) -> {
                    let match_entries =
                      list.map(match_keys, fn(key) { name <> "." <> key })
                    list.append(match_entries, match_acc)
                  }
                  option.None -> match_acc
                }
                #(
                  new_eval_acc,
                  defer_acc,
                  new_merge_acc,
                  new_deep_merge_acc,
                  new_match_acc,
                  error_acc,
                )
              }
            }
          }
          Deferred(name, group) -> {
            let current_props = dict.get(defer_acc, group) |> result.unwrap([])
            let updated_props = [name, ..current_props]
            let new_defer_acc = dict.insert(defer_acc, group, updated_props)
            #(
              eval_acc,
              new_defer_acc,
              merge_acc,
              deep_merge_acc,
              match_acc,
              error_acc,
            )
          }
          PropError(_name, error_dict) -> {
            let new_error_acc = dict.merge(error_acc, error_dict)
            #(
              eval_acc,
              defer_acc,
              merge_acc,
              deep_merge_acc,
              match_acc,
              new_error_acc,
            )
          }
        }
      },
    )

  #(
    evaluated,
    deferred_groups,
    merge_props,
    deep_merge_props,
    match_props_on,
    prop_errors,
  )
}

/// Process a single prop and return its evaluation result
fn process_single_prop(
  prop: types.Prop(p),
  encode_prop: fn(p) -> json.Json,
  partial_data: option.Option(List(String)),
) -> PropEval {
  case prop {
    // Regular props - evaluate immediately
    types.DefaultProp(name, value) -> {
      let json_value = encode_prop(value)
      Evaluated(name, json_value, NoMerge)
    }
    types.LazyProp(name, resolver) ->
      resolve_prop_result(name, resolver, encode_prop)
    types.OptionalProp(name, resolver) ->
      resolve_prop_result(name, resolver, encode_prop)
    types.AlwaysProp(name, value) -> {
      let json_value = encode_prop(value)
      Evaluated(name, json_value, NoMerge)
    }

    // Deferred props - evaluate if requested in partial reload, otherwise just track names
    types.DeferProp(name, group, resolver) -> {
      let group_name = option.unwrap(group, "default")
      case partial_data {
        option.Some(requested_props) -> {
          case list.contains(requested_props, name) {
            True -> {
              // This deferred prop was requested in partial reload, so evaluate it
              resolve_prop_result(name, resolver, encode_prop)
            }
            False -> {
              // This deferred prop was not requested, so track it for later
              Deferred(name, group_name)
            }
          }
        }
        option.None -> {
          // Not a partial reload, so track it for later
          Deferred(name, group_name)
        }
      }
    }

    // Merge props - process inner prop and add merge metadata
    types.MergeProp(inner_prop, match_on, deep) -> {
      let inner_eval =
        process_single_prop(inner_prop, encode_prop, partial_data)
      case inner_eval {
        Evaluated(name, value, _) -> {
          Evaluated(name, value, Merge(match_on, deep))
        }
        Deferred(name, group) -> {
          Deferred(name, group)
        }
        PropError(name, errors) -> {
          PropError(name, errors)
        }
      }
    }
  }
}

/// Filter props based on request type and partial reload settings
fn filter_props_for_request(
  props: List(types.Prop(p)),
  partial_data: option.Option(List(String)),
) -> List(types.Prop(p)) {
  case partial_data {
    option.None -> props |> list.filter(is_non_partial_prop)
    option.Some(requested_props) ->
      props |> list.filter(is_partial_prop(_, requested_props))
  }
}

/// Predicate for non-partial requests (initial page load and standard Inertia)
/// Include all non-optional props
/// OptionalProp: Excluded because they're only meant for partial reloads when explicitly requested
/// DeferProp: Retained here so process_props can move them to the deferred_props list
fn is_non_partial_prop(prop: types.Prop(p)) -> Bool {
  case prop {
    types.OptionalProp(_, _) -> False
    types.MergeProp(inner_prop, _, _) -> is_non_partial_prop(inner_prop)
    _ -> True
  }
}

/// Predicate for partial reload requests
/// Include only requested props plus always props
fn is_partial_prop(prop: types.Prop(p), partial_data: List(String)) -> Bool {
  case prop {
    types.AlwaysProp(_, _) -> True
    types.MergeProp(inner_prop, _, _) ->
      is_partial_prop(inner_prop, partial_data)
    types.DefaultProp(name, _) -> list.contains(partial_data, name)
    types.LazyProp(name, _) -> list.contains(partial_data, name)
    types.OptionalProp(name, _) -> list.contains(partial_data, name)
    types.DeferProp(name, _, _) -> list.contains(partial_data, name)
  }
}

/// Build URL from request path segments
fn build_url_from_request(req: Request) -> String {
  let path = wisp.path_segments(req) |> string.join("/")
  let base_url = "/" <> path

  case req.query {
    option.Some(query) if query != "" -> base_url <> "?" <> query
    _ -> base_url
  }
}

/// Add deferred props to JSON if not empty
fn maybe_add_deferred_props(
  json_list: List(#(String, json.Json)),
  deferred_props: Dict(String, List(String)),
) -> List(#(String, json.Json)) {
  case dict.is_empty(deferred_props) {
    True -> json_list
    False -> {
      let deferred_json =
        deferred_props
        |> dict.to_list()
        |> list.map(fn(pair) {
          #(pair.0, json.array(list.reverse(pair.1), json.string))
        })
        |> json.object()
      [#("deferredProps", deferred_json), ..json_list]
    }
  }
}

/// Add merge props to JSON if not empty
fn maybe_add_merge_props(
  json_list: List(#(String, json.Json)),
  merge_props: List(String),
) -> List(#(String, json.Json)) {
  case merge_props {
    [] -> json_list
    _ -> [
      #("mergeProps", json.array(list.reverse(merge_props), json.string)),
      ..json_list
    ]
  }
}

/// Add deep merge props to JSON if not empty
fn maybe_add_deep_merge_props(
  json_list: List(#(String, json.Json)),
  deep_merge_props: List(String),
) -> List(#(String, json.Json)) {
  case deep_merge_props {
    [] -> json_list
    _ -> [
      #(
        "deepMergeProps",
        json.array(list.reverse(deep_merge_props), json.string),
      ),
      ..json_list
    ]
  }
}

/// Escape HTML entities in JSON string for embedding in HTML
fn escape_html(text: String) -> String {
  text
  |> string.replace("&", "&amp;")
  |> string.replace("\"", "&quot;")
  |> string.replace("'", "&#x27;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
}

/// Add match props on to JSON if not empty
fn maybe_add_match_props_on(
  json_list: List(#(String, json.Json)),
  match_props_on: List(String),
) -> List(#(String, json.Json)) {
  case match_props_on {
    [] -> json_list
    _ -> [
      #("matchPropsOn", json.array(list.reverse(match_props_on), json.string)),
      ..json_list
    ]
  }
}
