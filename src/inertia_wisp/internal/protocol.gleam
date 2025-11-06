//// Inertia.js protocol implementation for HTTP requests and responses.
////
//// This module handles the low-level Inertia protocol details including:
//// - Reading Inertia-specific request headers
//// - Setting Inertia-specific response headers
//// - Managing error cookies for Post/Redirect/Get pattern
//// - Building URLs from requests

import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/http/request
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import inertia_wisp/internal/prop_behavior.{
  type MergeOptions, type PropBehavior, DeferBehavior,
}
import wisp.{type Request, type Response}

// Request header parsing

/// Check if current request is an Inertia request
pub fn is_inertia_request(req: Request) -> Bool {
  case request.get_header(req, "x-inertia") {
    Ok("true") -> True
    _ -> False
  }
}

/// Get partial data keys from request headers
pub fn partial_data(req: Request) -> List(String) {
  case request.get_header(req, "x-inertia-partial-data") {
    Ok(data) -> string.split(data, ",") |> list.map(string.trim)
    _ -> []
  }
}

/// Get partial component from request headers
pub fn partial_component(req: Request) -> Option(String) {
  case request.get_header(req, "x-inertia-partial-component") {
    Ok(component) -> option.Some(component)
    _ -> option.None
  }
}

/// Build URL string from request path and query
pub fn url_from_request(req: Request) -> String {
  let path = wisp.path_segments(req) |> string.join("/")
  let base_url = "/" <> path

  case req.query {
    option.Some(query) if query != "" -> base_url <> "?" <> query
    _ -> base_url
  }
}

// Response headers

/// Add required Inertia headers to response
pub fn add_inertia_headers(response: Response) -> Response {
  response
  |> wisp.set_header("x-inertia", "true")
  |> wisp.set_header("vary", "X-Inertia")
}

// Error cookie management for Post/Redirect/Get pattern

/// Store validation errors in a cookie for later retrieval
pub fn store_errors(
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

/// Retrieve validation errors from cookie
/// Returns Some(errors_dict) if cookie was present, None if no cookie
pub fn retrieve_errors(request: Request) -> Option(Dict(String, String)) {
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

/// Clear the inertia_errors cookie by setting it to expire immediately
pub fn clear_errors(response: Response, request: Request) -> Response {
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

/// Check if status code is a redirect (301-308) or conflict (409)
pub fn is_redirect_or_conflict(status: Int) -> Bool {
  status >= 301 && status <= 308 || status == 409
}

// Response JSON metadata generation

/// Collect deferred props grouped by group name
///
/// Only advertises deferred props on initial page loads, not on partial reloads.
pub fn collect_deferred_props(
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
///
/// Adds the "deferredProps" field containing grouped deferred prop names.
pub fn add_deferred_metadata(
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
///
/// Adds "mergeProps", "deepMergeProps", and "matchPropsOn" fields for client-side merging.
pub fn add_merge_metadata(
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
