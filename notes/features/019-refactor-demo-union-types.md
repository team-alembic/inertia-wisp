# Refactor Demo App to Use Union-Based Prop Types

## Plan

### Overview
Refactor the `examples/demo` app to follow the same union-based prop type patterns established in `examples/typed-demo`. This will provide consistency across example apps and demonstrate the new API patterns.

### Current State Analysis
- Single `props.gleam` file contains all prop types as records
- Uses old transformation-based API with helper functions
- Handlers use `inertia.set_props()` + `inertia.prop(helper_function())`
- Prop types: HomeProps, AboutProps, VersionedProps, UserProps, UploadProps, DemoFeaturesProps

### Target State
- Convert all record-based prop types to union-based prop types
- Create individual encoders for each prop variant
- Update all handlers to use new `inertia.with_encoder()` + `inertia.prop("key", Variant(value))` API
- Maintain same functionality while improving type safety

### Implementation Steps

#### Phase 1: Type System Conversion
1. **Convert HomeProps to union type**
   - Create `HomePageProp` union with variants: `Auth`, `CsrfToken`, `Message`, `Timestamp`, `UserCount`
   - Create `encode_home_page_prop` function with pattern matching
   - Remove old helper functions

2. **Convert AboutProps to union type**
   - Create `AboutPageProp` union with variants: `Auth`, `CsrfToken`, `PageTitle`, `Description`
   - Create `encode_about_page_prop` function

3. **Convert VersionedProps to union type**
   - Create `VersionedPageProp` union with variants: `Auth`, `CsrfToken`, `Version`, `BuildInfo`
   - Create `encode_versioned_page_prop` function

4. **Convert UserProps to union type**
   - Create `UserPageProp` union with variants: `Auth`, `CsrfToken`, `Users`, `Pagination`, `User`, `Success`, `Errors`
   - Create `encode_user_page_prop` function

5. **Convert UploadProps to union type**
   - Create `UploadPageProp` union with variants: `Auth`, `CsrfToken`, `MaxFiles`, `MaxSizeMb`, `Success`, `UploadedFiles`
   - Create `encode_upload_page_prop` function

6. **Convert DemoFeaturesProps to union type**
   - Create `DemoFeaturesPageProp` union with variants: `Auth`, `CsrfToken`, `Title`, `Description`, `ExpensiveData`, `PerformanceInfo`
   - Create `encode_demo_features_page_prop` function

#### Phase 2: Handler Updates
1. **Update main demo.gleam handlers**
   - `home_page`: Use `inertia.with_encoder()` and new prop API
   - `about_page`: Convert to new API
   - `versioned_page`: Convert to new API
   - `demo_features_page`: Convert to new API

2. **Update user handlers**
   - `list_handler.gleam`: Convert users page
   - `create_handler.gleam`: Convert create user form
   - `edit_handler.gleam`: Convert edit user form
   - `show_handler.gleam`: Convert show user page
   - `delete_handler.gleam`: Update if using props

3. **Update upload handlers**
   - `uploads.gleam`: Convert upload form and handlers

#### Phase 3: Testing & Validation
1. **Compile-time validation**
   - Ensure all handlers compile without errors
   - Verify type safety is maintained

2. **Runtime validation**
   - Test all pages render correctly
   - Verify form submissions work
   - Check partial reload functionality

3. **API consistency**
   - Ensure patterns match typed-demo exactly
   - Verify encoder functions follow same conventions

### Design Decisions

#### Union Type Naming Convention
- Follow typed-demo pattern: `[Page]PageProp` for union types
- Use descriptive variant names: `Auth(auth)`, `CsrfToken(token)`, etc.
- Encoder functions: `encode_[page]_page_prop`

#### Common Patterns
- `Auth` and `CsrfToken` variants will appear in most page types
- Keep `Auth` type as separate domain type for reuse
- Use `json.Json` type for complex data that doesn't need individual variants

#### Backward Compatibility
- Keep existing API functional during transition
- Remove old helper functions only after conversion complete
- Maintain same prop key names for frontend compatibility

### Success Criteria
1. All handlers compile and run successfully
2. Frontend receives identical prop structure
3. All form submissions continue working
4. Partial reload functionality preserved
5. Code follows same patterns as typed-demo
6. No runtime regressions introduced

### Risk Mitigation
- Convert one page type at a time to isolate issues
- Test each conversion before proceeding to next
- Keep old code commented out initially for easy rollback
- Verify frontend compatibility at each step

## Log

### Progress Update - Phase 1 Complete

**✅ Phase 1: Type System Conversion - COMPLETE**
- Created separate modules in `src/shared_types/` to avoid naming collisions:
  - `auth.gleam` - Shared Auth domain type and helpers
  - `home.gleam` - HomePageProp union type with Auth, CsrfToken, Message, Timestamp, UserCount variants
  - `about.gleam` - AboutPageProp union type with Auth, CsrfToken, PageTitle, Description variants  
  - `versioned.gleam` - VersionedPageProp union type with Auth, CsrfToken, Version, BuildInfo variants
  - `users.gleam` - UserPageProp union type with Auth, CsrfToken, Users, Pagination, User, Success, Errors variants + domain types
  - `uploads.gleam` - UploadPageProp union type with Auth, CsrfToken, MaxFiles, MaxSizeMb, Success, UploadedFiles variants + domain types
  - `demo_features.gleam` - DemoFeaturesPageProp union type with Auth, CsrfToken, Title, Description, ExpensiveData, PerformanceInfo variants + domain types

**✅ Phase 2: Individual Encoders - COMPLETE**
- All prop types now have individual encoder functions that pattern match on union variants
- Encoders follow consistent naming: `encode_[page]_page_prop`
- Each variant encodes its data appropriately using the proper json.* functions

**🔄 Phase 3: Main Handlers - IN PROGRESS**
- ✅ Updated `demo.gleam` main handlers:
  - `home_page()` - converted to use `inertia.with_encoder(home.encode_home_page_prop)` and new prop API
  - `about_page()` - converted to new API with `about.encode_about_page_prop`
  - `versioned_page()` - converted to new API with `versioned.encode_versioned_page_prop`
  - `demo_features_page()` - converted to new API with proper typed data structures
- ✅ Updated `handlers/utils.gleam` - simplified helper functions for common auth/csrf patterns
- 🔄 Currently updating user handlers to use new union types

**🔄 Phase 4: User Handlers - IN PROGRESS**
- ✅ Updated `handlers/users/list_handler.gleam` to use new union-based API
- ⏳ Need to update remaining user handlers:
  - `create_handler.gleam`
  - `show_handler.gleam` 
  - `edit_handler.gleam`
  - `delete_handler.gleam`

**✅ Phase 4: User Handlers - COMPLETE**
- ✅ Updated all remaining user handlers (create, show, edit, delete)
- ✅ Updated upload handlers with new union-based API
- ✅ Fixed import conflicts by using module aliases (user_data vs user_props)
- ✅ Resolved naming conflicts in shared type modules

**✅ Phase 5: Clean Up - COMPLETE**
- ✅ Removed old `props.gleam` file completely
- ✅ Updated all imports across all files
- ✅ Fixed type annotations and inference issues
- ✅ Application compiles successfully without errors

### Key Decisions Made
1. **Module Structure**: Split props into separate modules to avoid naming collisions, following typed-demo pattern
2. **Domain Types**: Kept shared types like Auth separate, created domain-specific types in relevant modules
3. **Type Mapping**: Converting between internal domain types (types/user.User) and prop types (shared_types/users.User) as needed
4. **API Consistency**: Using new `inertia.with_encoder()` + `inertia.prop("key", Variant(value))` API throughout

### Issues Encountered
1. **Naming Conflicts**: Had to use separate modules to avoid variant name collisions
2. **Type Mapping**: Need conversion functions between existing domain types and new prop types
3. **Import Updates**: Extensive import changes required across all files

### Next Steps
1. Complete user handler updates (create, show, edit, delete)
2. Update upload handlers
3. Remove old props.gleam and update all imports
4. Test full application functionality
5. Verify frontend compatibility (same JSON output)

## Conclusion