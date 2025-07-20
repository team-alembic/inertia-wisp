//// Advanced Inertia.js Props TDD Tests - Feature 027
////
//// This module contains TDD tests for implementing advanced Inertia.js prop types
//// as outlined in Feature 027. We follow strict Red-Green-Refactor methodology.
////
//// Phase 1: OptionalProp Implementation
//// - Search and filtering with optional expensive operations
//// - Partial reload optimization excluding optional props by default
//// - Component matching for partial reloads

import data/users

import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import handlers/users as user_handlers
import inertia_wisp/testing
import utils/test_db

// =============================================================================
// Phase 1: OptionalProp Implementation - RED Phase (Failing Tests)
// =============================================================================

/// Test search filters type exists and can be parsed from query parameters
/// RED: This will fail until we implement parse_search_filters function
pub fn search_filters_type_test() {
  // Test parsing search filters from query parameters
  let query_params = [
    #("query", "Demo"),
    #("category", "users"),
    #("sort_by", "name"),
  ]

  // This will fail because parse_search_filters is stubbed with todo
  let filters = users.parse_search_filters(query_params)

  // Test that SearchFilters type has expected structure
  assert filters.query == "Demo"
  assert filters.category == option.Some("users")
  assert filters.sort_by == users.SortByName
}

/// Test users_search handler returns proper component and expected props structure
/// RED: This will fail until we implement users_search handler with proper props
pub fn users_search_handler_test() {
  let assert Ok(db) = test_db.setup_test_database()

  let req =
    testing.inertia_request_to("/users/search?query=Demo&category=users")
  // This will fail because users_search is stubbed with todo
  let response = user_handlers.users_search(req, db)

  // Test component name
  assert testing.component(response) == Ok("Users/Search")

  // Test that search filters prop exists and contains expected query
  let filters_decoder = decode.at(["query"], decode.string)
  let assert Ok(query) =
    testing.prop(response, "search_filters", filters_decoder)
  assert query == "Demo"

  // Test that search results prop exists (should be a list of users)
  let results_decoder = decode.list(decode.dynamic)
  let assert Ok(_) = testing.prop(response, "search_results", results_decoder)

  // Test that analytics prop is NOT present by default (OptionalProp behavior)
  let analytics_result = testing.prop(response, "analytics", decode.dynamic)
  assert result.is_error(analytics_result)
}

/// Test search page includes analytics when requested via partial reload (OptionalProp)
/// RED: This will fail until we implement OptionalProp analytics on search page
pub fn users_analytics_handler_test() {
  let assert Ok(db) = test_db.setup_test_database()

  // Partial request specifically requesting analytics OptionalProp
  let req =
    testing.inertia_request_to("/users/search?query=Demo")
    |> testing.partial_data(["analytics"])
    |> testing.partial_component("Users/Search")
  let response = user_handlers.users_search(req, db)

  // Test component name (should still be search page)
  assert testing.component(response) == Ok("Users/Search")

  // Test that analytics prop exists and has expected structure when requested
  let analytics_decoder = decode.at(["total_filtered"], decode.int)
  let assert Ok(total) = testing.prop(response, "analytics", analytics_decoder)
  assert total >= 0

  // Test that growth rate exists in analytics
  let percentage_decoder = decode.at(["matching_percentage"], decode.float)
  let assert Ok(_) = testing.prop(response, "analytics", percentage_decoder)
}

/// Test standard request to search page excludes optional analytics
/// RED: Will fail until OptionalProp for analytics is properly implemented
pub fn search_excludes_optional_analytics_by_default_test() {
  let assert Ok(db) = test_db.setup_test_database()

  let req = testing.inertia_request_to("/users/search?query=Demo")
  // This will fail because users_search is stubbed with todo
  let response = user_handlers.users_search(req, db)

  // Analytics should be excluded by default (OptionalProp behavior)
  let analytics_result = testing.prop(response, "analytics", decode.dynamic)
  assert result.is_error(analytics_result)

  // But search results should be included (DefaultProp behavior)
  let search_result =
    testing.prop(response, "search_results", decode.list(decode.dynamic))
  assert result.is_ok(search_result)
}

/// Test partial request with "only" includes optional analytics
/// RED: Will fail until proper OptionalProp partial reload handling is implemented
pub fn search_includes_analytics_when_requested_test() {
  let assert Ok(db) = test_db.setup_test_database()

  // Partial reload requesting analytics specifically
  let req =
    testing.inertia_request_to("/users/search?query=Demo")
    |> testing.partial_data(["analytics"])
    |> testing.partial_component("Users/Search")
  // This will fail because users_search is stubbed with todo
  let response = user_handlers.users_search(req, db)

  // Analytics should now be included when explicitly requested
  let analytics_decoder = decode.at(["total_filtered"], decode.int)
  let assert Ok(total_filtered) =
    testing.prop(response, "analytics", analytics_decoder)
  assert total_filtered >= 0
}

/// Test search functionality with query parameters and multiple filters
/// RED: Will fail until search query handling and filter parsing is implemented
pub fn search_with_query_parameters_test() {
  let assert Ok(db) = test_db.setup_test_database()

  let req =
    testing.inertia_request_to(
      "/users/search?query=Demo&category=users&sort_by=name",
    )
  // This will fail because users_search is stubbed with todo
  let response = user_handlers.users_search(req, db)

  // Test component name
  assert testing.component(response) == Ok("Users/Search")

  // Should parse and include search filters with all parameters
  let query_decoder = decode.at(["query"], decode.string)
  let assert Ok(query) = testing.prop(response, "search_filters", query_decoder)
  assert query == "Demo"

  let category_decoder = decode.at(["category"], decode.optional(decode.string))
  let assert Ok(category_opt) =
    testing.prop(response, "search_filters", category_decoder)
  assert category_opt == option.Some("users")

  let sort_decoder = decode.at(["sort_by"], decode.string)
  let assert Ok(sort_by) =
    testing.prop(response, "search_filters", sort_decoder)
  assert sort_by == "name"

  // Should include search results (filtered by query)
  let results_decoder = decode.list(decode.at(["name"], decode.string))
  let assert Ok(user_names) =
    testing.prop(response, "search_results", results_decoder)
  // All results should match the query "Demo"
  list.each(user_names, fn(name) {
    assert name |> string.contains("Demo")
  })
}

/// Test Response Builder handles partial reloads automatically
/// RED: Will fail until proper Response Builder integration with OptionalProp
pub fn response_builder_handles_partial_reloads_test() {
  let assert Ok(db) = test_db.setup_test_database()

  // Standard request should exclude optional props
  let standard_req = testing.inertia_request_to("/users/search?query=Demo")
  // This will fail because users_search is stubbed with todo
  let standard_response = user_handlers.users_search(standard_req, db)

  // Analytics should not be in props for standard request
  let standard_analytics =
    testing.prop(standard_response, "analytics", decode.dynamic)
  assert result.is_error(standard_analytics)

  // Partial request should include optional props when requested
  let partial_req =
    testing.inertia_request_to("/users/search?query=Demo")
    |> testing.partial_data(["analytics", "search_results"])
    |> testing.partial_component("Users/Search")
  // This will fail because users_search is stubbed with todo
  let partial_response = user_handlers.users_search(partial_req, db)

  // Analytics should be included in partial request
  let partial_analytics =
    testing.prop(partial_response, "analytics", decode.dynamic)
  assert result.is_ok(partial_analytics)
}

// =============================================================================
// Phase 1: Integration Tests (will also fail initially)
// =============================================================================

/// Test search results are filtered correctly and return actual user data
/// RED: Will fail until database search filtering is implemented
pub fn search_results_filtering_test() {
  let assert Ok(db) = test_db.setup_test_database()

  // Search for "Demo" should return demo users
  let req = testing.inertia_request_to("/users/search?query=Demo")
  // This will fail because users_search is stubbed with todo
  let response = user_handlers.users_search(req, db)

  // Test that results contain user objects with expected fields
  let results_decoder =
    decode.list({
      use name <- decode.field("name", decode.string)
      use email <- decode.field("email", decode.string)
      decode.success(#(name, email))
    })
  let assert Ok(users_data) =
    testing.prop(response, "search_results", results_decoder)

  // Should have at least some results
  assert list.length(users_data) > 0

  // All results should contain "Demo" in the name
  list.each(users_data, fn(user_tuple) {
    let #(name, _email) = user_tuple
    assert string.contains(name, "Demo")
  })

  // Should include search query in props
  let query_decoder = decode.at(["query"], decode.string)
  let assert Ok(query) = testing.prop(response, "search_filters", query_decoder)
  assert query == "Demo"
}

/// Test analytics computation for filtered results
/// RED: Will fail until analytics for filtered results is implemented
pub fn search_analytics_computation_test() {
  let assert Ok(db) = test_db.setup_test_database()

  // Request analytics for search results
  let req =
    testing.inertia_request_to("/users/search?query=Demo")
    |> testing.partial_data(["analytics"])
    |> testing.partial_component("Users/Search")
  // This will fail because users_search is stubbed with todo
  let response = user_handlers.users_search(req, db)

  // Should include analytics specific to filtered results
  let analytics_decoder = {
    use total_filtered <- decode.field("total_filtered", decode.int)
    use matching_percentage <- decode.field("matching_percentage", decode.float)
    decode.success(#(total_filtered, matching_percentage))
  }

  let assert Ok(#(total, percentage)) =
    testing.prop(response, "analytics", analytics_decoder)
  assert total >= 0
  assert percentage >=. 0.0
  assert percentage <=. 100.0
}

/// Test category filtering functionality
/// RED: Will fail until category-based filtering is implemented
pub fn category_filtering_test() {
  let assert Ok(db) = test_db.setup_test_database()

  // Search with category filter
  let req = testing.inertia_request_to("/users/search?category=admin")
  // This will fail because users_search is stubbed with todo
  let response = user_handlers.users_search(req, db)

  // Should include category in search filters
  let category_decoder = decode.at(["category"], decode.optional(decode.string))
  let assert Ok(category_opt) =
    testing.prop(response, "search_filters", category_decoder)
  assert category_opt == option.Some("admin")
}

// =============================================================================
// Helper Functions for Tests
// =============================================================================

/// Test that search filters include all expected fields and handle edge cases
/// RED: Will fail until complete SearchFilters type is implemented
pub fn search_filters_complete_structure_test() {
  let assert Ok(db) = test_db.setup_test_database()

  // Test with all parameters present
  let req =
    testing.inertia_request_to(
      "/users/search?query=test&category=admin&sort_by=name",
    )
  // This will fail because users_search is stubbed with todo
  let response = user_handlers.users_search(req, db)

  // This test defines the expected structure of SearchFilters
  let expected_decoder = {
    use query <- decode.field("query", decode.string)
    use category <- decode.field("category", decode.optional(decode.string))
    use sort_by <- decode.field("sort_by", decode.string)
    decode.success(#(query, category, sort_by))
  }

  let assert Ok(#("test", option.Some("admin"), "name")) =
    testing.prop(response, "search_filters", expected_decoder)

  // Test that search results are included even with complex filters
  let results_decoder = decode.list(decode.dynamic)
  let assert Ok(_) = testing.prop(response, "search_results", results_decoder)
}
