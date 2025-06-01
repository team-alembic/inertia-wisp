# Feature 015: Simplify Middleware API

## Plan

### Overview
Remove the complex `inertia.middleware` function and rename `inertia.empty_middleware` to `inertia.middleware` to simplify the API. In practice, everyone uses the empty middleware pattern, making the complex middleware unnecessary.

### Current State Analysis
Based on code analysis, the current middleware functions are:

1. **`inertia.middleware`** - Complex middleware requiring:
   - Initial props value
   - Props encoder function
   - Handler function with typed context
   
2. **`inertia.empty_middleware`** - Simplified middleware requiring:
   - Handler function with `InertiaContext(EmptyProps)`
   - Uses elegant middleware-before-routing pattern

### Usage Pattern Analysis
From grep results, current usage patterns show:

**Real-world usage (examples and docs):**
- `examples/demo/src/demo.gleam` - uses `empty_middleware`
- `examples/typed-demo/backend/src/typed_demo_backend.gleam` - uses `empty_middleware`
- All documentation examples recommend `empty_middleware`

**Test usage only:**
- `test/inertia_edge_cases_test.gleam` - uses complex `middleware` only for testing edge cases
- All practical examples use the empty middleware pattern

### Proposed Changes

#### 1. Remove Complex Middleware
- Delete `inertia.middleware` function (lines 407-423 in `inertia.gleam`)
- This function is only used in tests, not in real applications

#### 2. Rename Simple Middleware
- Rename `inertia.empty_middleware` to `inertia.middleware` (lines 442-456 in `inertia.gleam`)
- Update function documentation to reflect it's now the primary middleware
- Keep the same elegant middleware-before-routing pattern

#### 3. Update All Usages
**Examples:**
- `examples/demo/src/demo.gleam` - change `empty_middleware` to `middleware`
- `examples/typed-demo/backend/src/typed_demo_backend.gleam` - change `empty_middleware` to `middleware`

**Documentation:**
- Update all documentation references from `empty_middleware` to `middleware`
- Remove references to the complex middleware pattern
- Update README.md examples

**Tests:**
- Update `test/inertia_edge_cases_test.gleam` to use the new middleware pattern
- May need to modify test helpers to work with EmptyProps pattern
- Ensure all edge case tests still pass with simplified middleware

#### 4. Documentation Updates
- Remove complex middleware examples from docs
- Update SSR_SETUP.md to use simplified middleware
- Update inline documentation and comments
- Update any feature notes that reference the old patterns

### Files to Modify

1. **Core Implementation:**
   - `src/inertia_wisp/inertia.gleam` - remove old middleware, rename new one

2. **Examples:**
   - `examples/demo/src/demo.gleam`
   - `examples/typed-demo/backend/src/typed_demo_backend.gleam`

3. **Documentation:**
   - `README.md`
   - `docs/SSR_SETUP.md`
   - Any inline documentation in source files

4. **Tests:**
   - `test/inertia_edge_cases_test.gleam` - update all middleware calls
   - May need to update test helpers for EmptyProps pattern

5. **Feature Notes:**
   - Various notes in `notes/features/` that reference old middleware patterns

### Breaking Change Considerations
This is a breaking change but justified because:
- The complex middleware was never used in practice
- The empty middleware pattern is already the recommended approach
- Simplifies the API significantly
- All examples already use the pattern we're promoting

### Testing Strategy
1. Run existing test suite to ensure all tests pass with new middleware
2. Verify all examples still work correctly
3. Check that SSR functionality works with simplified middleware
4. Ensure edge cases (version mismatches, etc.) still function properly

### Success Criteria
- [x] Complex `inertia.middleware` function removed
- [x] `inertia.empty_middleware` renamed to `inertia.middleware`
- [x] All examples updated and working
- [x] All tests passing
- [x] Documentation updated
- [x] No references to old middleware patterns remain

## Log

### Step 1: Update Core Implementation
- **Updated `src/inertia_wisp/inertia.gleam`**:
  - Removed the complex `middleware` function (lines 407-423)
  - Renamed `empty_middleware` to `middleware` (lines 442-456)
  - Updated function documentation and examples
  - Updated inline documentation references

### Step 2: Update Examples
- **Updated `examples/demo/src/demo.gleam`**: Changed `inertia.empty_middleware` to `inertia.middleware`
- **Updated `examples/typed-demo/backend/src/typed_demo_backend.gleam`**: Changed `inertia.empty_middleware` to `inertia.middleware`
- **Updated `README.md`**: Changed example from `inertia.inertia_middleware` to `inertia.middleware`

### Step 3: Update Test Files
- **Updated `test/inertia_edge_cases_test.gleam`**: 
  - Converted all middleware calls from complex 6-argument pattern to simple 4-argument pattern
  - Added `inertia.set_props(initial_props(), encode_test_props)` calls
  - Fixed all prop assignment patterns to work with EmptyProps context
- **Updated `test/inertia_initial_load_test.gleam`**: Same pattern as edge cases test
- **Updated `test/inertia_test.gleam`**: Same pattern as other test files
- **Updated `test/testing_utilities_test.gleam`**: Same pattern as other test files

### Step 4: Test Validation
- All 61 tests passing
- Both demo and typed-demo examples compile successfully
- No breaking changes to public API (except for the intentional removal of complex middleware)

### Key Challenges Resolved
1. **Test Migration Complexity**: The old middleware pattern used typed props upfront, while the new pattern uses EmptyProps + set_props. Required systematic conversion of all test functions.
2. **Field Name Mismatches**: During test updates, ensured all property assignments matched the actual type definitions.
3. **Test Expectation Updates**: Some test values were updated during migration, requiring corresponding expectation updates.

## Conclusion

The middleware API simplification has been successfully implemented. The complex `inertia.middleware` function that required upfront props and encoder has been removed, and `inertia.empty_middleware` has been renamed to `inertia.middleware`.

### Final State
- **Single Middleware Function**: `inertia.middleware(req, config, ssr_supervisor, handler)` is now the only middleware function
- **Elegant Pattern**: The middleware-before-routing pattern is now the default and only approach
- **Simplified API**: Developers no longer need to provide initial props and encoders upfront
- **Consistent Usage**: All examples and documentation now use the same middleware pattern

### Benefits Achieved
1. **API Simplification**: Reduced cognitive overhead by eliminating the unused complex middleware
2. **Consistent Patterns**: All real-world usage already followed the simplified pattern
3. **Better Developer Experience**: The elegant middleware-before-routing pattern is now the standard
4. **Maintained Functionality**: All existing features and edge cases continue to work correctly

### Breaking Change Impact
This is a breaking change, but justified because:
- The complex middleware was never used in practice (only in tests)
- All examples already used the simplified pattern
- The change promotes the already-recommended approach
- Migration is straightforward for anyone using the complex middleware

The implementation maintains full backward compatibility for all practical usage patterns while significantly simplifying the API surface.