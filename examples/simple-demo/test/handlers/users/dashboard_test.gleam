//// Dashboard handler tests for DeferredProp functionality demonstration.
////
//// This module tests the dashboard page that showcases DeferredProp behavior
//// for expensive analytics calculations and activity feeds.

import gleam/dynamic/decode
import gleam/result
import handlers/users/dashboard
import inertia_wisp/testing
import utils/test_db

pub fn dashboard_excludes_deferred_props_by_default_test() {
  let assert Ok(db) = test_db.setup_test_database()

  let req = testing.inertia_request()
  let response = dashboard.dashboard_page(req, db)

  // Should render dashboard page immediately
  assert testing.component(response) == Ok("Dashboard/Index")

  // Should include basic props immediately (not deferred)
  let assert Ok(user_count) = testing.prop(response, "user_count", decode.int)
  assert user_count == 3

  // Should NOT include expensive deferred props by default
  let analytics_result = testing.prop(response, "analytics", decode.dynamic)
  assert result.is_error(analytics_result)

  let activity_result = testing.prop(response, "activity_feed", decode.dynamic)
  assert result.is_error(activity_result)

  // Should include deferred props in metadata for client-side loading
  let assert Ok(deferred_analytics) =
    testing.deferred_props(response, "default", decode.list(decode.string))
  assert deferred_analytics == ["analytics"]

  let assert Ok(deferred_activity) =
    testing.deferred_props(response, "activity", decode.list(decode.string))
  assert deferred_activity == ["activity_feed"]
}

pub fn dashboard_includes_single_deferred_prop_when_requested_test() {
  let assert Ok(db) = test_db.setup_test_database()

  // Request with partial reload for analytics using correct API
  let req = testing.inertia_request()
    |> testing.partial_data(["analytics"])
    |> testing.partial_component("Dashboard/Index")
  let response = dashboard.dashboard_page(req, db)

  // DefaultProp user_count should NOT be included in partial requests
  let user_count_result = testing.prop(response, "user_count", decode.int)
  assert result.is_error(user_count_result)

  // DeferredProp analytics should be included when specifically requested
  let analytics_decoder = decode.at(["total_users"], decode.int)
  let assert Ok(total_users) = testing.prop(response, "analytics", analytics_decoder)
  assert total_users == 3

  // Should NOT include other deferred props not requested
  let activity_result = testing.prop(response, "activity_feed", decode.dynamic)
  assert result.is_error(activity_result)

  // Partial requests do not include deferredProps metadata
  // The requested prop is evaluated and returned, others are excluded
}

pub fn dashboard_includes_multiple_deferred_props_when_requested_test() {
  let assert Ok(db) = test_db.setup_test_database()

  // Request multiple deferred props using correct API
  let req = testing.inertia_request()
    |> testing.partial_data(["analytics", "activity_feed"])
    |> testing.partial_component("Dashboard/Index")
  let response = dashboard.dashboard_page(req, db)

  // DefaultProp user_count should NOT be included in partial requests
  let user_count_result = testing.prop(response, "user_count", decode.int)
  assert result.is_error(user_count_result)

  // Both deferred props should be included when specifically requested
  let analytics_decoder = decode.at(["total_users"], decode.int)
  let assert Ok(total_users) = testing.prop(response, "analytics", analytics_decoder)
  assert total_users == 3

  let activity_decoder = decode.at(["recent_activities"], decode.list(decode.dynamic))
  let assert Ok(_recent_activities) = testing.prop(response, "activity_feed", activity_decoder)

  // Partial requests do not include deferredProps metadata
  // Both requested props are evaluated and returned
}
