# Inertia.js Gleam + Wisp Implementation Plan

## Project Overview

Port the inertia-phoenix package to Gleam and the Wisp web framework, providing a seamless way to build modern single-page applications with server-side routing.

## Incremental Development Phases

### Phase 0: Minimal Proof of Concept (Days 1-2)

#### Step 0.1: Basic Project Setup
- [x] Update `gleam.toml` with minimal dependencies
- [x] Create basic project structure
- [x] Set up development environment

#### Step 0.2: Simplest Inertia Response ✅ COMPLETED
**Goal**: Handle a request and respond with `render_inertia("ComponentName")` with no props

**Files created**:
- [x] `src/inertia_gleam/types.gleam` - Basic Page type
- [x] `src/inertia_gleam/middleware.gleam` - Minimal Inertia detection
- [x] `src/inertia_gleam/controller.gleam` - Basic render_inertia function
- [x] `src/inertia_gleam/json.gleam` - JSON serialization
- [x] `src/inertia_gleam/html.gleam` - HTML template generation
- [x] `src/inertia_gleam.gleam` - Main public API
- [x] `examples/minimal/main.gleam` - Simple web server

**Success criteria**:
- [x] GET `/` returns HTML with `<div id="app" data-page="...">` for browser requests
- [x] GET `/` with `X-Inertia: true` returns JSON `{"component": "Home", "props": {}, "url": "/", "version": "1"}`

#### Step 0.3: React Frontend Integration ✅ COMPLETED
- [x] Create minimal React app that can consume the Inertia responses
- [x] Test initial page load and XHR navigation
- [x] Document setup process

### Phase 1: Basic Props & Navigation (Days 3-5)

#### Step 1.1: Static Props Support
**Goal**: `render_inertia("ComponentName", %{"user" => "John"})`

**Enhancements**:
- Extend `render_inertia` to accept props map
- JSON serialization for props
- Props in both HTML data-page and XHR responses

#### Step 1.2: Assign Props Pattern
**Goal**: Pipe-friendly prop assignment

```gleam
request
|> assign_prop("user", user_data)
|> assign_prop("posts", posts_data)
|> render_inertia("Dashboard")
```

#### Step 1.3: Basic Navigation
**Goal**: Multiple routes working with Inertia

- Router integration with Wisp
- Multiple components
- Client-side navigation between pages

### Phase 2: Advanced Props System (Days 6-8)

#### Step 2.1: Lazy Props (Optional)
**Goal**: Props that are only evaluated when requested

```gleam
request
|> assign_prop("user", user_data)
|> assign_optional_prop("expensive_data", fn() { calculate_expensive_data() })
|> render_inertia("Dashboard")
```

#### Step 2.2: Always Props
**Goal**: Props included in every request

```gleam
request
|> assign_always_prop("auth", auth_data)
|> assign_prop("page_data", page_data)
|> render_inertia("Dashboard")
```

#### Step 2.3: Partial Reloads
**Goal**: Request only specific props on navigation

- Detect `X-Inertia-Partial-Data` header
- Only include requested props in response
- Optimize performance for large datasets

### Phase 3: Forms & Validation (Days 9-11)

#### Step 3.1: Form Handling
**Goal**: POST requests through Inertia

- Handle form submissions
- Redirect after POST
- Flash messages

#### Step 3.2: Validation Errors
**Goal**: Display validation errors in frontend

```gleam
request
|> assign_errors(changeset_or_error_map)
|> render_inertia("CreateUser")
```

#### Step 3.3: File Uploads
**Goal**: Handle multipart form data

- File upload support
- Progress tracking
- Validation for files

### Phase 4: Advanced Features (Days 12-15)

#### Step 4.1: Redirects & External Navigation
**Goal**: Proper redirect handling

- External redirects (409 + X-Inertia-Location)
- Internal redirects
- History management

#### Step 4.2: Asset Versioning
**Goal**: Automatic page reloads when assets change

- Asset hash generation
- Version mismatch detection
- Automatic refresh

#### Step 4.3: Error Pages & HTTP Status
**Goal**: Proper error handling

- 404 pages through Inertia
- 500 error pages
- Custom error components

### Phase 5: Performance & Polish (Days 16-20)

#### Step 5.1: Caching & Optimization
- Response caching strategies
- Prop serialization optimization
- Memory usage optimization

#### Step 5.2: Developer Experience
- Better error messages
- Debug mode
- Development tools

#### Step 5.3: Configuration System
- Runtime configuration
- Environment-specific settings
- Default value management

## File Structure Plan

```
src/inertia_gleam/
├── inertia_gleam.gleam          # Main public API
├── types.gleam                  # Core types and records
├── middleware.gleam             # Wisp middleware functions
├── controller.gleam             # Request/response helpers
├── html.gleam                   # HTML template generation
├── json.gleam                   # JSON serialization
├── props.gleam                  # Property system
├── errors.gleam                 # Error handling
├── redirect.gleam               # Redirect helpers
├── version.gleam                # Asset versioning
└── internal/
    ├── utils.gleam              # Internal utilities
    └── serialization.gleam      # Internal serialization

examples/
├── minimal/                     # Phase 0 example
├── blog/                        # Full-featured example
└── todo/                        # Tutorial example

test/
├── unit/                        # Unit tests per module
├── integration/                 # Full request/response tests
└── browser/                     # End-to-end browser tests
```

## Dependencies by Phase

### Phase 0 (Minimal):
```toml
wisp = "~> 1.6"
gleam_http = "~> 3.6"
gleam_json = "~> 1.0"
mist = "~> 2.0"  # for examples
```

### Phase 1-2 (Props & Navigation):
```toml
gleam_stdlib = ">= 0.44.0"
```

### Phase 3-4 (Forms & Advanced):
```toml
gleam_crypto = "~> 1.0"  # for signatures
simplifile = "~> 2.0"    # for file handling
```

### Phase 5 (Polish):
```toml
logging = "~> 1.2"       # for debug logging
```

## Testing Strategy

### Unit Testing
- Each module has comprehensive unit tests
- Property-based testing for JSON serialization
- Mock HTTP requests/responses

### Integration Testing
- Full request/response cycles
- Multiple routes and navigation
- Form submission flows

### Browser Testing
- Selenium/Playwright tests
- Real browser navigation
- JavaScript integration testing

### Performance Testing
- Large dataset handling
- Memory usage profiling
- Response time benchmarks

## Success Metrics

### Phase 0: ✅ COMPLETED
- [x] Basic HTTP server responds correctly to Inertia requests
- [x] React frontend can consume responses
- [x] Documentation for setup

### Phase 1:
- [ ] Props system works with complex data
- [ ] Navigation between multiple pages
- [ ] No memory leaks with repeated navigation

### Phase 2:
- [ ] Lazy props reduce initial load time by >50%
- [ ] Partial reloads work correctly
- [ ] Always props included automatically

### Phase 3:
- [ ] Form submissions work end-to-end
- [ ] Validation errors display properly
- [ ] File uploads complete successfully

### Phase 4:
- [ ] All redirect types work correctly
- [ ] Asset versioning triggers reloads
- [ ] Error pages render through Inertia

### Phase 5:
- [ ] Performance matches Phoenix implementation
- [ ] Developer experience is smooth
- [ ] Configuration system is flexible

## Risk Mitigation

### Technical Risks:
1. **JSON serialization complexity** - Start simple, add complexity incrementally
2. **Wisp API changes** - Pin versions, maintain compatibility layer
3. **React integration issues** - Use official Inertia.js client library

### Timeline Risks:
1. **Scope creep** - Stick to defined phases, defer non-essential features
2. **Testing complexity** - Start with manual testing, automate incrementally
3. **Documentation debt** - Document as we build, not after

## Delivery Schedule

- **Week 1**: Phases 0-1 (✅ Proof of concept + basic props)
- **Week 2**: Phases 2-3 (Advanced props + forms)
- **Week 3**: Phase 4 (Advanced features)
- **Week 4**: Phase 5 (Polish + documentation)

Each phase includes:
- Implementation
- Testing
- Documentation updates
- Example updates