# Design Document

## Overview

This design implements advanced Inertia.js prop types (OptionalProp, DeferredProp, and MergeProp) to provide sophisticated performance optimization and user experience enhancements. The implementation extends the existing Response Builder API and prop type system to support search optimization, dashboard analytics, and infinite scroll pagination with comprehensive test coverage.

The design leverages the existing `types.Prop(p)` union type and Response Builder infrastructure, adding new prop variants and enhancing the prop processing pipeline to handle advanced scenarios like deferred loading, client-side merging, and conditional prop inclusion.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Advanced Props System                        │
├─────────────────────────────────────────────────────────────────┤
│  Request Handler Layer                                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Search Handler  │  │Dashboard Handler│  │Pagination Handler│ │
│  │ (OptionalProp)  │  │ (DeferredProp)  │  │  (MergeProp)    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  Response Builder API (Enhanced)                                │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ • Prop filtering based on request type                     │ │
│  │ • Deferred prop metadata generation                        │ │
│  │ • Merge prop metadata generation                           │ │
│  │ • Partial reload component matching                        │ │
│  └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  Core Prop Types (Extended)                                    │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ • OptionalProp (conditional inclusion)                     │ │
│  │ • DeferredProp (background loading with groups)            │ │
│  │ • MergeProp (client-side merging with strategies)          │ │
│  └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  Frontend Integration                                           │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ • React components for advanced prop handling              │ │
│  │ • TypeScript types for prop structures                     │ │
│  │ • Loading states and error handling                        │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Request Flow Architecture

```
Initial Request → Filter Props → Process Props → Generate Response
     │               │              │               │
     │               │              │               └─ Include: DefaultProp, LazyProp, AlwaysProp
     │               │              │                  Exclude: OptionalProp
     │               │              │                  Defer: DeferredProp (metadata only)
     │               │              │                  Merge: MergeProp (with metadata)
     │               │              │
     │               │              └─ Evaluate resolvers for included props
     │               │                 Generate deferred prop metadata
     │               │                 Generate merge prop metadata
     │               │
     │               └─ Based on request type:
     │                  • Standard: Exclude OptionalProp
     │                  • Partial: Include only requested props + AlwaysProp
     │
     └─ Determine request type:
        • Standard visit (initial page load)
        • Inertia request (navigation)
        • Partial reload (specific props requested)

Partial Request → Validate Component → Filter Requested Props → Process Props → Generate Response
     │                    │                     │                    │               │
     │                    │                     │                    │               └─ Include only requested props
     │                    │                     │                    │                  Evaluate deferred props if requested
     │                    │                     │                    │                  Handle merge props normally
     │                    │                     │                    │
     │                    │                     │                    └─ Evaluate resolvers for requested props
     │                    │                     │                       Handle prop errors gracefully
     │                    │                     │
     │                    │                     └─ Include props matching request:
     │                    │                        • Requested prop names
     │                    │                        • AlwaysProp (always included)
     │                    │                        • OptionalProp (if specifically requested)
     │                    │                        • DeferredProp (if specifically requested)
     │                    │
     │                    └─ Ensure component matches request
     │                       Reject if component mismatch
     │
     └─ Extract partial reload headers:
        • X-Inertia-Partial-Component
        • X-Inertia-Partial-Data
```

## Components and Interfaces

### Enhanced Prop Types

The existing `types.Prop(p)` union type already includes the advanced prop types we need:

```gleam
pub type Prop(p) {
  // Existing types (already implemented)
  DefaultProp(name: String, value: p)
  LazyProp(name: String, resolver: fn() -> Result(p, dict.Dict(String, String)))
  AlwaysProp(name: String, value: p)
  
  // Advanced types (need enhanced implementation)
  OptionalProp(name: String, resolver: fn() -> Result(p, dict.Dict(String, String)))
  DeferProp(name: String, group: option.Option(String), resolver: fn() -> Result(p, dict.Dict(String, String)))
  MergeProp(prop: Prop(p), match_on: option.Option(List(String)), deep: Bool)
}
```

### New Data Types for Advanced Features

```gleam
// Search and filtering types
pub type SearchFilters {
  SearchFilters(
    query: String,
    category: Option(String),
    date_range: Option(DateRange),
    sort_by: SortOption,
  )
}

pub type DateRange {
  DateRange(start: String, end: String)
}

pub type SortOption {
  NameAsc
  NameDesc
  DateAsc
  DateDesc
  EmailAsc
  EmailDesc
}

// Analytics and dashboard types
pub type UserAnalytics {
  UserAnalytics(
    total_users: Int,
    active_users: Int,
    growth_rate: Float,
    top_domains: List(DomainStat),
    monthly_signups: List(MonthlyData),
    user_activity_trend: List(ActivityData),
  )
}

pub type DomainStat {
  DomainStat(domain: String, count: Int, percentage: Float)
}

pub type MonthlyData {
  MonthlyData(month: String, count: Int)
}

pub type ActivityData {
  ActivityData(date: String, active_count: Int)
}

// Activity feed types
pub type Activity {
  UserCreated(user: users.User, timestamp: String)
  UserUpdated(user: users.User, timestamp: String)
  UserDeleted(user_name: String, timestamp: String)
  SystemEvent(event: String, timestamp: String)
}

// Pagination and merge types
pub type PaginatedUsers {
  PaginatedUsers(
    data: List(users.User),
    meta: PaginationMeta,
    has_more: Bool,
  )
}

pub type PaginationMeta {
  PaginationMeta(
    current_page: Int,
    per_page: Int,
    total: Int,
    total_pages: Int,
    from: Int,
    to: Int,
  )
}

// Growth statistics for deferred loading
pub type GrowthStats {
  GrowthStats(
    weekly_growth: Float,
    monthly_growth: Float,
    quarterly_growth: Float,
    retention_rate: Float,
    churn_rate: Float,
  )
}
```

### Enhanced UserProp Union Type

```gleam
pub type UserProp {
  // Existing props
  UserList(List(users.User))
  UserCount(Int)
  UserData(users.User)
  UserFormData(name: String, email: String)
  
  // New advanced props
  SearchFilters(SearchFilters)           // DefaultProp
  UserAnalytics(UserAnalytics)          // OptionalProp/DeferredProp
  ActivityFeed(List(Activity))          // DeferredProp("activity")
  GrowthStats(GrowthStats)             // DeferredProp("analytics")
  PaginatedUsers(PaginatedUsers)        // MergeProp
  SearchResults(List(users.User))       // OptionalProp
  FilteredCount(Int)                    // OptionalProp
}
```

### Factory Functions for Advanced Props

```gleam
// OptionalProp factories
pub fn search_results(
  search_fn: fn() -> Result(List(users.User), dict.Dict(String, String)),
) -> types.Prop(UserProp) {
  types.OptionalProp("search_results", fn() {
    case search_fn() {
      Ok(users) -> Ok(SearchResults(users))
      Error(errors) -> Error(errors)
    }
  })
}

pub fn user_analytics(
  analytics_fn: fn() -> Result(UserAnalytics, dict.Dict(String, String)),
) -> types.Prop(UserProp) {
  types.OptionalProp("user_analytics", fn() {
    case analytics_fn() {
      Ok(analytics) -> Ok(UserAnalytics(analytics))
      Error(errors) -> Error(errors)
    }
  })
}

// DeferredProp factories
pub fn activity_feed(
  activity_fn: fn() -> Result(List(Activity), dict.Dict(String, String)),
) -> types.Prop(UserProp) {
  types.DeferProp("activity_feed", option.Some("activity"), fn() {
    case activity_fn() {
      Ok(activities) -> Ok(ActivityFeed(activities))
      Error(errors) -> Error(errors)
    }
  })
}

pub fn growth_stats(
  growth_fn: fn() -> Result(GrowthStats, dict.Dict(String, String)),
) -> types.Prop(UserProp) {
  types.DeferProp("growth_stats", option.Some("analytics"), fn() {
    case growth_fn() {
      Ok(stats) -> Ok(GrowthStats(stats))
      Error(errors) -> Error(errors)
    }
  })
}

// MergeProp factories
pub fn paginated_users(users: PaginatedUsers) -> types.Prop(UserProp) {
  let inner_prop = types.DefaultProp("users", PaginatedUsers(users))
  types.MergeProp(inner_prop, option.Some(["id"]), False)
}

pub fn infinite_scroll_users(users: List(users.User)) -> types.Prop(UserProp) {
  let inner_prop = types.DefaultProp("users", UserList(users))
  types.MergeProp(inner_prop, option.None, False)
}
```

### Handler Architecture

```gleam
// Advanced search handler with OptionalProp
pub fn users_search(req: Request, db: Connection) -> Response {
  let search_filters = extract_search_filters(req)
  let basic_results = get_basic_search_results(db, search_filters)
  
  let props = [
    user_props.search_filters(search_filters),
    user_props.user_list(basic_results),
    user_props.search_results(fn() { 
      get_detailed_search_results(db, search_filters) 
    }),
    user_props.filtered_count(fn() { 
      get_filtered_count(db, search_filters) 
    }),
  ]
  
  req
  |> inertia.response_builder("Users/Search")
  |> inertia.props(props, user_props.user_prop_to_json)
  |> inertia.response()
}

// Dashboard handler with DeferredProp groups
pub fn users_dashboard(req: Request, db: Connection) -> Response {
  let quick_count = get_user_count(db)
  
  let props = [
    user_props.user_count(quick_count),
    user_props.user_analytics(fn() { 
      compute_user_analytics(db) 
    }),
    user_props.activity_feed(fn() { 
      get_recent_activity(db) 
    }),
    user_props.growth_stats(fn() { 
      compute_growth_statistics(db) 
    }),
  ]
  
  req
  |> inertia.response_builder("Users/Dashboard")
  |> inertia.props(props, user_props.user_prop_to_json)
  |> inertia.response()
}

// Pagination handler with MergeProp
pub fn users_paginated(req: Request, db: Connection) -> Response {
  let page = get_page_from_query(req) |> result.unwrap(1)
  let per_page = 20
  let paginated_data = get_paginated_users(db, page, per_page)
  
  let props = [
    user_props.paginated_users(paginated_data),
  ]
  
  req
  |> inertia.response_builder("Users/Paginated")
  |> inertia.props(props, user_props.user_prop_to_json)
  |> inertia.response()
}
```

## Data Models

### Database Layer Enhancements

```gleam
// Enhanced user data access with analytics support
pub fn get_user_analytics(db: Connection) -> Result(UserAnalytics, String) {
  use total_users <- result.try(get_total_user_count(db))
  use active_users <- result.try(get_active_user_count(db))
  use growth_rate <- result.try(calculate_growth_rate(db))
  use top_domains <- result.try(get_top_domains(db))
  use monthly_signups <- result.try(get_monthly_signups(db))
  use activity_trend <- result.try(get_activity_trend(db))
  
  Ok(UserAnalytics(
    total_users: total_users,
    active_users: active_users,
    growth_rate: growth_rate,
    top_domains: top_domains,
    monthly_signups: monthly_signups,
    user_activity_trend: activity_trend,
  ))
}

// Activity feed data access
pub fn get_recent_activity(db: Connection, limit: Int) -> Result(List(Activity), String) {
  let sql = "
    SELECT type, user_id, user_name, user_email, timestamp 
    FROM user_activity 
    ORDER BY timestamp DESC 
    LIMIT ?
  "
  
  use rows <- result.try(sqlight.query(sql, db, [sqlight.int(limit)], decode_activity_row))
  Ok(rows)
}

// Search functionality with filtering
pub fn search_users(
  db: Connection, 
  filters: SearchFilters,
) -> Result(List(users.User), String) {
  let base_sql = "SELECT id, name, email, created_at FROM users WHERE 1=1"
  let #(sql, params) = build_search_query(base_sql, filters)
  
  use rows <- result.try(sqlight.query(sql, db, params, users.decode_user_row))
  Ok(rows)
}

// Pagination support
pub fn get_paginated_users(
  db: Connection,
  page: Int,
  per_page: Int,
) -> Result(PaginatedUsers, String) {
  let offset = (page - 1) * per_page
  
  use total <- result.try(get_total_user_count(db))
  use users <- result.try(get_users_with_limit(db, per_page, offset))
  
  let total_pages = (total + per_page - 1) / per_page
  let has_more = page < total_pages
  
  let meta = PaginationMeta(
    current_page: page,
    per_page: per_page,
    total: total,
    total_pages: total_pages,
    from: offset + 1,
    to: offset + list.length(users),
  )
  
  Ok(PaginatedUsers(
    data: users,
    meta: meta,
    has_more: has_more,
  ))
}
```

### JSON Encoding Enhancements

```gleam
// Enhanced JSON encoding for new prop types
pub fn user_prop_to_json(prop: UserProp) -> json.Json {
  case prop {
    // Existing encoders...
    UserList(users) -> encode_user_list(users)
    UserCount(count) -> json.int(count)
    UserData(user) -> encode_user(user)
    
    // New advanced prop encoders
    SearchFilters(filters) -> encode_search_filters(filters)
    UserAnalytics(analytics) -> encode_user_analytics(analytics)
    ActivityFeed(activities) -> encode_activity_feed(activities)
    GrowthStats(stats) -> encode_growth_stats(stats)
    PaginatedUsers(paginated) -> encode_paginated_users(paginated)
    SearchResults(users) -> encode_user_list(users)
    FilteredCount(count) -> json.int(count)
  }
}

fn encode_search_filters(filters: SearchFilters) -> json.Json {
  json.object([
    #("query", json.string(filters.query)),
    #("category", encode_optional_string(filters.category)),
    #("date_range", encode_optional_date_range(filters.date_range)),
    #("sort_by", encode_sort_option(filters.sort_by)),
  ])
}

fn encode_user_analytics(analytics: UserAnalytics) -> json.Json {
  json.object([
    #("total_users", json.int(analytics.total_users)),
    #("active_users", json.int(analytics.active_users)),
    #("growth_rate", json.float(analytics.growth_rate)),
    #("top_domains", json.array(analytics.top_domains, encode_domain_stat)),
    #("monthly_signups", json.array(analytics.monthly_signups, encode_monthly_data)),
    #("user_activity_trend", json.array(analytics.user_activity_trend, encode_activity_data)),
  ])
}

fn encode_paginated_users(paginated: PaginatedUsers) -> json.Json {
  json.object([
    #("data", encode_user_list(paginated.data)),
    #("meta", encode_pagination_meta(paginated.meta)),
    #("has_more", json.bool(paginated.has_more)),
  ])
}
```

## Error Handling

### Prop Resolution Error Handling

```gleam
// Enhanced error handling for advanced prop scenarios
pub fn handle_prop_errors(
  prop_name: String,
  error: dict.Dict(String, String),
) -> dict.Dict(String, String) {
  case dict.get(error, "type") {
    Ok("database_error") -> 
      dict.from_list([
        #(prop_name <> ".database", "Database connection failed"),
        #(prop_name <> ".retry", "Please try again later"),
      ])
    Ok("timeout_error") ->
      dict.from_list([
        #(prop_name <> ".timeout", "Request timed out"),
        #(prop_name <> ".suggestion", "Try reducing the date range"),
      ])
    Ok("validation_error") ->
      error
    _ ->
      dict.from_list([
        #(prop_name <> ".general", "An unexpected error occurred"),
      ])
  }
}

// Graceful degradation for deferred props
pub fn create_fallback_analytics() -> UserAnalytics {
  UserAnalytics(
    total_users: 0,
    active_users: 0,
    growth_rate: 0.0,
    top_domains: [],
    monthly_signups: [],
    user_activity_trend: [],
  )
}

// Error boundaries for expensive operations
pub fn safe_compute_analytics(db: Connection) -> Result(UserAnalytics, dict.Dict(String, String)) {
  case compute_user_analytics(db) {
    Ok(analytics) -> Ok(analytics)
    Error(_) -> {
      // Log error and return fallback
      let fallback = create_fallback_analytics()
      Ok(fallback)
    }
  }
}
```

### Frontend Error Handling

```gleam
// Error component props for frontend
pub type ErrorProp {
  PropError(prop_name: String, error_message: String, retry_available: Bool)
  LoadingError(component: String, error_details: String)
  NetworkError(status_code: Int, message: String)
}

pub fn error_prop(
  name: String,
  message: String,
  can_retry: Bool,
) -> types.Prop(ErrorProp) {
  types.AlwaysProp("error", PropError(name, message, can_retry))
}
```

## Testing Strategy

### Unit Test Structure

```gleam
// Test modules for each prop type
// test/advanced_props/optional_prop_test.gleam
// test/advanced_props/deferred_prop_test.gleam  
// test/advanced_props/merge_prop_test.gleam

// OptionalProp tests
pub fn optional_prop_excluded_on_standard_request_test() {
  let req = create_standard_request()
  let props = [user_props.user_analytics(fn() { Ok(create_test_analytics()) })]
  
  let builder = 
    req
    |> inertia.response_builder("Users/Test")
    |> inertia.props(props, user_props.user_prop_to_json)
  
  let response = inertia.response(builder)
  let json_body = extract_json_from_response(response)
  
  json_body
  |> json.field("props", json.dynamic)
  |> should.be_ok()
  |> dict.has_key("user_analytics")
  |> should.be_false()
}

pub fn optional_prop_included_on_partial_request_test() {
  let req = create_partial_request(["user_analytics"])
  let props = [user_props.user_analytics(fn() { Ok(create_test_analytics()) })]
  
  let builder = 
    req
    |> inertia.response_builder("Users/Test")
    |> inertia.props(props, user_props.user_prop_to_json)
  
  let response = inertia.response(builder)
  let json_body = extract_json_from_response(response)
  
  json_body
  |> json.field("props", json.dynamic)
  |> should.be_ok()
  |> dict.has_key("user_analytics")
  |> should.be_true()
}

// DeferredProp tests
pub fn deferred_prop_excluded_from_initial_props_test() {
  let req = create_standard_request()
  let props = [user_props.activity_feed(fn() { Ok(create_test_activities()) })]
  
  let builder = 
    req
    |> inertia.response_builder("Users/Test")
    |> inertia.props(props, user_props.user_prop_to_json)
  
  let response = inertia.response(builder)
  let json_body = extract_json_from_response(response)
  
  // Should not be in props
  json_body
  |> json.field("props", json.dynamic)
  |> should.be_ok()
  |> dict.has_key("activity_feed")
  |> should.be_false()
  
  // Should be in deferredProps metadata
  json_body
  |> json.field("deferredProps", json.dynamic)
  |> should.be_ok()
  |> dict.get("activity")
  |> should.be_ok()
  |> should.contain("activity_feed")
}

// MergeProp tests
pub fn merge_prop_includes_metadata_test() {
  let req = create_standard_request()
  let paginated = create_test_paginated_users()
  let props = [user_props.paginated_users(paginated)]
  
  let builder = 
    req
    |> inertia.response_builder("Users/Test")
    |> inertia.props(props, user_props.user_prop_to_json)
  
  let response = inertia.response(builder)
  let json_body = extract_json_from_response(response)
  
  // Should include merge metadata
  json_body
  |> json.field("mergeProps", json.dynamic)
  |> should.be_ok()
  |> should.contain("users")
  
  // Should include match metadata
  json_body
  |> json.field("matchPropsOn", json.dynamic)
  |> should.be_ok()
  |> should.contain("users.id")
}
```

### Integration Test Structure

```gleam
// test/integration/advanced_props_integration_test.gleam

pub fn complete_dashboard_flow_test() {
  use db <- with_test_database()
  
  // Seed test data
  seed_test_users(db)
  seed_test_activities(db)
  
  // Initial dashboard request
  let req = create_dashboard_request()
  let response = handlers.users_dashboard(req, db)
  
  // Verify initial response structure
  let json_body = extract_json_from_response(response)
  
  // Should have basic props
  json_body
  |> json.field("props", json.dynamic)
  |> should.be_ok()
  |> dict.has_key("user_count")
  |> should.be_true()
  
  // Should have deferred prop metadata
  json_body
  |> json.field("deferredProps", json.dynamic)
  |> should.be_ok()
  |> dict.has_key("analytics")
  |> should.be_true()
  
  // Test partial reload for deferred props
  let partial_req = create_partial_request(["user_analytics", "growth_stats"])
  let partial_response = handlers.users_dashboard(partial_req, db)
  
  let partial_json = extract_json_from_response(partial_response)
  
  // Should now include the deferred props
  partial_json
  |> json.field("props", json.dynamic)
  |> should.be_ok()
  |> dict.has_key("user_analytics")
  |> should.be_true()
}

pub fn search_with_optional_props_test() {
  use db <- with_test_database()
  
  seed_test_users(db)
  
  // Basic search request
  let search_req = create_search_request("john", None)
  let response = handlers.users_search(search_req, db)
  
  let json_body = extract_json_from_response(response)
  
  // Should have basic search results
  json_body
  |> json.field("props", json.dynamic)
  |> should.be_ok()
  |> dict.has_key("users")
  |> should.be_true()
  
  // Should not have expensive optional props
  json_body
  |> json.field("props", json.dynamic)
  |> should.be_ok()
  |> dict.has_key("search_results")
  |> should.be_false()
  
  // Request with optional props
  let detailed_req = create_partial_request(["search_results", "filtered_count"])
  let detailed_response = handlers.users_search(detailed_req, db)
  
  let detailed_json = extract_json_from_response(detailed_response)
  
  // Should now include optional props
  detailed_json
  |> json.field("props", json.dynamic)
  |> should.be_ok()
  |> dict.has_key("search_results")
  |> should.be_true()
}
```

### Performance Test Structure

```gleam
// test/performance/advanced_props_performance_test.gleam

pub fn deferred_props_improve_initial_load_time_test() {
  use db <- with_large_test_dataset()
  
  // Measure initial load without deferred props
  let start_time = get_current_time()
  let req = create_dashboard_request()
  let _response = handlers.users_dashboard(req, db)
  let initial_load_time = get_current_time() - start_time
  
  // Should be under 200ms
  initial_load_time
  |> should.be_less_than(200)
  
  // Measure deferred prop load time separately
  let deferred_start = get_current_time()
  let partial_req = create_partial_request(["user_analytics"])
  let _partial_response = handlers.users_dashboard(partial_req, db)
  let deferred_load_time = get_current_time() - deferred_start
  
  // Deferred load can be slower but should still be reasonable
  deferred_load_time
  |> should.be_less_than(1000)
}

pub fn optional_props_optimize_search_performance_test() {
  use db <- with_large_test_dataset()
  
  // Basic search should be fast
  let start_time = get_current_time()
  let req = create_search_request("test", None)
  let _response = handlers.users_search(req, db)
  let basic_search_time = get_current_time() - start_time
  
  // Should be under 100ms
  basic_search_time
  |> should.be_less_than(100)
  
  // Detailed search with optional props can be slower
  let detailed_start = get_current_time()
  let detailed_req = create_partial_request(["search_results"])
  let _detailed_response = handlers.users_search(detailed_req, db)
  let detailed_search_time = get_current_time() - detailed_start
  
  // Should still be reasonable
  detailed_search_time
  |> should.be_less_than(500)
}
```

This design provides a comprehensive foundation for implementing advanced Inertia.js prop types while maintaining compatibility with the existing Response Builder API and prop system. The architecture supports performance optimization through conditional prop loading, progressive enhancement through deferred props, and smooth user experiences through client-side prop merging.