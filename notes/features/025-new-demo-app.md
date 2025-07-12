# 025 - New Demo Application Plan

## Plan

### Overview
Create a new demo application called "simple-demo" that showcases the new `inertia.eval` API design. This demo will demonstrate how the library can be used without the `InertiaContext` type, instead constructing `Page` objects directly and using regular Wisp functionality.

### Key Differences from Existing Demos

**Current API (examples/demo):**
```gleam
fn home_page(ctx: inertia.InertiaContext(Nil), db: Connection) -> wisp.Response {
  ctx
  |> inertia.with_encoder(home.encode_home_page_prop)
  |> inertia.always_prop("auth", home.Auth(auth_user))
  |> inertia.prop("message", home.Message("Hello"))
  |> inertia.render("Home")
}
```

**New API (simple-demo):**
```gleam
fn home_page(req: wisp.Request, db: Connection) -> wisp.Response {
  let props = [
    types.AlwaysProp("auth", home.Auth(auth_user)),
    types.DefaultProp("message", home.Message("Hello")),
  ]
  let page = inertia.eval(req, "Home", props, home.encode_home_page_prop)
  inertia.render(req, page)
}
```

### Demo Application Structure

```
simple-demo/
├── src/
│   ├── simple_demo.gleam           # Main application
│   ├── handlers/
│   │   ├── home.gleam              # Home page handler
│   │   ├── users.gleam             # User management
│   │   ├── errors.gleam            # Error handling demo
│   │   └── forms.gleam             # Form validation
│   ├── data/
│   │   ├── users.gleam             # User data types
│   │   └── validation.gleam        # Form validation
│   └── props/
│       ├── home_props.gleam        # Home page props
│       ├── user_props.gleam        # User props
│       └── form_props.gleam        # Form props
├── frontend/
│   ├── src/Pages/
│   │   ├── Home.tsx                # React components
│   │   ├── Users/
│   │   │   ├── Index.tsx
│   │   │   ├── Create.tsx
│   │   │   └── Edit.tsx
│   │   └── Errors.tsx
│   └── package.json
├── static/                         # Built assets
└── README.md
```

### Features to Demonstrate

1. **Basic Page Rendering**
   - Simple home page with static props
   - Demonstrate `DefaultProp`, `AlwaysProp`

2. **Dynamic Data**
   - User listing with database queries
   - Demonstrate `LazyProp` for expensive operations

3. **Partial Reloads**
   - User search/filtering
   - Demonstrate `OptionalProp` and partial reload behavior

4. **Error Handling**
   - Form validation errors
   - Demonstrate `inertia.errors()` function

5. **Deferred Props**
   - Dashboard with analytics data
   - Demonstrate `DeferProp` with different groups

6. **Merge Props**
   - Pagination or infinite scroll
   - Demonstrate `MergeProp` behavior

### Implementation Plan

We will follow a test-driven development (TDD) approach with iterative RED-GREEN-REFACTOR cycles for each feature. The workflow will be:

1. **RED**: Write failing tests that specify the expected behavior
2. **GREEN**: Write minimal code to make tests pass (using `todo` stubs initially)
3. **REFACTOR**: Improve code while keeping tests green

#### Project Structure Decision
- **Location**: `examples/simple-demo/` (alongside existing demos)
- **Database**: SQLite in-memory (like current demo)
- **Frontend**: esbuild + React + TypeScript (refer to existing demo frontend/package.json)
- **Scope**: All 6 features implemented in phases

#### Phase 1: Project Setup & Basic Page Rendering (TDD)
**Goal**: Demonstrate `DefaultProp` and `AlwaysProp` with static content

**RED Phase**:
- [ ] Create project structure with empty gleam.toml
- [ ] Create type definitions for home page props (stubbed with `todo`)
- [ ] Create handler functions (stubbed with `todo`)
- [ ] Write failing tests for basic home page functionality:
  - [ ] Test component name is "Home"
  - [ ] Test URL path construction
  - [ ] Test static props are included
  - [ ] Test prop encoding/decoding

**GREEN Phase**:
- [ ] Implement minimal home page handler to pass tests
- [ ] Implement prop encoders to pass tests
- [ ] Implement basic Wisp application structure

**REFACTOR Phase**:
- [ ] Clean up code organization
- [ ] Add documentation and comments
- [ ] Optimize imports

#### Phase 2: Dynamic Data & User Management (TDD)
**Goal**: Demonstrate `LazyProp` and database integration

**RED Phase**:
- [ ] Create user data types (stubbed with `todo`)
- [ ] Create user handler functions (stubbed with `todo`)
- [ ] Write failing tests for user functionality:
  - [ ] Test user listing with database queries
  - [ ] Test lazy prop evaluation only when needed
  - [ ] Test CRUD operations
  - [ ] Test proper JSON encoding of user data

**GREEN Phase**:
- [ ] Implement user data layer (in-memory SQLite)
- [ ] Implement user handlers to pass tests
- [ ] Implement lazy prop resolution

**REFACTOR Phase**:
- [ ] Extract database utilities
- [ ] Improve error handling
- [ ] Add more comprehensive user validation

#### Phase 3: Form Validation & Error Handling (TDD)
**Goal**: Demonstrate `inertia.errors()` function and form handling

**RED Phase**:
- [ ] Create form validation types (stubbed with `todo`)
- [ ] Create form handler functions (stubbed with `todo`)
- [ ] Write failing tests for form validation:
  - [ ] Test successful form submission
  - [ ] Test validation error responses
  - [ ] Test error prop structure in JSON
  - [ ] Test form data preservation on errors

**GREEN Phase**:
- [ ] Implement form validation logic
- [ ] Implement error handling in handlers
- [ ] Make all form tests pass

**REFACTOR Phase**:
- [ ] Extract validation utilities
- [ ] Improve error message formatting
- [ ] Add more validation rules

#### Phase 4: Partial Reloads & Optional Props (TDD)
**Goal**: Demonstrate `OptionalProp` and partial reload behavior

**RED Phase**:
- [ ] Create search/filter types (stubbed with `todo`)
- [ ] Create search handler functions (stubbed with `todo`)
- [ ] Write failing tests for partial reloads:
  - [ ] Test standard request excludes optional props
  - [ ] Test partial request includes only requested props
  - [ ] Test component matching for partial reloads
  - [ ] Test filter/search functionality

**GREEN Phase**:
- [ ] Implement search and filtering logic
- [ ] Implement partial reload handling
- [ ] Make all partial reload tests pass

**REFACTOR Phase**:
- [ ] Optimize search performance
- [ ] Add pagination support
- [ ] Improve user experience

#### Phase 5: Deferred Props & Performance (TDD)
**Goal**: Demonstrate `DeferProp` with different groups

**RED Phase**:
- [ ] Create analytics/dashboard types (stubbed with `todo`)
- [ ] Create dashboard handler functions (stubbed with `todo`)
- [ ] Write failing tests for deferred props:
  - [ ] Test initial request excludes deferred props
  - [ ] Test deferred props appear in deferred_props field
  - [ ] Test subsequent requests include deferred props
  - [ ] Test deferred prop grouping

**GREEN Phase**:
- [ ] Implement expensive analytics calculations
- [ ] Implement deferred prop handling
- [ ] Make all deferred prop tests pass

**REFACTOR Phase**:
- [ ] Add caching for expensive operations
- [ ] Optimize deferred prop groups
- [ ] Add loading states

#### Phase 6: Merge Props & Advanced Features (TDD)
**Goal**: Demonstrate `MergeProp` behavior

**RED Phase**:
- [ ] Create pagination/infinite scroll types (stubbed with `todo`)
- [ ] Create pagination handler functions (stubbed with `todo`)
- [ ] Write failing tests for merge props:
  - [ ] Test merge prop structure in JSON
  - [ ] Test pagination with merge behavior
  - [ ] Test infinite scroll scenarios

**GREEN Phase**:
- [ ] Implement pagination logic
- [ ] Implement merge prop handling
- [ ] Make all merge prop tests pass

**REFACTOR Phase**:
- [ ] Optimize pagination performance
- [ ] Add keyboard navigation
- [ ] Improve user experience

#### Phase 7: Frontend Implementation
**Goal**: Create React components to demonstrate the backend API

- [ ] Set up esbuild + React + TypeScript build system
- [ ] Create components for each demonstrated feature
- [ ] Test integration between backend and frontend
- [ ] Add styling and user experience improvements

#### Phase 8: Documentation & Polish
- [ ] Comprehensive README with TDD examples
- [ ] Code comments explaining API usage patterns
- [ ] Performance comparison notes
- [ ] Migration guide from context-based API

### TDD Guidelines for This Project

1. **Always start with failing tests** - Write tests that specify the exact expected behavior
2. **Use `todo` for initial implementations** - Stub out functions with `todo` to make compilation pass
3. **Make tests pass with minimal code** - Don't over-engineer the initial implementations
4. **Refactor only when tests are green** - Improve code organization and performance after functionality works
5. **Test both success and failure cases** - Include error handling and edge cases in tests
6. **Use `inertia_wisp/testing` utilities** - Leverage the existing testing infrastructure for response validation
7. **Test prop encoding/decoding** - Ensure JSON serialization works correctly for all prop types
8. **Test partial reload behavior** - Verify that partial reloads work as expected with proper headers

### Known Fake Implementations

The following functions contain fake/hardcoded implementations that will need to be replaced in future phases:

- `generate_csrf_token()` - Currently returns a static string, needs proper CSRF token generation
- `get_current_user()` - Currently returns hardcoded demo user data, needs real authentication
- `get_app_version()` - Currently returns hardcoded "1.0.0", should read from build metadata
- `get_navigation_items()` - Currently returns static navigation, may need dynamic routing in future

### Key API Demonstrations

#### 1. Basic Page Construction
```gleam
pub fn home_page(req: wisp.Request) -> wisp.Response {
  let props = [
    types.DefaultProp("title", "Welcome to Simple Demo"),
    types.AlwaysProp("navigation", get_navigation_items()),
  ]
  let page = inertia.eval(req, "Home", props, encode_home_prop)
  inertia.render(req, page)
}
```

#### 2. Error Handling
```gleam
pub fn create_user(req: wisp.Request) -> wisp.Response {
  use form_data <- wisp.require_form(req)
  case validate_user(form_data) {
    Ok(user) -> {
      // Success - redirect
      wisp.redirect("/users")
    }
    Error(validation_errors) -> {
      let props = [types.DefaultProp("form_data", form_data)]
      let page = inertia.eval(req, "Users/Create", props, encode_user_prop)
      let page_with_errors = inertia.errors(page, validation_errors)
      inertia.render(req, page_with_errors)
    }
  }
}
```

#### 3. Deferred Props
```gleam
pub fn dashboard(req: wisp.Request) -> wisp.Response {
  let props = [
    types.DefaultProp("user", get_current_user()),
    types.DeferProp("analytics", option.None, fn() {
      get_expensive_analytics()
    }),
    types.DeferProp("reports", option.Some("background"), fn() {
      generate_reports()
    }),
  ]
  let page = inertia.eval(req, "Dashboard", props, encode_dashboard_prop)
  inertia.render(req, page)
}
```

#### 4. Partial Reloads
```gleam
pub fn users_index(req: wisp.Request) -> wisp.Response {
  let search = wisp.get_query(req) |> dict.get("search") |> result.unwrap("")

  let props = [
    types.AlwaysProp("filters", get_filter_options()),
    types.OptionalProp("users", fn() { search_users(search) }),
    types.DefaultProp("search_term", search),
  ]
  let page = inertia.eval(req, "Users/Index", props, encode_user_prop)
  inertia.render(req, page)
}
```

### Benefits of New API

1. **Explicit Control**: Developers have direct control over Page construction
2. **Regular Wisp Patterns**: Uses standard Wisp request handling
3. **Type Safety**: Props are type-safe with compile-time checking
4. **Composability**: Page objects can be easily transformed and combined
5. **Testability**: Easier to unit test page construction separately from rendering

### Documentation Focus

The demo should emphasize:
- How the new API simplifies reasoning about Inertia responses
- When to use each prop type (`DefaultProp`, `LazyProp`, `OptionalProp`, etc.)
- Error handling patterns
- Performance optimization with deferred and partial props
- Migration path from context-based API

### Success Criteria

1. **Complete Feature Coverage**: All prop types and features demonstrated
2. **Clear Documentation**: Each example well-documented with explanations
3. **Performance Showcase**: Demonstrates lazy evaluation and partial reloads
4. **Error Handling**: Comprehensive form validation examples
5. **Developer Experience**: Easy to understand and modify examples

## Log

### Phase 1: Project Setup & Basic Page Rendering - COMPLETED ✅

**TDD Approach Successfully Applied:**
- **RED Phase**: Created 11 failing tests covering all basic functionality
- **GREEN Phase**: Implemented minimal code to pass each test one-by-one
- **REFACTOR Phase**: Applied Single Responsibility Principle and Single Level of Abstraction

**Final Results:**
- ✅ 11 tests passing, 0 failures
- ✅ Zero compilation warnings
- ✅ Clean, maintainable code structure

**Key Achievements:**
1. **New API Demonstration**: Successfully showcased `inertia.eval()` API with direct Page construction
2. **Prop Type Coverage**: Implemented and tested both `DefaultProp` and `AlwaysProp` types
3. **Response Format Support**: Both JSON (Inertia requests) and HTML (initial loads) working
4. **Type Safety**: Complete type-safe prop encoding/decoding with JSON serialization
5. **Test Quality**: Comprehensive test suite using `assert` patterns and `let assert` for better error reporting

**Technical Implementation:**
- **Handler Module**: Clean separation of HTTP handling from prop construction
- **Props Module**: Modular encoding system with single responsibility functions
- **Main Module**: Proper server configuration and routing abstraction
- **Type Definitions**: Complete prop type system with NavigationItem structure

**Code Quality Improvements:**
- Replaced conditional `assert False` with `let assert` patterns per CLAUDE.md rules
- Applied Single Responsibility Principle to all modules
- Maintained Single Level of Abstraction throughout
- Removed all unused functions and imports
- Zero compilation warnings achieved

**Ready for Phase 2**: Basic page rendering is complete and ready for dynamic data integration.

## Conclusion

*Final implementation details and lessons learned will be documented here*
