# 001 - Eval Function Implementation

## Plan

### Overview
Implement the `eval` function in `inertia_wisp/inertia.gleam` that processes a list of props based on the request context and returns a Page object. This is a core function that handles prop evaluation, partial reloads, deferred props, and builds the appropriate page response structure.

### Function Signature
```gleam
pub fn eval(req: Request, props: List(types.Prop(p))) -> Page(p)
```

### Requirements Analysis

Based on the Inertia.js documentation and existing codebase:

1. **Prop Type Handling**: Support all prop types defined in `types.gleam`:
   - `DefaultProp`: Always included on standard visits, optionally on partial reloads, always evaluated
   - `LazyProp`: Always included on standard visits, optionally on partial reloads, only evaluated when needed
   - `OptionalProp`: Never included on standard visits, optionally on partial reloads, only evaluated when needed
   - `AlwaysProp`: Always included on standard and partial reloads, always evaluated
   - `DeferProp`: Deferred props fetched in separate requests, with optional grouping
   - `MergeProp`: Wrapper indicating client-side merging behavior

2. **Request Context Processing**:
   - Detect if request is an Inertia XHR request vs initial page load
   - Handle partial reload headers (`X-Inertia-Partial-Data`, `X-Inertia-Partial-Component`)
   - Build URL from request path segments
   - Extract component name (parameter needed)

3. **Page Object Construction**:
   - Component name (from parameter)
   - Evaluated props list
   - Deferred props list (names only)
   - Encode function (from parameter)
   - URL from request path
   - Version (default or from config)
   - History flags (defaults)

### Implementation Strategy

1. **Parse Request Headers**: Extract partial reload information using existing middleware functions
2. **Filter Props**: Determine which props should be included based on request type and partial reload settings
3. **Evaluate Props**: Only evaluate props that are needed (respecting lazy evaluation)
4. **Build Deferred List**: Extract deferred prop names for client-side requests
5. **Construct Page**: Build final Page object with all required fields

### Core Logic Flow

```gleam
pub fn eval(req: Request, component: String, props: List(types.Prop(p)), encode_prop: fn(p) -> #(String, json.Json)) -> Page(p) {
  let is_inertia = middleware.is_inertia_request(req)
  let partial_data = middleware.get_partial_data(req)
  let is_partial = !list.is_empty(partial_data)
  
  let #(evaluated_props, deferred_props) = 
    props 
    |> filter_props_for_request(is_inertia, is_partial, partial_data)
    |> evaluate_and_separate_props()
  
  let url = build_url_from_request(req)
  
  Page(
    component: component,
    props: evaluated_props,
    deferred_props: deferred_props,
    encode_prop: encode_prop,
    url: url,
    version: "1", // Default, should come from config
    encrypt_history: False,
    clear_history: False,
  )
}
```

### Updated Function Signature
The function needs additional parameters:
- `component`: String (component name)
- `encode_prop`: Encoder function

### Test Coverage Plan

1. **Basic Functionality**:
   - Standard visits with different prop types
   - Proper URL construction
   - Default values for version/history flags

2. **Partial Reloads**:
   - Only requested props included
   - Except behavior
   - Component matching

3. **Prop Type Behavior**:
   - DefaultProp: included on standard, optional on partial
   - LazyProp: lazy evaluation
   - OptionalProp: never on standard, optional on partial
   - AlwaysProp: always included
   - DeferProp: deferred handling
   - MergeProp: wrapper behavior

4. **Edge Cases**:
   - Empty prop lists
   - Invalid partial data
   - Non-Inertia requests

### Dependencies
- `inertia_wisp/internal/middleware` for request parsing
- `gleam/string` for URL construction
- `gleam/list` for prop filtering
- `wisp` for path segments

### Breaking Changes
The current function signature is a stub and needs to be updated to include the component name and encoder function parameters.

## Log

### Implementation Process

1. **Updated Function Signature**: Changed from the stub to include required parameters:
   ```gleam
   pub fn eval(
     req: Request,
     component: String, 
     props: List(types.Prop(p)),
     encode_prop: fn(p) -> #(String, json.Json),
   ) -> Page(p)
   ```

2. **Core Implementation Structure**: 
   - Parse request headers using existing middleware functions
   - Determine if partial reload should be applied (component matching)
   - Filter props based on request type and partial reload settings
   - Evaluate props and separate into evaluated vs deferred lists
   - Build URL from request path segments
   - Construct Page object with defaults

3. **Key Implementation Insights**:
   - **Deferred Props for Non-Inertia Requests**: Initially thought deferred props should be excluded for initial page loads, but realized they should be included in `deferred_props` list so client can fetch them after JavaScript hydration
   - **Partial Reload Component Matching**: Only apply partial reload filtering when component matches the requested component
   - **Prop Type Filtering**: Different prop types have different inclusion rules based on request type:
     - OptionalProp: Only included on partial reloads when explicitly requested
     - DeferProp: Never evaluated immediately, always goes to deferred list for Inertia requests
     - AlwaysProp: Always included regardless of request type
     - MergeProp: Acts as wrapper, delegates to inner prop behavior

4. **Test Coverage Implemented**:
   - 19 comprehensive test cases covering all scenarios
   - Basic functionality (component, URL, defaults)
   - Different request types (Inertia vs non-Inertia)
   - Partial reload scenarios with component matching
   - All prop types and their behaviors
   - Edge cases (empty lists, lazy evaluation)
   - Deferred props with grouping

5. **Issues Resolved**:
   - Initially filtered out deferred props completely, needed to pass them through for separation
   - Fixed test expectations around deferred props for non-Inertia requests
   - Handled lazy evaluation correctly to avoid unnecessary computation
   - **Critical Fix**: Corrected partial reload logic to require component header - changed `True, option.None -> True` to `True, option.None -> False` per Inertia.js documentation requirements
   - **Laravel Compatibility**: Updated Page structure to match Laravel Inertia adapter by adding `merge_props`, `deep_merge_props`, `match_props_on` fields and changing `deferred_props` to grouped structure

### Technical Decisions

- **URL Construction**: Used `wisp.path_segments(req) |> string.join("/")` with "/" prefix
- **Default Values**: Version "1", encrypt_history False, clear_history False
- **Prop Filtering Logic**: Three-way case analysis (standard Inertia, partial reload, non-Inertia)
- **Component Matching**: Strict equality check for partial reload component matching

## Conclusion

### Successfully Implemented

The `eval` function has been fully implemented and tested with comprehensive coverage. After fixing a critical issue with partial reload component matching, the implementation correctly handles:

1. **All Prop Types**: Proper evaluation and filtering for DefaultProp, LazyProp, OptionalProp, AlwaysProp, DeferProp, and MergeProp
2. **Request Type Detection**: Differentiates between Inertia XHR requests and initial page loads
3. **Partial Reload Support**: Honors `X-Inertia-Partial-Data` and `X-Inertia-Partial-Component` headers with proper component matching requirement
4. **Deferred Props**: Correctly separates deferred props for client-side loading
5. **Lazy Evaluation**: Only evaluates props when they will actually be included
6. **URL Construction**: Builds proper URLs from request path segments

### Final Function Signature

```gleam
pub fn eval(
  req: Request,
  component: String,
  props: List(types.Prop(p)),
  encode_prop: fn(p) -> #(String, json.Json),
) -> Page(p)
```

### Breaking Changes Applied

- Added `component` parameter for component name
- Added `encode_prop` parameter for prop encoding function
- These are necessary for proper Page object construction

### Test Results

All 20 tests pass, covering:
- Basic functionality and defaults
- URL construction for various paths
- Standard vs partial Inertia requests  
- Component matching for partial reloads
- All prop type behaviors
- Deferred props handling
- Edge cases and error conditions
- Partial reload behavior without component header (falls back to standard request)

### Laravel Compatibility

Updated the Page structure to match the Laravel Inertia adapter after analyzing the official test suite:

- **Deferred Props Structure**: Changed from flat array `["prop1", "prop2"]` to grouped object `{"default": ["prop1"], "group1": ["prop2"]}`
- **Added `merge_props`**: Array of prop names that should be merged client-side
- **Added `deep_merge_props`**: Array of prop names that should be deep merged
- **Added `match_props_on`**: Array of match strategies like `["prop.key"]` for merge matching

### Integration Ready

The function is ready for integration with the existing Inertia adapter and can be used by higher-level functions like `render` and context builders. The implementation follows Inertia.js protocol specifications exactly, including the requirement that partial reloads must include the component header for safety, and maintains full compatibility with the Laravel Inertia adapter's response structure.