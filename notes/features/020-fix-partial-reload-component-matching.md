# Fix Partial Reload Component Matching

## Plan

### Issue Description
The current partial reload implementation in `inertia-wisp` does not conform to the Inertia.js protocol specification. According to the protocol, partial reloads should only occur when the `X-Inertia-Partial-Component` header matches the component being rendered. If the component differs from the header value, it should be treated as a regular page load, not a partial reload.

### Current Implementation Problems
1. The `evaluate_props` function in `controller.gleam` only checks if partial data is requested (`X-Inertia-Partial-Data`) but ignores the component matching requirement
2. There's no function to extract the `X-Inertia-Partial-Component` header value
3. The partial reload logic doesn't validate that the requested component matches the component being rendered

### Protocol Requirements
- Partial reloads should only happen when `X-Inertia-Partial-Component` header matches the current component
- If components don't match, treat as regular page load (include all `IncludeDefault` props)
- Only include `IncludeOptionally` props when it's a valid partial reload

### Implementation Plan

#### Step 1: Add Component Header Extraction
- Add `get_partial_component(req: Request) -> Option(String)` function to `middleware.gleam`
- Extract the `X-Inertia-Partial-Component` header value

#### Step 2: Update Controller Logic
- Modify `render_typed` function to pass the component name to `evaluate_props`
- Update `evaluate_props` to accept component name and validate component matching
- Change partial reload detection logic to require both partial data AND component match

#### Step 3: Update Prop Evaluation Logic
- Modify `evaluate_props` to check:
  1. Is this an Inertia request?
  2. Does the partial component header match the current component?
  3. Is partial data requested?
- Only treat as partial reload when all conditions are met

#### Step 4: Testing Strategy
- Test partial reload with matching component (should include only requested props)
- Test partial reload with non-matching component (should include all default props)
- Test regular Inertia requests (should include all default props)
- Test non-Inertia requests (should include all default props)

### Files to Modify
1. `inertia-wisp/src/inertia_wisp/internal/middleware.gleam`
   - Add `get_partial_component` function
2. `inertia-wisp/src/inertia_wisp/internal/controller.gleam`
   - Update `render_typed` function signature
   - Update `evaluate_props` function logic

### Expected Behavior After Fix
- Partial reloads only occur when component headers match
- Non-matching components result in full page loads with all default props
- Maintains backward compatibility for existing functionality
- Conforms to official Inertia.js protocol specification

## Log

### Step 1: Add Component Header Extraction ✅
- Added `get_partial_component(req: Request) -> Option(String)` function to `middleware.gleam`
- Function extracts the `X-Inertia-Partial-Component` header value
- Returns `Option(String)` to handle cases where header is not present
- Implementation follows the same pattern as existing `get_partial_data` function

### Step 2: Update Controller Logic ✅
- Modified `render_typed` function to extract partial component header using `middleware.get_partial_component`
- Updated `evaluate_props` function signature to accept:
  - `partial_component: option.Option(String)` - the requested component from header
  - `current_component: String` - the component being rendered
- Added component matching logic: `component_matches = requested_component == current_component`
- Updated partial reload detection to require: Inertia request + partial data + component match
- Now partial reloads only occur when all three conditions are met

### Step 3: Update Prop Evaluation Logic ✅
- Enhanced comments in `evaluate_props` to clearly document the three required conditions:
  1. Is an Inertia request
  2. Has partial data requested (X-Inertia-Partial-Data header)
  3. Component matches (X-Inertia-Partial-Component header matches current component)
- Changed `list.length(partial_data) > 0` to `!list.is_empty(partial_data)` for better idiom
- Verified prop inclusion logic works correctly:
  - `IncludeAlways`: Always included regardless of request type
  - `IncludeDefault`: Included for non-partial reloads OR when specifically requested in partial data
  - `IncludeOptionally`: Only included during valid partial reloads when specifically requested
- Logic now properly handles component mismatch scenarios (treats as regular page load)

### Step 4: Testing Strategy ✅
- Added `partial_component(req: Request, component: String)` function to testing module
- Created comprehensive test file `test/partial_reload_component_matching_test.gleam` with 6 test scenarios:
  1. **Matching component test**: Partial reload with matching component - should include only requested props
  2. **Non-matching component test**: Partial reload with different component - should include all default props
  3. **Regular Inertia request test**: No partial headers - should include all default props
  4. **Non-Inertia request test**: Regular browser request - should include all default props
  5. **Partial data without component test**: Has partial data but no component header - should treat as regular
  6. **Component without partial data test**: Has component header but no partial data - should treat as regular
- Tests cover all three prop inclusion types: `IncludeAlways`, `IncludeDefault`, and `IncludeOptionally`
- Tests verify both JSON responses (Inertia requests) and HTML responses (regular requests)
- All tests demonstrate correct protocol compliance with component matching requirements
- **TESTS PASSING**: All 6 tests compile and pass successfully, confirming the implementation works as expected
- Fixed compilation issues with imports and type definitions to ensure clean test execution

## Conclusion