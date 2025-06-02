# Feature 018: Idiomatic Typed Props API

## Plan

### Overview
Refactor the inertia.gleam API to make it more idiomatic for typed props usage by:
1. Renaming `assign_prop_t` to `prop` for brevity and clarity
2. Adding new convenience functions `optional_prop` and `always_prop` that work with tuples
3. Removing the old untyped prop assignment functions to encourage typed usage
4. Updating all examples and tests to use the new API

### Current State Analysis
The current API has these prop assignment functions:
- `assign_prop_t(ctx, #(key, transformer))` - accepts tuple, uses IncludeDefault
- `assign_prop(ctx, key, transformer)` - separate parameters, uses IncludeDefault  
- `assign_always_prop(ctx, key, transformer)` - separate parameters, uses IncludeAlways
- `assign_optional_prop(ctx, key, transformer)` - separate parameters, uses IncludeOptionally

The typed demo examples use helper functions that return tuples like:
```gleam
pub fn title(t: String) {
  #("title", fn(p) { HomePageProps(..p, title: t) })
}
```

### Proposed Changes

#### 1. Core API Changes in `src/inertia_wisp/inertia.gleam`
- **Rename** `assign_prop_t` → `prop`
- **Add** `optional_prop(ctx, #(key, transformer))` - uses IncludeOptionally
- **Add** `always_prop(ctx, #(key, transformer))` - uses IncludeAlways
- **Remove** `assign_prop`, `assign_always_prop`, `assign_optional_prop`
- Keep `assign_prop_with_include` as internal function

#### 2. New API Structure
```gleam
// Main typed prop functions (public API)
pub fn prop(ctx: InertiaContext(t), name_and_fn: #(String, fn(t) -> t))
pub fn optional_prop(ctx: InertiaContext(t), name_and_fn: #(String, fn(t) -> t))  
pub fn always_prop(ctx: InertiaContext(t), name_and_fn: #(String, fn(t) -> t))

// Internal helper (private)
fn assign_prop_with_include(ctx, key, transformer, include)
```

#### 3. Usage Examples
Before:
```gleam
ctx
|> inertia.assign_prop_t(home.title("Welcome"))
|> inertia.assign_always_prop("auth", fn(props) { HomeProps(..props, auth: user) })
|> inertia.assign_optional_prop("expensive_data", fn(props) { HomeProps(..props, data: compute()) })
```

After:
```gleam
ctx  
|> inertia.prop(home.title("Welcome"))
|> inertia.always_prop(home.auth(user))
|> inertia.optional_prop(home.expensive_data(compute()))
```

#### 4. Files to Update

**Core Library:**
- `src/inertia_wisp/inertia.gleam` - implement new API

**Tests:**
- `test/inertia_edge_cases_test.gleam` - update `assign_prop_t` → `prop`
- All test files using old prop assignment functions

**Examples/Demo:**
- `examples/demo/src/demo.gleam` - migrate from old untyped API
- `examples/demo/src/handlers/uploads.gleam`
- `examples/demo/src/handlers/users/*.gleam` 
- `examples/demo/src/handlers/utils.gleam`

**Examples/Typed-Demo:**
- `examples/typed-demo/backend/src/auth/handlers.gleam` - update `assign_prop_t` → `prop`
- `examples/typed-demo/backend/src/blog/handlers.gleam`
- `examples/typed-demo/backend/src/contact/handlers.gleam`
- `examples/typed-demo/backend/src/dashboard/handlers.gleam`
- `examples/typed-demo/backend/src/users/handlers/*.gleam`

**Shared Types (typed-demo):**
- Update comments in shared_types modules that reference `assign_prop_t`

#### 5. Migration Strategy
1. **Phase 1**: Add new functions alongside existing ones
2. **Phase 2**: Update all examples and tests to use new API
3. **Phase 3**: Remove old functions
4. **Phase 4**: Verify all examples still compile and work

#### 6. Breaking Changes
This is a breaking change that will require users to:
- Replace `assign_prop_t` with `prop`
- Replace `assign_prop`, `assign_always_prop`, `assign_optional_prop` with typed equivalents
- Create typed prop helper functions if not already using them

#### 7. Benefits
- **Shorter, cleaner API**: `prop()` vs `assign_prop_t()`
- **Consistent tuple-based interface**: All typed functions use same pattern
- **Encourages typed usage**: Removes untyped alternatives
- **Better discoverability**: `always_prop`, `optional_prop` clearly indicate behavior
- **Type safety**: Forces users toward the typed approach

### Implementation Order
1. Implement new functions in `inertia.gleam`
2. Update test files to use new API
3. Update `examples/typed-demo` (already mostly typed)
4. Update `examples/demo` to use typed approach with new API
5. Remove old functions
6. Test all examples compile and run correctly

### Success Criteria
- All examples compile and run without errors
- All tests pass
- API is more concise and intuitive
- Users are guided toward type-safe prop handling
- No functionality is lost in the migration

## Log

### Phase 1: Add new functions alongside existing ones ✅
- Added `prop()` function - main typed prop assignment with default inclusion
- Added `always_prop()` function - typed prop assignment with always inclusion  
- Added `optional_prop()` function - typed prop assignment with optional inclusion
- All new functions follow the same tuple-based pattern as `assign_prop_t`
- Added comprehensive documentation and examples for each function
- Existing functions remain unchanged for backward compatibility

### Phase 2: Update test files ✅
- Updated `test/inertia_edge_cases_test.gleam` to use `prop()` instead of `assign_prop_t()`
- All test function calls migrated successfully
- No other test files were using the old functions

### Phase 3: Update examples/typed-demo ✅
- Updated all handler files to use `prop()` instead of `assign_prop_t()`
- Updated auth, blog, contact, dashboard handlers
- Updated create user, edit profile, show profile handlers  
- Updated comments in shared_types modules to reference new `prop()` function
- All typed-demo examples now use the cleaner API

### Phase 4: Update examples/demo to use typed approach ✅
- Added comprehensive typed prop helper functions to `props.gleam`
- Created helper functions for all prop types: HomeProps, AboutProps, VersionedProps, UserProps, UploadProps, DemoFeaturesProps
- Updated `demo.gleam` main handlers to use new typed API with helper functions
- Updated all user handlers, upload handlers, and utils module
- Migrated from untyped `assign_*_prop` functions to typed `prop()`, `always_prop()`, and `optional_prop()`
- Code is now more concise and type-safe

### Phase 5: Update all tests and remove deprecated functions ✅
- Updated all remaining test files to use new typed API:
  - `inertia_test.gleam` - Added comprehensive helper functions for MainTestProps
  - `testing_utilities_test.gleam` - Added helper functions for TestingProps
  - Fixed component names and test assertions to match new API usage
- Completely removed deprecated functions from `inertia.gleam`:
  - Removed `assign_prop`, `assign_always_prop`, `assign_optional_prop`
  - Removed `assign_prop_t` (the old typed function)
- Updated missed file `home/handlers.gleam` in typed-demo example
- All 60 tests pass successfully
- All examples compile and work correctly
- **Breaking change complete** - old functions no longer available

### Final API Summary
**New Functions:**
- `prop()` - Default inclusion behavior with tuple interface
- `always_prop()` - Always included props with tuple interface  
- `optional_prop()` - Optional inclusion props with tuple interface

**Removed Functions (Breaking Changes):**
- `assign_prop_t()` - Replaced by `prop()`
- `assign_prop()` - Replaced by typed approach with `prop()`
- `assign_always_prop()` - Replaced by typed approach with `always_prop()`
- `assign_optional_prop()` - Replaced by typed approach with `optional_prop()`

## Conclusion

✅ **Implementation Complete and Successful**

The inertia.gleam API has been successfully modernized to provide a more idiomatic typed props experience. The new API is:

**More Concise:**
```gleam
// Before
|> inertia.assign_prop_t(home.title("Welcome"))
|> inertia.assign_always_prop("auth", fn(props) { HomeProps(..props, auth: user) })

// After  
|> inertia.prop(home.title("Welcome"))
|> inertia.always_prop(home.auth(user))
```

**Type-Safe:** The new API encourages the use of typed helper functions, making prop assignment both safer and more discoverable.

**Consistent:** All three functions (`prop`, `always_prop`, `optional_prop`) use the same tuple-based interface pattern.

**Breaking Changes:** Old functions have been completely removed to enforce the new idiomatic approach.

**Benefits Achieved:**
- Reduced API surface area with cleaner intent
- Shorter, more readable function names
- Consistent tuple-based interface across all typed functions  
- Enhanced discoverability with descriptive function names
- Enforced migration to type-safe prop handling
- Clean, modern API without legacy baggage
- All examples demonstrate best practices with the new API

The implementation successfully modernizes the API while maintaining all functionality, providing a cleaner, more intuitive developer experience that encourages type-safe prop handling.