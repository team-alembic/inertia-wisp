# Feature 007: Type-Level Programming for Page Props

## Plan

### Overview
Convert the typed-demo page components to use type-level programming projections instead of Gleam decoders, eliminating awkward Gleam types (Option, List) in React components and removing the need for higher-order component wrappers.

### Problem Statement
The current page props system has several issues:
1. **Awkward Gleam Types**: Components receive `Option<T>` and `List<T>` instead of JavaScript-friendly `T | null` and `T[]`
2. **Complex Wrapper Components**: Higher-order components needed to decode props add complexity
3. **Poor Developer Experience**: Working with Gleam types in React is unnatural
4. **Inconsistent Patterns**: Form submissions use projections, but page props use decoders

### Current State Assessment
- ✅ **Form Submissions**: Using type-level projections (Feature 006 complete)
- ❌ **Page Props**: Using Gleam decoders with wrapper components
- ❌ **Developer Experience**: Awkward Option/List handling in components
- ❌ **Code Consistency**: Mixed patterns between forms and page props

### Success Criteria
1. **JavaScript-Compatible Props**: All page components receive `T | null` and `T[]` instead of `Option<T>` and `List<T>`
2. **No Wrapper Components**: Direct component usage without higher-order wrappers
3. **Type Safety**: Maintain compile-time safety while improving usability
4. **Consistent Patterns**: Same projection approach for both forms and page props
5. **Simplified Components**: Cleaner, more readable React components

### Architecture Design

#### 1. **Current Page Props Flow**
```
Gleam Backend → JSON → Inertia Context → Decoder → Gleam Types → React Component
```

#### 2. **New Type-Level Flow**
```
Gleam Backend → JSON → Type Projection → JavaScript Types → React Component
```

#### 3. **Key Changes**
- **Remove Decoders**: No more `decode_user_profile_props()` functions
- **Add Projections**: Use `GleamToJS<T>` for all page prop types
- **Simplify Components**: Direct prop usage without wrappers
- **Automatic Conversion**: Inertia.js handles JSON conversion automatically

### Implementation Strategy

#### Phase 1: Extend Type-Level Utilities
1. **Enhance gleam-projections.ts**:
   - Add page prop projections alongside form projections
   - Create utilities for common page prop patterns
   - Add comprehensive type tests

2. **Create Page Prop Types**:
   - `UserProfilePageData = GleamToJS<UserProfilePageProps>`
   - `BlogPostPageData = GleamToJS<BlogPostPageProps>`
   - `DashboardPageData = GleamToJS<DashboardPageProps>`
   - `HomePageData = GleamToJS<HomePageProps>`

#### Phase 2: Convert Page Components
1. **Remove Higher-Order Wrappers**:
   - Eliminate decoder-based wrapper components
   - Convert to direct component prop interfaces

2. **Update Component Interfaces**:
   - Replace Gleam types with projected JavaScript types
   - Update prop destructuring and usage patterns

3. **Fix Type Handling**:
   - Convert `Option<T>` usage to `T | null` patterns
   - Convert `List<T>` usage to `T[]` patterns

#### Phase 3: Backend Cleanup (Optional)
1. **Remove Unused Decoders**:
   - Delete `decode_*_page_props()` functions that are no longer needed
   - Keep encoders as they're still used for sending props

2. **Backend Stays Largely the Same**:
   - Route handlers continue using encoders to send JSON
   - No changes needed to prop assignment patterns
   - Inertia.js handles JSON transfer automatically

#### Phase 4: Clean Up and Test
1. **Remove Dead Code**:
   - Delete unused decoder functions
   - Remove wrapper component files
   - Clean up imports

2. **Verify Type Safety**:
   - Ensure all components compile without errors
   - Test runtime behavior matches expectations

### Expected Changes

#### Type-Level Utilities (`src/frontend/src/types/gleam-projections.ts`)
```typescript
// Add page prop projections
export type UserProfilePageData = GleamToJS<UserProfilePageProps>;
export type BlogPostPageData = GleamToJS<BlogPostPageProps>;
export type DashboardPageData = GleamToJS<DashboardPageProps>;
export type HomePageData = GleamToJS<HomePageProps>;

// Convenience type for all page data
export type PageData<T> = GleamToJS<T>;
```

#### Component Updates (`src/frontend/src/UserProfile.tsx`)
```typescript
// Before: Complex wrapper with Gleam types
export default createInertiaPage(
  UserProfilePageProps,
  decode_user_profile_props,
  ({ name, email, id, interests, bio }) => {
    const interestsList = interests?.toArray() || [];
    const displayBio = bio || "No bio provided";
    // ...
  }
);

// After: Direct component with JavaScript types  
import type { UserProfilePageData } from "./types/gleam-projections";

interface Props extends UserProfilePageData {}

export default function UserProfile({ name, email, id, interests, bio }: Props) {
  const interestsList = interests || [];
  const displayBio = bio || "No bio provided";
  // ...
}
```

#### Backend Handler Updates (`src/backend/src/handlers.gleam`)
```gleam
// Backend stays largely the same - no decoders were used for outgoing props
pub fn user_profile_handler(ctx: InertiaContext(inertia.EmptyProps), req: wisp.Request, user_id: String) -> wisp.Response {
  let user_props = UserProfilePageProps(
    name: "John Doe",
    email: "john@example.com", 
    id: 1,
    interests: option.Some(["gleam", "typescript"]),
    bio: "Software engineer",
  )
  
  ctx
  |> inertia.set_props(user_props, encode_user_profile_props)
  |> inertia.render("UserProfile")
}

// The key insight: Backend continues to send Gleam types as JSON using encoders
// Frontend receives JSON and uses type projections to get JavaScript-friendly types
// No backend changes needed - the magic happens purely on the frontend type level
```

### Technical Challenges

#### 1. **Frontend Type Projection**
- Ensure type projections work correctly with Inertia's page props
- Verify automatic JSON → TypeScript conversion handles all type mappings
- Test edge cases with null/undefined values in received props

#### 2. **Type Projection Accuracy**
- Ensure Option<T> → T | null mapping is complete
- Verify List<T> → T[] conversion works for nested structures
- Handle complex nested types correctly

#### 3. **Component Integration**
- Update all existing page components to use projected types
- Remove wrapper components and decoder dependencies
- Ensure component behavior remains identical with new prop types

#### 4. **Build Process Integration**
- Ensure TypeScript compilation works with projected page props
- Verify SSR builds handle type projections correctly
- Confirm production builds maintain type safety

### Risk Assessment
- **Medium Risk**: More complex than form projections due to nested structures
- **Breaking Changes**: Will require updating all page components
- **Type Complexity**: Advanced TypeScript features may cause compilation issues
- **Integration Risk**: Inertia.js prop system integration specifics

### Dependencies
- **Feature 006**: Type-level form projections (completed) - provides foundation
- **Existing Page Components**: All components will need updates
- **Inertia.js**: Core prop system and JSON handling
- **Gleam Backend**: Current prop encoding system

### Estimated Effort
- **Type Utilities Enhancement**: 2-3 hours (extend existing projections)
- **Component Conversion**: 4-5 hours (convert all page components)
- **Backend Cleanup**: 1-2 hours (remove unused decoder functions only)
- **Testing & Integration**: 3-4 hours (verify type safety and runtime behavior)
- **Code Cleanup**: 2-3 hours (remove dead code, update imports)
- **Total**: 12-17 hours

### Success Metrics
1. **Type Safety**: All components compile without TypeScript errors
2. **Code Simplicity**: Significant reduction in component complexity
3. **Developer Experience**: Natural JavaScript object handling in components
4. **Runtime Behavior**: Identical functionality with improved ergonomics
5. **Pattern Consistency**: Unified approach for forms and page props

## Log

### Status: Phase 2 Complete - Ready for Phase 3
**Next Required Action**: Begin Phase 3 - Remove wrapper components and decoder dependencies

**Current State**:
- ✅ **Foundation Ready**: Type-level projection system proven with forms (Feature 006)
- ✅ **Problem Identified**: Current page props system creates awkward developer experience
- ✅ **Solution Designed**: Type-level projections can eliminate decoders and wrappers
- ✅ **Phase 1 Complete**: Extended gleam-projections.ts with page prop type aliases
- ✅ **Phase 2 Complete**: Converted all page components to use projected types
- ⏳ **Phase 3 Pending**: Ready to remove wrapper components and decoder utilities

**Key Files to Reference**:
- `src/frontend/src/types/gleam-projections.ts` - Core type-level utilities (working for forms)
- `src/frontend/src/forms/ContactFormComponent.tsx` - Example of successful projection usage
- `src/frontend/src/UserProfile.tsx` - Example component that needs conversion
- `src/shared/src/types.gleam` - Page prop types that need projection

**Key Insight**: The type-level programming approach we developed for forms can completely eliminate the complexity of the current page props system, providing a unified, developer-friendly approach across the entire application.

**Backend vs Frontend Changes**:
- **Backend**: Minimal - only remove unused decoder functions
- **Frontend**: Major - convert all components from Gleam types to JavaScript types
- **Core Change**: Replace wrapper components + decoders with direct type projections

**Critical Technical Details**:
- Type projection transforms `Option<T>` → `T | null` and `List<T>` → `T[]`
- `GleamToJS<T>` utility filters out class methods and projects property types
- Inertia.js automatically handles JSON conversion between backend and frontend
- No runtime overhead - all transformation happens at TypeScript compile time

### Phase 1 Implementation Details (COMPLETED)

**Extended gleam-projections.ts with Page Prop Types**:
- Added imports for all page prop classes from generated types
- Created type aliases using `GleamToJS<T>` utility for all page components:
  - `UserProfilePageData = GleamToJS<UserProfilePageProps>`
  - `BlogPostPageData = GleamToJS<BlogPostPageProps>`
  - `DashboardPageData = GleamToJS<DashboardPageProps>`
  - `HomePageData = GleamToJS<HomePageProps>`
- Added form page prop projections for pages that render forms:
  - `CreateUserFormPageData`, `EditProfileFormPageData`, etc.
- Added convenient type aliases for easy importing
- Created generic `PageData<T>` utility type

**Key Achievement**: All page prop types now have JavaScript-compatible projections available, transforming:
- `interests: Option$<List<string>>` → `interests: string[] | null`
- `tags: List<string>` → `tags: string[]`
- `view_count: Option$<number>` → `view_count: number | null`

**Ready for Phase 2**: Can now convert components to use these projected types instead of Gleam classes.

### Phase 2 Implementation Details (COMPLETED)

**Converted All Page Components to Use Projected Types**:

1. **UserProfile.tsx**:
   - Removed: `withDecodedProps(decode_user_profile_page_props, UserProfile)`
   - Added: `import type { UserProfilePageData } from "./types/gleam-projections"`
   - Simplified interests handling: `props.interests && props.interests.length > 0` instead of complex option utilities
   - Natural bio handling: `props.bio || "No bio provided"` instead of direct Gleam property access

2. **BlogPost.tsx**:
   - Removed: Complex `unwrapOr` and option utilities for view count
   - Added: Natural JavaScript null checking: `props.view_count && props.view_count > 0`
   - Simplified tags mapping: `props.tags.map()` instead of `props.tags.toArray().map()`

3. **Dashboard.tsx**:
   - Removed: Complex option mapping for recent signups count and list handling
   - Added: Simple array operations: `props.recent_signups ? props.recent_signups.length : 0`
   - Eliminated all `option.unwrapOr` and `List` utility usage

4. **Home.tsx**:
   - Simplified features list rendering: `props.features.map()` instead of `props.features.toArray().map()`
   - Removed decoder wrapper and option utilities

**Key Developer Experience Improvements**:
- ❌ **Before**: `option.unwrapOr(option.map(props.interests, x => x.toArray()), []).map(...)`
- ✅ **After**: `props.interests?.map(...) || []`

- ❌ **Before**: `unwrapOr(props.view_count, 0) > 0 ? ...`  
- ✅ **After**: `props.view_count && props.view_count > 0 ? ...`

- ❌ **Before**: `props.features.toArray().map(...)`
- ✅ **After**: `props.features.map(...)`

**Form Pages Status**: Already using manual interfaces (CreateUser.tsx, EditProfile.tsx, Login.tsx, ContactForm.tsx) - no changes needed as they don't use the decoder pattern.

**Ready for Phase 3**: All components now use natural JavaScript types. Need to remove decoder utilities and clean up unused functions.

## Conclusion

This feature will complete the transformation to a fully type-safe, developer-friendly system where:
- **Forms use projections**: JavaScript objects → Gleam types (via JSON)
- **Pages use projections**: Gleam types → JavaScript objects (via JSON)
- **No manual type conversion**: Everything handled automatically by type system
- **Consistent patterns**: Same projection approach everywhere
- **Superior DX**: Natural JavaScript semantics throughout

The result will be a production-ready template for building Inertia Wisp applications with seamless type safety and optimal developer experience.

## Continuation Prompt for Next Thread

"I need to implement Feature 007: Type-Level Programming for Page Props in the inertia-wisp typed-demo.

**Context**: We've successfully implemented type-level projections for form submissions (Feature 006), where TypeScript automatically converts Gleam types to JavaScript-compatible interfaces. Now we need to apply the same approach to page props to eliminate awkward Gleam types (`Option<T>`, `List<T>`) in React components.

**Current Problem**: Page components currently use wrapper components with decoders that bring Gleam types into React:
```typescript
// ❌ Current: Awkward Gleam types
const interestsList = interests?.toArray() || [];
const displayBio = bio instanceof Some ? bio[0] : 'No bio';
```

**Goal**: Convert to natural JavaScript types using type-level projections:
```typescript
// ✅ Target: Natural JavaScript types  
const interestsList = interests || [];
const displayBio = bio || 'No bio';
```

**Implementation Plan**:
1. **Phase 1**: Extend `src/frontend/src/types/gleam-projections.ts` with page prop projections
2. **Phase 2**: Convert page components (`UserProfile.tsx`, `BlogPost.tsx`, etc.) to use projected types
3. **Phase 3**: Remove wrapper components and decoder dependencies
4. **Phase 4**: Clean up unused decoder functions

**Key Technical Details**:
- Use existing `GleamToJS<T>` utility from gleam-projections.ts
- Transform page prop types: `UserProfilePageProps` → `UserProfilePageData`
- Backend stays the same (uses encoders to send JSON)
- Frontend eliminates decoders and wrapper components

**Files to Focus On**:
- `src/frontend/src/types/gleam-projections.ts` - Extend for page props
- `src/frontend/src/UserProfile.tsx` - Convert first component
- `src/shared/src/types.gleam` - Reference for page prop types

Please start with Phase 1: extending the type-level utilities to handle page props alongside the existing form projections."