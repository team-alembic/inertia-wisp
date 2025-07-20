//// User search handler for the simple demo application.
////
//// This module handles search requests with advanced filtering capabilities.
//// Demonstrates OptionalProp usage and proper search functionality.

import data/users as data_users
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/uri
import inertia_wisp/inertia
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user search with advanced filters
pub fn handler(req: Request, db: Connection) -> Response {
  // Parse query parameters from request
  let query_params =
    req.query
    |> option.map(fn(query) { result.unwrap(uri.parse_query(query), []) })
    |> option.unwrap([])

  // Parse search filters
  let filters = data_users.parse_search_filters(query_params)

  // Get filtered search results
  let search_results = case data_users.search_users(db, filters.query) {
    Ok(users) -> users
    Error(_) -> []
  }

  let props = [
    user_props.search_filters(filters),
    user_props.search_results(search_results),
    // OptionalProp - analytics excluded by default, included when requested
    user_props.search_analytics(fn() {
      compute_search_analytics(db, search_results)
    }),
  ]

  req
  |> inertia.response_builder("Users/Search")
  |> inertia.props(props, user_props.user_prop_to_json)
  |> inertia.response()
}

/// Compute search analytics for filtered results (OptionalProp)
fn compute_search_analytics(
  db: sqlight.Connection,
  search_results: List(data_users.User),
) -> Result(data_users.SearchAnalytics, dict.Dict(String, String)) {
  let total_filtered = list.length(search_results)

  // Get total users for percentage calculation
  let total_users = case data_users.get_user_count(db) {
    Ok(count) -> count
    Error(_) -> 1
  }

  let matching_percentage = case total_users {
    0 -> 0.0
    _ -> int.to_float(total_filtered) /. int.to_float(total_users) *. 100.0
  }

  Ok(data_users.SearchAnalytics(
    total_filtered: total_filtered,
    matching_percentage: matching_percentage,
    filter_performance_ms: 25,
    // Simulated performance metric
  ))
}
