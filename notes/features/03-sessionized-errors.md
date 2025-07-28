# 03 - Cookie-based Errors

## Product Level Requirements

### Business Objectives
- Enable server-side validation error handling that follows Inertia.js conventions
- Provide seamless error display after form submission failures and redirects
- Support enterprise-grade form validation workflows with proper error messaging
- Maintain consistency with Laravel and Phoenix Inertia adapter patterns using cookie storage

## User Level Requirements

### User Motivations
- Developers want validation errors to "just work" after form submission redirects
- Need consistent error handling patterns across different types of forms
- Want to avoid boilerplate code for error passing between request/response cycles
- Expect errors to be automatically available in frontend components

### UX Affordances
- Validation errors appear immediately after form submission without page reload
- Error messages are properly scoped to specific form fields
- Multiple forms on same page don't interfere with each other's error states
- Error display follows standard Inertia.js patterns (reactive props)

### Interaction Patterns
- Form submission → server validation → redirect with errors in session → errors displayed
- Errors automatically cleared on successful form submission
- Error bag scoping for multiple forms: `errors.createUser.name` vs `errors.editUser.name`
- Standard Inertia.js onError callback triggering when errors are present

## Architectural Constraints

### System Integration
- Must integrate with wisp's existing cookie management
- Should work seamlessly with current InertiaResponseBuilder patterns
- Need to maintain backward compatibility with existing `errors()` function
- Must follow Inertia.js protocol for error prop sharing

### Technical Constraints
- Leverage Gleam's type system for compile-time error safety
- Cookie storage must handle serialization/deserialization of error structures
- Support for different error data types (Dict, custom types, validation results)
- Memory efficient - don't persist errors longer than necessary

### Project Location
- **Implementation Path**: `inertia-wisp/src/inertia_wisp/`
- **Dependencies**: wisp cookie management, existing response builder, gleam/dict

## Implementation Design

### Domain Model

```gleam
// Simple cookie-based error handling - no new types needed!
// Use existing Dict(String, String) from response builder
// Error bags are just automatic nesting based on request headers

// Cookie storage handled internally by framework
// No new public API - existing errors() function unchanged
```

### Workflows

#### Simple Form Validation Flow
1. User submits form via Inertia
2. Server validates form data, validation fails
3. Framework automatically stores errors in cookie during redirect
4. Browser follows redirect back to form page
5. Response builder automatically retrieves cookie errors
6. If `X-Inertia-Error-Bag` header present, errors get nested: `{"bagName": errors}`
7. If no header, errors used directly
8. Frontend displays errors and triggers onError callback

#### Error Bag Workflow (Automatic)
1. Frontend specifies error bag: `router.post('/users', data, {errorBag: 'createUser'})`
2. This sends `X-Inertia-Error-Bag: createUser` header automatically
3. Backend detects header and nests errors under bag name
4. Result: `props.errors.createUser.fieldName` instead of `props.errors.fieldName`

### Pages/Components

#### Cookie Integration
- Simple functions to store/retrieve Dict(String, String) from cookies
- Automatic cleanup of errors after use
- No complex managers or state tracking needed

#### Response Builder Enhancement
- Add automatic cookie error retrieval to existing `response()` function
- Detect `X-Inertia-Error-Bag` header and nest errors when present
- Keep existing `errors()` function unchanged for request errors

### Backend Modules

#### `inertia_wisp/response_builder` (enhanced)
- Internal `store_errors_in_cookie/2` - Store Dict(String, String) in cookie
- Internal `retrieve_errors_from_cookie/1` - Get errors from cookie and clear them
- Enhanced `response/2` - Automatically retrieve cookie errors if no request errors set
- Enhanced `redirect/2` - Store errors in cookie and return Response (not ResponseBuilder)
- Error bag detection via `X-Inertia-Error-Bag` header (automatic nesting)
- Keep existing `errors/2` function unchanged for request errors

## Testing Plan

### TDD Integration Tests (Testing Private Functions Indirectly)
- Test redirect with errors stores them in cookie via handler workflow
- Test form display retrieves cookie errors automatically via handler workflow
- Error bag naming and scoping logic via request headers
- Error serialization/deserialization from cookie via full request cycle
- Automatic error clearing after successful responses

### Integration Tests (Full Workflow)
- Complete form submission → validation failure → redirect → error display workflow
- Multiple forms with error bags on same page using X-Inertia-Error-Bag header
- Error persistence across request/response cycles with cookie storage
- Cookie cleanup and memory management across multiple requests
- Verify compatibility with existing request error assignment patterns

## Implementation Tasks

### Phase 1: Cookie Storage Functions
- [ ] Add internal cookie functions to `response_builder.gleam` for Dict(String, String)
- [ ] Add cookie error serialization/deserialization using wisp cookie API
- [ ] Test error storage and retrieval with automatic cleanup
- [ ] Test cookie behavior across request/response cycles

### Phase 2: Response Builder Auto-Retrieval and Redirect Enhancement
- [ ] Enhance `response()` function to automatically retrieve errors from cookie
- [ ] Change `redirect()` function to store errors in cookie and return Response
- [ ] Add `X-Inertia-Error-Bag` header detection and error nesting logic
- [ ] Ensure existing `errors()` function overrides cookie errors when called
- [ ] Add integration tests using handler patterns with redirect and form display

### Phase 3: Integration Testing
- [ ] Test complete form validation workflow with cookie storage
- [ ] Test error bag functionality with multiple forms
- [ ] Test error cleanup and memory management
- [ ] Verify compatibility with existing request error assignment
