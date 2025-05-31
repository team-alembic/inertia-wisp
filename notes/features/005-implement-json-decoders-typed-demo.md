# Feature 005: Implement JSON Decoder Pattern for Typed-Demo Frontend

## Plan

### Overview
Fix the fundamental type mismatch issue in the typed-demo where Gleam `List(String)` types are serialized to JSON arrays but the frontend TypeScript expects Gleam List objects with `.toArray()` methods. Implement a comprehensive JSON decoder pattern that properly converts raw JavaScript objects into correctly typed Gleam data structures on the frontend.

### Problem Statement
The current shared types approach has a critical flaw:
1. **Backend**: Gleam encodes `List(String)` as JSON array `["item1", "item2"]` 
2. **Transport**: JSON is sent to frontend as plain JavaScript objects
3. **Frontend**: TypeScript expects Gleam `List<String>` with `.toArray()` method
4. **Reality**: Frontend receives plain JavaScript `Array<string>` causing runtime errors

**Example Issue:**
```tsx
// Frontend expects: props.features.toArray()
// But receives: ["feature1", "feature2"] (plain JS array)
// Result: TypeError: props.features.toArray is not a function
```

### Current State Assessment
- ✅ **Backend**: Properly encodes Gleam types to JSON
- ✅ **TypeScript Definitions**: Generated types are correct
- ❌ **Runtime Conversion**: No conversion from JS objects to Gleam types
- ⚠️ **Workaround**: Frontend uses `.toArray()` on objects that don't have this method

### Solution: JSON Decoder Pattern
Implement Gleam decoders on the frontend that convert raw JavaScript data into proper Gleam types, ensuring runtime type safety matches compile-time expectations.

### Architecture Design

#### 1. **Shared Module Enhancement**
- ✅ Add decoder functions for each prop type (started with `home_page_props_decoder`)
- Create comprehensive decoders for all complex types (Lists, nested objects)
- Maintain both encoders (backend) and decoders (frontend) in shared module

#### 2. **Frontend Integration Pattern**
```tsx
// Current (broken):
export default function Home(props: HomePageProps) {
  return <div>{props.features.toArray().map(...)}</div>; // Error!
}

// Target (with decoder):
export default function Home(rawProps: unknown) {
  const props = decodeHomePageProps(rawProps);
  return <div>{props.features.toArray().map(...)}</div>; // Works!
}
```

#### 3. **Inertia.js Integration**
Need to integrate decoder pattern with Inertia.js page component loading:
- Intercept raw props before component rendering
- Apply appropriate decoder based on page component
- Pass properly typed props to components

### Implementation Strategy

#### Phase 1: Complete Decoder Suite ✅ (Started)
1. **Add decoders for all prop types**:
   - `user_profile_page_props_decoder()`
   - `blog_post_page_props_decoder()`
   - `dashboard_page_props_decoder()`
   - Complete `home_page_props_decoder()` (already started)

2. **Handle complex types**:
   - `List(String)` → Gleam List with proper methods
   - Nested objects if any
   - Optional fields and error handling

#### Phase 2: Frontend Integration
1. **Create decoder utility module**:
   - Import all decoders from shared types
   - Create component-to-decoder mapping
   - Handle decoder errors gracefully

2. **Update component pattern**:
   - Components receive decoded props with proper Gleam types
   - Remove current `.toArray()` workarounds
   - Add runtime type validation

#### Phase 3: Inertia.js Integration
1. **Page component wrapper**:
   - Intercept props before component rendering
   - Apply decoder based on component name
   - Handle decoder failures with fallbacks

2. **Developer experience**:
   - Clear error messages for decoder failures
   - Type safety maintained throughout
   - Performance optimization for decoder caching

### Expected Changes

#### Shared Types Module
```gleam
// Add comprehensive decoder suite
pub fn user_profile_page_props_decoder() -> decode.Decoder(UserProfilePageProps)
pub fn blog_post_page_props_decoder() -> decode.Decoder(BlogPostPageProps)
pub fn dashboard_page_props_decoder() -> decode.Decoder(DashboardPageProps)
// home_page_props_decoder already exists
```

#### Frontend Components
```tsx
// Before: Direct props with broken .toArray()
export default function Home(props: HomePageProps) {
  return <div>{props.features.toArray().map(...)}</div>
}

// After: Properly decoded props
export default function Home(props: HomePageProps) {
  return <div>{props.features.toArray().map(...)}</div> // Actually works!
}
```

#### Integration Layer
```tsx
// New decoder integration wrapper
function withDecoder<T>(component: Component<T>, decoder: Decoder<T>) {
  return function DecodedComponent(rawProps: unknown) {
    const decodedProps = decoder(rawProps);
    return component(decodedProps);
  }
}
```

### Success Criteria
1. **Runtime Type Safety**: All components receive properly typed Gleam objects
2. **Method Availability**: `.toArray()`, `.countLength()` etc. work correctly
3. **Error Handling**: Graceful handling of decoder failures
4. **Performance**: Minimal overhead from decoder pattern
5. **Developer Experience**: Clear error messages and type safety
6. **Compatibility**: Works with all Inertia.js features (partial reloads, etc.)

### Risk Assessment
- **Low Risk**: Decoders are well-established pattern in Gleam ecosystem
- **Incremental**: Can implement one component at a time
- **Backward Compatible**: Doesn't change backend or shared type definitions
- **Rollback**: Can revert to manual type handling if needed

### Technical References
- **Gleam Dynamic Decode**: `/build/packages/gleam_stdlib/src/gleam/dynamic/decode.gleam`
- **Existing Decoder**: `home_page_props_decoder()` in shared types
- **Inertia.js Integration**: Component resolution and prop passing

### Estimated Effort
- **Decoder Creation**: 2-3 hours (add 3 more decoders)
- **Frontend Integration**: 3-4 hours (wrapper pattern, error handling)
- **Component Updates**: 2-3 hours (remove workarounds, test)
- **Inertia Integration**: 2-3 hours (component mapping, prop interception)
- **Testing & Polish**: 2-3 hours (error cases, performance)
- **Total**: 11-16 hours

## Log

### Ready for Implementation
**Status**: Comprehensive plan complete, problem well-defined

**Next Required Action**: Begin implementing complete decoder suite for all prop types in shared module

**Key Files to Modify**:
- `src/shared/src/types.gleam` - Add remaining decoders
- `src/frontend/src/` - All component files
- `src/frontend/src/main.tsx` - Inertia.js integration
- Frontend build/integration - Decoder wrapper pattern

## Conclusion

This feature addresses a fundamental architectural flaw in the current typed-demo implementation. The JSON decoder pattern will ensure true type safety between Gleam backend and TypeScript frontend, making the shared types approach work correctly in practice, not just in theory.

The implementation will serve as a production-ready example of how to maintain type safety across the full stack when using Gleam with frontend frameworks, demonstrating best practices for the broader Inertia Wisp ecosystem.

## Ideal Next Prompt

"I'm continuing work on the Inertia Wisp project. Feature 004 (updating typed-demo) has been completed, but we discovered a critical issue: the shared types approach doesn't work correctly because Gleam Lists are serialized as JSON arrays but the frontend expects Gleam List objects with methods like `.toArray()`.

I've started implementing a solution using JSON decoders. There's already a `home_page_props_decoder()` function in `src/shared/src/types.gleam` that shows the pattern.

Please implement Feature 005 to fix this issue:

1. **Complete the decoder suite**: Add decoders for all remaining prop types (`UserProfilePageProps`, `BlogPostPageProps`, `DashboardPageProps`) in the shared types module

2. **Implement frontend integration**: Create a decoder utility that maps component names to their decoders and properly converts raw JavaScript objects to Gleam types

3. **Update all components**: Ensure they receive properly decoded props so `.toArray()` and other Gleam List methods work correctly

4. **Integrate with Inertia.js**: Hook into the page rendering process to automatically decode props before passing to components

5. **Test thoroughly**: Verify all components work with the new decoder pattern and handle edge cases gracefully

The goal is to make the shared types approach work correctly in practice, ensuring the frontend receives proper Gleam types with all expected methods available."