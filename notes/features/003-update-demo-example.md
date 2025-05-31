# Feature 003: Update Demo Example to New Typed Props API + EmptyProps System

## Plan

### Overview
Update the `examples/demo` project to use the new typed props API that was established in Feature 002, AND implement a new EmptyProps system that allows middleware to be called before routing while maintaining type safety. The demo currently uses deprecated APIs like `assign_always_typed_prop`, `new_typed_context`, `render_typed`, `assign_always_props`, and `set_config` that no longer exist.

### Current Issues Identified
1. **Deprecated API Usage**: Demo uses old APIs that were removed:
   - `inertia.new_typed_context()` → should use `inertia.new_context()`
   - `inertia.assign_always_typed_prop()` → should use `inertia.assign_always_prop()`
   - `inertia.assign_typed_prop()` → should use `inertia.assign_prop()`
   - `inertia.render_typed()` → should use `inertia.render()`
   - `inertia.assign_always_props()` → should use individual `assign_always_prop()` calls
   - `inertia.set_config()` → should pass config directly to middleware

2. **Middleware Pattern**: Demo uses old middleware pattern, needs to use new `inertia.middleware()` with typed context

3. **Props Structure**: Demo has typed props defined but not fully utilizing the new system's benefits

4. **Middleware Type Conflict**: Current typed system requires knowing prop types upfront, but the elegant middleware-before-routing pattern needs to work with different prop types per page

### Migration Strategy

#### Phase 1: Implement EmptyProps System
- Create `EmptyProps` type that serializes to empty JSON object
- Implement `set_props()` function to transform `InertiaContext(EmptyProps)` to `InertiaContext(SpecificProps)`
- Update middleware to use EmptyProps by default
- Test type transformation functionality

#### Phase 2: Update Core APIs
- Replace all deprecated API calls with new equivalents
- Update middleware usage pattern to use EmptyProps
- Implement set_props calls in each handler
- Fix compilation errors

#### Phase 3: Modernize Props Usage  
- Update all handlers to use new typed context pattern
- Ensure proper prop transformers are used
- Validate selective prop encoding works correctly

#### Phase 4: Enhanced Examples
- Add examples showcasing optional props (`assign_optional_prop`)
- Demonstrate partial reload scenarios
- Show different inclusion strategies
- Demonstrate EmptyProps → SpecificProps transformation pattern

### Detailed Changes Required

#### Core Library Changes

#### File: `src/inertia_wisp/internal/types.gleam`
1. **EmptyProps Type**:
   - Add `EmptyProps` type that represents no props
   - Create encoder that produces empty JSON object `{}`

#### File: `src/inertia_wisp/inertia.gleam`
1. **EmptyProps Support**:
   - Add `empty_context()` function to create `InertiaContext(EmptyProps)`
   - Add `set_props()` function to transform context type
   - Update middleware to use EmptyProps by default

#### Demo Application Changes

#### File: `src/demo.gleam`
1. **Middleware Update**:
   - Change from custom middleware to new `inertia.middleware()` pattern
   - Use EmptyProps in middleware (no upfront prop knowledge needed)
   - Keep elegant middleware-before-routing pattern

2. **Home Page Handler**:
   - Add `set_props(HomeProps(...))` to transform context type
   - Replace `assign_always_typed_prop()` with `assign_always_prop()`
   - Replace `assign_typed_prop()` with `assign_prop()`
   - Replace `render_typed()` with `render()`

3. **Versioned Page Handler**:
   - Add `set_props()` call for appropriate prop type
   - Remove `set_config()` usage
   - Handle config changes through middleware setup

4. **About Page Handler**:
   - Add `set_props()` call for AboutProps
   - Replace `assign_always_props()` with individual `assign_always_prop()` calls

#### File: `src/handlers/utils.gleam`
1. **Common Props Function**:
   - Replace `assign_always_props()` with individual calls
   - Ensure proper type safety

#### File: `src/handlers/users/*.gleam`
1. **All User Handlers**:
   - Add `set_props()` calls to transform to UserProps
   - Update to use new API consistently
   - Ensure props are properly typed

#### File: `src/props.gleam`
1. **Props Definitions**:
   - Add EmptyProps type and encoder
   - Verify all prop types are correctly defined
   - Ensure encoders match new API expectations

### Success Criteria
1. **Compilation**: Demo compiles without errors or warnings
2. **Functionality**: All demo features work as before
3. **Type Safety**: Full type safety maintained throughout
4. **API Consistency**: Uses only new, supported APIs
5. **Examples**: Demonstrates key features of new typed props system
6. **EmptyProps System**: Middleware-before-routing pattern works with type safety
7. **Context Transformation**: `set_props()` correctly transforms context types

### Testing Plan
1. **Build Test**: `gleam build` in demo directory succeeds
2. **Runtime Test**: Demo server starts and serves pages correctly
3. **Feature Test**: All routes work (home, about, versioned, users, uploads)
4. **Props Test**: Verify selective prop encoding works in partial requests
5. **Redirect Test**: Verify redirect functionality works correctly
6. **EmptyProps Test**: Verify EmptyProps serializes to `{}` correctly
7. **Type Transformation Test**: Verify `set_props()` maintains type safety
8. **Middleware Pattern Test**: Verify middleware-before-routing still works

### Implementation Order
1. **Core Library**: Implement EmptyProps type and encoder in `internal/types.gleam`
2. **Core Library**: Add `set_props()` function in `inertia.gleam`
3. **Core Library**: Update middleware to use EmptyProps by default
4. **Demo**: Update `src/demo.gleam` main middleware and core handlers with set_props calls
5. **Demo**: Update `src/handlers/utils.gleam` common functions  
6. **Demo**: Update all user handlers in `src/handlers/users/` with set_props calls
7. **Demo**: Update upload handlers in `src/handlers/uploads.gleam`
8. Test compilation and basic functionality
9. Test EmptyProps and type transformation behavior
10. Add enhanced examples showcasing new features
11. Final validation and documentation updates

### Risk Assessment
- **Low Risk**: API changes are straightforward replacements
- **Migration Path**: Clear mapping from old APIs to new ones
- **Rollback**: Can revert to previous version if needed
- **Dependencies**: No external dependency changes required

### Estimated Effort
- **EmptyProps System Implementation**: 2-3 hours
- **Core API Updates**: 2-3 hours
- **Handler Updates**: 1-2 hours  
- **Testing & Validation**: 2 hours
- **Enhanced Examples**: 1-2 hours
- **Total**: 8-12 hours

This plan ensures a systematic migration of the demo example to use the new typed props API while maintaining all existing functionality, preserving the elegant middleware pattern, and adding demonstrations of new capabilities including the EmptyProps system.