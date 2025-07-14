# 027 - Advanced Inertia.js Props Implementation

## Plan

### Overview
This feature implements the advanced Inertia.js prop types that were planned in Phases 4-6 of Feature 025. We will demonstrate OptionalProp, DeferredProp, and MergeProp functionality using the Response Builder API with comprehensive TDD coverage.

### Key Features to Implement

#### 1. OptionalProp & Partial Reloads (Phase 4)
- **Search and filtering** with optional expensive operations
- **Partial reload optimization** excluding optional props by default
- **Component matching** for partial reloads
- **Query parameter handling** for search/filter states

#### 2. DeferredProp & Performance (Phase 5)  
- **Dashboard analytics** with expensive calculations
- **Deferred prop groups** for different loading strategies
- **Initial page load optimization** (deferred props excluded)
- **Progressive enhancement** (deferred props loaded separately)

#### 3. MergeProp & Advanced UX (Phase 6)
- **Pagination with merge behavior** for infinite scroll
- **Deep merging** for nested data structures
- **Client-side state preservation** during merges
- **Performance optimization** for large datasets

### Implementation Plan

#### Phase 1: OptionalProp Implementation (TDD)

**RED Phase - Search & Filter Infrastructure:**
```gleam
// Search types
pub type SearchFilters {
  SearchFilters(
    query: String,
    category: Option(String),
    date_range: Option(DateRange),
    sort_by: SortOption,
  )
}

// Handler stubs
pub fn users_search(req: Request, db: Connection) -> Response {
  todo as "implement search with OptionalProp"
}

pub fn users_analytics(req: Request, db: Connection) -> Response {
  todo as "implement analytics with OptionalProp"
}
```

**Failing Tests:**
- [ ] Test standard request excludes optional analytics
- [ ] Test partial request with "only" includes analytics
- [ ] Test search functionality with query parameters  
- [ ] Test Response Builder handles partial reloads automatically

**GREEN Phase:**
- [ ] Implement search logic with database queries
- [ ] Implement OptionalProp for expensive analytics
- [ ] Use Response Builder with `types.OptionalProp` for analytics
- [ ] Make all partial reload tests pass

**REFACTOR Phase:**
- [ ] Extract search utilities for reusability
- [ ] Optimize database queries for performance
- [ ] Add search result caching

#### Phase 2: DeferredProp Implementation (TDD)

**RED Phase - Dashboard Infrastructure:**
```gleam
// Analytics types  
pub type UserAnalytics {
  UserAnalytics(
    total_users: Int,
    active_users: Int,
    growth_rate: Float,
    top_domains: List(DomainStat),
  )
}

// Handler stubs
pub fn dashboard_page(req: Request, db: Connection) -> Response {
  todo as "implement dashboard with DeferredProp"
}

pub fn user_activity_feed(req: Request, db: Connection) -> Response {
  todo as "implement activity feed with DeferredProp groups"
}
```

**Failing Tests:**
- [ ] Test initial request excludes deferred props from response.props
- [ ] Test deferred props appear in response.deferredProps metadata
- [ ] Test partial requests evaluate and return deferred props
- [ ] Test deferred prop grouping with different group names

**GREEN Phase:**
- [ ] Implement expensive analytics calculations
- [ ] Implement DeferredProp with different groups ("analytics", "activity")
- [ ] Use Response Builder with `types.DeferredProp` 
- [ ] Make all deferred prop tests pass

**REFACTOR Phase:**
- [ ] Add caching layer for expensive calculations
- [ ] Optimize deferred prop evaluation order
- [ ] Add loading state management

#### Phase 3: MergeProp Implementation (TDD)

**RED Phase - Pagination Infrastructure:**
```gleam
// Pagination types
pub type PaginatedUsers {
  PaginatedUsers(
    data: List(users.User),
    meta: PaginationMeta,
    has_more: Bool,
  )
}

// Handler stubs  
pub fn users_paginated(req: Request, db: Connection) -> Response {
  todo as "implement pagination with MergeProp"
}

pub fn infinite_scroll_users(req: Request, db: Connection) -> Response {
  todo as "implement infinite scroll with MergeProp"
}
```

**Failing Tests:**
- [ ] Test merge prop metadata appears in response.mergeProps
- [ ] Test pagination appends to existing user list
- [ ] Test infinite scroll merges correctly with client state
- [ ] Test deep merge behavior for nested objects

**GREEN Phase:**
- [ ] Implement pagination logic with offset/limit
- [ ] Implement MergeProp for infinite scroll behavior
- [ ] Use Response Builder with `types.MergeProp`
- [ ] Make all merge prop tests pass

**REFACTOR Phase:**
- [ ] Optimize pagination queries with indexes
- [ ] Add cursor-based pagination for performance
- [ ] Improve merge conflict resolution

#### Phase 4: Integration & Frontend (TDD)

**Dashboard Integration:**
- [ ] Create comprehensive dashboard showing all prop types
- [ ] Implement React components for each prop type demonstration
- [ ] Add TypeScript types for all new prop structures
- [ ] Test browser behavior with real prop merging

**User Experience Enhancements:**
- [ ] Loading states for deferred props
- [ ] Search suggestions and autocomplete
- [ ] Infinite scroll with smooth UX
- [ ] Error handling for partial reload failures

### Technical Architecture

#### New Handler Structure
```gleam
// Advanced user handlers
pub fn users_dashboard(req: Request, db: Connection) -> Response {
  let props = [
    user_props.user_count(get_quick_count()),           // DefaultProp
    user_props.search_filters(get_current_filters()),   // DefaultProp
    user_props.analytics(compute_analytics(db)),        // OptionalProp
    user_props.activity_feed(get_recent_activity(db)),  // DeferredProp("activity")
    user_props.growth_stats(compute_growth_stats(db)),  // DeferredProp("analytics")
    user_props.user_list_page(users, pagination),       // MergeProp
  ]
  
  req
  |> inertia.response_builder("Users/Dashboard")
  |> inertia.props(props, user_props.user_prop_to_json)
  |> inertia.response()
}
```

#### New Prop Types
```gleam
pub type UserProp {
  // Existing props...
  UserList(List(users.User))
  UserCount(Int)
  
  // New advanced props
  UserAnalytics(UserAnalytics)        // OptionalProp/DeferredProp
  ActivityFeed(List(Activity))        // DeferredProp("activity")
  SearchFilters(SearchFilters)        // DefaultProp
  PaginatedUsers(PaginatedUsers)      // MergeProp
  GrowthStats(GrowthStats)           // DeferredProp("analytics")
}
```

#### Factory Functions
```gleam
// OptionalProp factories
pub fn analytics(data: UserAnalytics) -> types.Prop(UserProp) {
  types.OptionalProp("analytics", UserAnalytics(data))
}

// DeferredProp factories
pub fn activity_feed(fn: fn() -> List(Activity)) -> types.Prop(UserProp) {
  types.DeferredProp("activity_feed", option.None, fn)
}

pub fn growth_stats(fn: fn() -> GrowthStats) -> types.Prop(UserProp) {
  types.DeferredProp("growth_stats", option.Some("analytics"), fn)
}

// MergeProp factories
pub fn paginated_users(users: PaginatedUsers) -> types.Prop(UserProp) {
  types.MergeProp("users", users, MergeOptions(append: True, deep: False))
}
```

### Test Strategy

#### Unit Tests per Prop Type
- **OptionalProp**: Test exclusion/inclusion based on request type
- **DeferredProp**: Test initial exclusion, deferred evaluation, grouping
- **MergeProp**: Test merge metadata, client-side merge behavior

#### Integration Tests
- **Dashboard flow**: Complete user journey with all prop types
- **Performance tests**: Ensure deferred props improve page load times
- **Frontend integration**: Test actual browser behavior with prop merging

#### TDD Workflow
1. **RED**: Write failing tests for each prop type
2. **GREEN**: Implement minimal functionality to pass tests
3. **REFACTOR**: Optimize for performance and user experience
4. **REPEAT**: Iterate through each prop type systematically

### Success Criteria

#### Functional Requirements
- [ ] OptionalProp excluded by default, included on partial reload with "only"
- [ ] DeferredProp excluded initially, available in metadata, evaluates on partial reload
- [ ] MergeProp provides merge metadata for client-side merging
- [ ] All prop types work seamlessly with Response Builder API
- [ ] Frontend demonstrates real-world usage of each prop type

#### Performance Requirements  
- [ ] Initial page load under 200ms (deferred props excluded)
- [ ] Search results under 100ms (using OptionalProp efficiently)
- [ ] Pagination merges without UI flicker (using MergeProp)
- [ ] Deferred prop groups load independently without blocking

#### User Experience Requirements
- [ ] Smooth loading states for deferred content
- [ ] Instant search with progressive enhancement
- [ ] Infinite scroll that feels native
- [ ] No data loss during partial reloads

### Documentation Focus

#### API Examples
- Complete examples of each prop type with Response Builder API
- Migration patterns from basic props to advanced props
- Performance optimization techniques

#### Best Practices
- When to use each prop type for optimal UX
- Grouping strategies for deferred props  
- Merge strategies for different data types
- Error handling for advanced prop scenarios

#### Frontend Integration
- React hooks for handling deferred props
- TypeScript patterns for prop type safety
- Testing strategies for prop merging behavior

This feature will establish our simple-demo as the **definitive reference** for advanced Inertia.js usage with Gleam, showcasing enterprise-ready patterns for performance and user experience optimization.

## Log

*Implementation notes and progress will be tracked here during development.*

## Conclusion

*Final implementation summary and lessons learned will be documented here upon completion.*