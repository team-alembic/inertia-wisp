# Fix #002: Documentation API Mismatch

## Issue

The current documentation in README.md, inertia.gleam module docs, and SSR_SETUP.md does not accurately reflect the actual API provided by the inertia.gleam module. There are several discrepancies:

1. **README.md Issues:**
   - Shows `assign_prop()` function that doesn't exist - actual API uses `prop()`, `always_prop()`, `optional_prop()`
   - Shows outdated prop assignment patterns with JSON values instead of typed union props
   - Missing `with_encoder()` function which is crucial for typed props
   - Shows incorrect middleware usage pattern
   - Examples don't match the actual union type props system used in examples

2. **inertia.gleam Module Documentation Issues:**
   - Module-level docs show outdated examples with record types instead of union types
   - Function examples reference non-existent functions like `assign_prop()`
   - SSR examples show incorrect function signatures
   - Missing documentation for key functions like `with_encoder()`
   - Examples don't show the union type pattern used in actual working examples

3. **SSR_SETUP.md Issues:**
   - Shows outdated SSR configuration patterns
   - Incorrect middleware usage examples
   - Missing proper union type props integration with SSR
   - Examples don't match the actual union type pattern

## Fix

Update all documentation files to accurately reflect the current API:

1. **Update README.md:**
   - Fix Quick Start section to use correct `prop()`, `always_prop()`, `optional_prop()` functions
   - Show proper `with_encoder()` usage for union type props
   - Update middleware examples to match actual signature
   - Fix all code examples to use union type pattern from working examples

2. **Update inertia.gleam module docs:**
   - Fix module-level documentation examples to use union types
   - Update function documentation to show correct union type usage
   - Add missing documentation for `with_encoder()`
   - Ensure all examples match the union type pattern from working examples

3. **Update SSR_SETUP.md:**
   - Fix middleware integration examples
   - Show proper union type props usage with SSR
   - Update configuration examples to match union type pattern

## Conclusion

Successfully updated all documentation files to match the current API with union type props:

1. **README.md Updates:**
   - Fixed Quick Start section to show proper union type props usage with `with_encoder()`
   - Updated prop assignment to use `prop()`, `always_prop()`, `optional_prop()` instead of non-existent `assign_prop()`
   - Changed from record types to union type pattern: `HomePageProp { Message(String) | User(String) | Count(Int) }`
   - Added proper encoder function using pattern matching on union types
   - Fixed middleware usage examples and added Advanced Usage section

2. **inertia.gleam Module Documentation Updates:**
   - Fixed module-level documentation examples to use union types instead of record types
   - Added comprehensive documentation for `with_encoder()` function with union type examples
   - Added proper documentation for `prop()` function with union type usage
   - Updated all function examples to use union type pattern matching in encoders
   - Fixed SSR configuration examples with correct paths and modules
   - All examples now follow the `HomePageProp { Title(String) | Message(String) }` pattern

3. **SSR_SETUP.md Updates:**
   - Fixed SSR build configuration to output correct file
   - Updated middleware integration examples to use current API with union types
   - Added proper union type props integration with SSR showing encoder pattern matching
   - Fixed import statements and function signatures
   - Added complete example with union type HomePageProp and case-based encoder

The documentation now accurately reflects the current union type props system where:
- Props are defined as union types like `pub type HomePageProp { Title(String) | Message(String) }`
- Encoders use pattern matching: `case prop { Title(title) -> json.string(title) }`
- `middleware()` creates `InertiaContext(Nil)`
- `with_encoder()` converts to typed context with union type encoder
- `prop()`, `always_prop()`, `optional_prop()` assign union type values like `Title("Welcome")`

This matches the actual working pattern used in the examples directory and ensures developers can follow the documentation to create working applications.