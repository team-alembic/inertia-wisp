//// Dashboard handler for DeferredProp functionality demonstration.
////
//// This module demonstrates DeferredProp usage for expensive calculations
//// like analytics and activity feeds that should be loaded after the initial page render.

import data/users
import gleam/dict
import gleam/erlang/process
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/uri
import inertia_wisp/inertia
import inertia_wisp/internal/types
import props/user_props
import sqlight.{type Connection}
import utils/demo_data
import wisp.{type Request, type Response}

/// Dashboard page handler that demonstrates DeferredProp functionality
/// Shows how expensive calculations can be deferred until specifically requested
pub fn dashboard_page(req: Request, db: Connection) -> Response {
  // Get delay parameter from query string (default to 2000ms for demo)
  let delay_ms = get_delay_param(req)
  echo delay_ms

  case users.get_user_count(db) {
    Ok(count) -> {
      // Create basic props that load immediately (included in initial loads only)
      let basic_props = [
        types.DefaultProp("user_count", user_props.UserCount(count))
      ]

      // Create deferred props that load only when requested
      let deferred_props = [
        dashboard_analytics_prop(db, delay_ms),
        activity_feed_prop(db, delay_ms)
      ]

      // Combine all props
      let all_props = list.append(basic_props, deferred_props)

      req
      |> inertia.response_builder("Dashboard/Index")
      |> inertia.props(all_props, user_props.user_prop_to_json)
      |> inertia.response()
    }
    Error(_) -> {
      // Handle database error
      req
      |> inertia.response_builder("Dashboard/Index")
      |> inertia.props([], user_props.user_prop_to_json)
      |> inertia.response()
    }
  }
}

/// Helper function to create dashboard analytics prop (DeferredProp)
/// This represents expensive analytics calculations that should be deferred
fn dashboard_analytics_prop(db: Connection, delay_ms: Int) -> types.Prop(user_props.UserProp) {
  types.DeferProp("analytics", option.None, fn() {
    // Artificial delay to demonstrate progressive loading
    process.sleep(delay_ms)
    users.compute_user_analytics(db)
    |> result.map(user_props.UserAnalytics)
    |> result.map_error(fn(_) { dict.new() })
  })
}

/// Extract delay parameter from query string for demo purposes
/// Supports ?delay=1000 to control artificial delay in milliseconds
fn get_delay_param(req: Request) -> Int {
  let query_string = req.query |> option.unwrap("")

  case uri.parse_query(query_string) {
    Ok(query_params) -> {
      case list.key_find(query_params, "delay") {
        Ok(delay_str) -> {
          case int.parse(delay_str) {
            Ok(delay) if delay >= 0 && delay <= 10000 -> delay
            _ -> 0  // Default 0ms (no delay) if invalid
          }
        }
        Error(_) -> 0  // Default 0ms (no delay) if no delay param
      }
    }
    Error(_) -> 0  // Default 0ms (no delay) if query parsing fails
  }
}

/// Helper function to create activity feed prop (DeferredProp)
/// This represents expensive activity feed generation that should be deferred
fn activity_feed_prop(db: Connection, delay_ms: Int) -> types.Prop(user_props.UserProp) {
  types.DeferProp("activity_feed", option.Some("activity"), fn() {
    // Artificial delay to demonstrate progressive loading
    process.sleep(delay_ms)
    demo_data.generate_activity_feed(db)
    |> result.map(user_props.ActivityFeed)
    |> result.map_error(fn(_) { dict.new() })
  })
}
