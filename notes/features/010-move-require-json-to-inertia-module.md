# Move require_json Function to Inertia Module

## Plan

### Overview
Move the `require_json` utility function from the shared utility modules into the main `inertia.gleam` module to consolidate JSON handling functionality and reduce duplication across examples.

### Current State Analysis
The `require_json` function currently exists in two locations:
1. `examples/demo/src/handlers/utils.gleam` 
2. `examples/typed-demo/src/backend/src/shared/json_utils.gleam`

Both implementations are identical and provide a convenient wrapper around Wisp's `require_json` that:
- Takes an `InertiaContext` and a decoder
- Handles JSON parsing and decoding
- Returns a bad request response on decode failure
- Continues with the decoded value on success

### Usage Analysis
The function is currently used in:
- `examples/demo/src/handlers/users/create_handler.gleam`
- `examples/demo/src/handlers/users/edit_handler.gleam`
- `examples/typed-demo/src/backend/src/auth/handlers.gleam`
- `examples/typed-demo/src/backend/src/contact/handlers.gleam`
- `examples/typed-demo/src/backend/src/users/handlers/create_user_handlers.gleam`
- `examples/typed-demo/src/backend/src/users/handlers/edit_profile_handlers.gleam`

### Implementation Steps
1. **Add the function to `inertia.gleam`**:
   - Import required modules (`gleam/dynamic/decode`, `wisp`)
   - Add the `require_json` function to the public API
   - Ensure proper documentation

2. **Update example imports**:
   - Replace `utils.require_json` calls with `inertia.require_json` in demo example
   - Replace `json_utils.require_json` calls with `inertia.require_json` in typed-demo example
   - Update import statements in all affected handler files

3. **Remove redundant utility modules**:
   - Remove `json_utils.gleam` from typed-demo (if it only contains `require_json`)
   - Consider removing `utils.gleam` from demo if it only contains `require_json`
   - Update any other imports that might reference these removed functions

4. **Verify functionality**:
   - Ensure all examples still compile
   - Test JSON handling functionality remains intact

### Benefits
- **Consolidation**: Single source of truth for JSON handling utilities
- **API Consistency**: Part of the main inertia module API
- **Reduced Duplication**: Eliminates duplicate implementations
- **Better Discoverability**: Users can find JSON utilities in the main module

### Considerations
- This is a breaking change for users who might be importing from the utility modules
- Need to ensure the function signature remains compatible with existing usage
- Should consider if other utility functions should also be moved to the main module

## Log

### Implementation Completed

**Step 1: Added require_json function to inertia.gleam**
- Added `import gleam/dynamic/decode` to the imports section
- Added the `require_json` function with comprehensive documentation
- Placed it logically after the redirect functions and before SSR functions
- Function signature: `require_json(ctx: InertiaContext(props), decoder: decode.Decoder(a), cont: fn(a) -> Response) -> Response`

**Step 2: Updated all handler imports**
Updated the following files to use `inertia.require_json` instead of utility module versions:
- `examples/demo/src/handlers/users/create_handler.gleam`
- `examples/demo/src/handlers/users/edit_handler.gleam`
- `examples/typed-demo/src/backend/src/auth/handlers.gleam`
- `examples/typed-demo/src/backend/src/contact/handlers.gleam`
- `examples/typed-demo/src/backend/src/users/handlers/create_user_handlers.gleam`
- `examples/typed-demo/src/backend/src/users/handlers/edit_profile_handlers.gleam`

**Step 3: Cleaned up redundant utility modules**
- Completely removed `examples/typed-demo/src/backend/src/shared/json_utils.gleam` (no longer needed)
- Removed only the `require_json` function from `examples/demo/src/handlers/utils.gleam` (kept other utilities like `require_int` and common props functions)
- Removed unused `gleam/dynamic/decode` import from demo utils.gleam

**Step 4: Verification**
- Both demo and typed-demo examples compile successfully with `gleam check`
- No remaining references to `json_utils.require_json` or `utils.require_json` found
- Main inertia module compiles without errors
- All existing functionality preserved

**Challenges Encountered:**
- Minor syntax error during editing (stray `</edits>` tag) which was quickly resolved
- Had to be careful to preserve other utility functions in demo/utils.gleam that are still being used

**Files Modified:**
- `src/inertia_wisp/inertia.gleam` (added function and import)
- 6 handler files (updated import usage)
- `examples/demo/src/handlers/utils.gleam` (removed require_json function)
- `examples/typed-demo/src/backend/src/shared/json_utils.gleam` (deleted)

## Conclusion

### Implementation Summary
Successfully moved the `require_json` utility function from scattered utility modules into the main `inertia.gleam` module, consolidating JSON handling functionality and improving the API design.

### Key Achievements
- **Consolidated API**: The `require_json` function is now part of the main inertia module, making it easily discoverable for users
- **Eliminated Duplication**: Removed identical implementations from both demo examples
- **Maintained Compatibility**: All existing usage patterns continue to work with just import changes
- **Clean Architecture**: JSON utilities are now logically grouped with other Inertia response utilities

### Technical Implementation
- Added `gleam/dynamic/decode` import to main module
- Implemented `require_json` with comprehensive documentation and examples
- Updated 6 handler files across both example projects
- Removed redundant utility modules while preserving other needed functions
- Verified successful compilation of all affected code

### Breaking Changes
This is a breaking change for any users who were importing `require_json` from utility modules, but the migration path is straightforward:
- Change `import shared/json_utils` to use `inertia.require_json`
- Change `import handlers/utils` to use `inertia.require_json`

### Future Considerations
This refactoring establishes a pattern for consolidating utility functions into the main module. Other utility functions like `require_int` could potentially be moved as well if they prove to be commonly needed across projects.

The `require_json` function is now a first-class citizen of the Inertia API, making JSON form handling more discoverable and consistent across applications.