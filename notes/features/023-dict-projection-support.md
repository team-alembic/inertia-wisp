# Feature 023: Dict Projection Support

## Plan

### Overview
Enhance the TypeScript type projection system to support Gleam `Dict<String, V>` types, automatically converting them to JavaScript `Record<string, V>` types. This will enable seamless type-safe usage of Gleam dictionaries in React components.

### Current State
The `ProjectType<T>` utility in `gleam-projections.ts` currently supports:
- `List<T>` → `T[]`
- `Option<T>` → `T | null` 
- `CustomType` → Plain objects (with method filtering)
- Primitive types → Pass through

### Requirements
1. **Type Detection**: Add conditional logic to detect Gleam `Dict$<String, V>` types
2. **Type Projection**: Transform `Dict$<String, V>` to `Record<string, ProjectType<V>>`
3. **Recursive Projection**: Ensure nested types within dictionary values are also projected
4. **Import Support**: Add appropriate import for `Dict$` type from `@gleam_stdlib/gleam/dict.d.mts`
5. **Exercise Functionality**: Update at least one page prop type in shared_types to use Dict and demonstrate the projection works

### Technical Challenge
**CRITICAL LIMITATION DISCOVERED**: The Gleam TypeScript generator defines `Dict$<LA, LB> = any`, which makes compile-time type detection impossible because:

1. `T extends Dict$<string, infer V>` becomes `T extends any` (always true)
2. No structural information exists to infer the value type `V`
3. TypeScript cannot distinguish `Dict$` from other `any` types

### Alternative Approaches

#### Option 1: Manual Type Annotations (Recommended)
Since automatic detection is impossible, require explicit type annotations:

```typescript
// In shared_types, add manual type exports alongside Gleam types
export type DashboardStats = Record<string, number>;

// In page components, use manual projection
type DashboardProps = {
  title: string;
  user_stats: DashboardStats; // Manually specify Record type
  // ... other projected fields
};
```

#### Option 2: Runtime Transformation
Handle Dict projection at runtime rather than type-level:

```typescript
// Helper function to transform Dict to Record
function projectDict<T>(dict: any): Record<string, T> {
  // Runtime logic to convert Gleam Dict to JS Record
  return dict; // Implementation would depend on Dict's runtime structure
}
```

#### Option 3: Gleam-side Type Hints
Add metadata or naming conventions in Gleam to hint at Dict usage:

```gleam
// Use type aliases with naming conventions
pub type UserStatsDict = Dict(String, Int)

pub type DashboardPageProp$ {
  DashboardPageProp$(
    title: String,
    user_stats: UserStatsDict,  // Clear naming indicates Dict
  )
}
```

#### 4. Exercise in Shared Types
Update one of the existing page prop types (e.g., `DashboardPageProp$`) to include a Dict field:
```gleam
pub type DashboardPageProp$ {
  DashboardPageProp$(
    title: String,
    user_stats: Dict(String, Int),  // New field to exercise Dict projection
    // ... existing fields
  )
}
```

#### 5. Frontend Usage Verification
Ensure the projected type works correctly in React components by accessing dictionary values with proper type safety.

### Implementation Steps (Revised for Option 1)
1. **Document the limitation**: Add comments explaining why Dict projection isn't automatic
2. **Create manual type definitions**: Add explicit Record types alongside Dict usage in shared_types
3. **Update gleam-projections.ts**: Add utility functions for manual Dict handling
4. **Add Dict field to DashboardPageProp$**: Use Dict in Gleam with manual TypeScript typing
5. **Create type bridge**: Export manual Record types from shared_types module
6. **Update Dashboard.tsx**: Use manual Record type instead of automatic projection
7. **Document the workaround**: Provide clear examples of how to handle Dict types

### Success Criteria (Revised)
- Clear documentation of Dict limitation and workaround approach
- Manual Dict typing works correctly with type safety
- Dict values can be accessed with proper type inference using manual types
- No regression in existing projection functionality
- Established pattern for future Dict usage in the codebase
- Runtime Dict handling (if implemented) works correctly

### Risk Mitigation
- **Accept the limitation**: Acknowledge that automatic Dict projection isn't feasible
- **Establish clear patterns**: Create consistent manual typing approaches
- **Documentation**: Clearly document why automatic projection doesn't work
- **Future-proofing**: Design manual approach to be easily upgradeable if Gleam TS generation improves
- **Type safety**: Ensure manual types maintain full type safety even without automatic projection

## Log

**Investigation Phase**: Discovered that Gleam's TypeScript generation defines `Dict$<LA, LB> = any`, which makes compile-time type detection impossible. The automatic projection approach that works for `List<T>` and `Option<T>` cannot be applied to `Dict<K, V>` because:

1. TypeScript conditional types cannot distinguish `Dict$` from other `any` types
2. Type inference with `infer` patterns fails when the base type is `any`
3. No structural information is preserved in the generated TypeScript definitions

**Alternative Approaches Considered**:
- Manual type annotations (most practical)
- Runtime transformation (complex, limited type safety)
- Gleam-side type hints (requires broader changes)

## Conclusion

**Task Status**: Closed - Investigation Complete

The automatic projection of Gleam `Dict<String, V>` types to JavaScript `Record<string, V>` types is **not feasible** with the current Gleam TypeScript generation system. The fundamental issue is that Gleam generates `Dict$<LA, LB> = any`, which eliminates all structural type information needed for TypeScript's compile-time type manipulation.

**Key Findings**:
- Automatic Dict projection cannot be implemented using the same patterns as List and Option projection
- The limitation is in Gleam's TypeScript generation, not in the projection utility design
- Manual type annotations remain the most practical workaround for Dict usage
- Any solution would require changes to how Gleam generates TypeScript definitions

**Recommendation**: 
Continue using manual `Record<string, T>` type annotations for Dict fields until Gleam's TypeScript generation is enhanced to preserve structural type information for Dict types.

**Future Work**: 
Monitor Gleam compiler development for potential improvements to TypeScript definition generation that could enable automatic Dict projection.