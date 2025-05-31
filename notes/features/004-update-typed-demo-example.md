# Feature 004: Update Typed-Demo Example to New Typed Props API

## Plan

### Overview
Update the `examples/typed-demo` project to use the new typed props API and EmptyProps system that was established in Features 002 and 003. The typed-demo is likely an older or alternative example that may be using different patterns than the main demo, and needs to be modernized to match the current API standards.

### Objectives
1. **API Modernization**: Update typed-demo to use the same new typed props API as the main demo
2. **EmptyProps Integration**: Implement the EmptyProps middleware pattern for type safety
3. **Consistency**: Ensure typed-demo follows the same patterns established in the main demo
4. **Enhanced Examples**: Add advanced typed prop usage patterns unique to this example
5. **Documentation**: Update any README or documentation specific to typed-demo

### Assessment Phase
**Before starting implementation, we need to:**
1. Analyze current state of `examples/typed-demo` directory structure
2. Identify differences from main demo and current API usage
3. Determine scope of changes needed
4. Plan migration strategy based on existing code patterns

### Expected Changes
Based on Feature 003 experience, likely changes include:
- Replace deprecated API calls with new typed prop methods
- Update middleware pattern to use `empty_middleware()` and `set_props()`
- Fix type signatures to use `InertiaContext(inertia.EmptyProps)`
- Remove any internal module imports, use public API only
- Update prop assignment patterns to use transformation functions
- Ensure prop names match any frontend component expectations

### Success Criteria
1. **Compilation**: Typed-demo compiles without errors or warnings
2. **API Consistency**: Uses only new, supported APIs matching main demo
3. **Type Safety**: Full type safety maintained throughout
4. **No Internal Imports**: Uses only public API surface
5. **Functional**: All example features work correctly
6. **Documentation**: Clear examples of advanced typed prop patterns

### Implementation Strategy
1. **Assessment**: Analyze current typed-demo structure and code
2. **Core Migration**: Update API calls and middleware patterns
3. **Type Safety**: Fix all type signatures and prop assignments
4. **Enhanced Examples**: Add unique patterns not covered in main demo
5. **Testing**: Verify compilation and basic functionality
6. **Documentation**: Update any example-specific documentation

### Risk Assessment
- **Low Risk**: Based on Feature 003 success, migration path is well-established
- **Pattern Reuse**: Can leverage exact patterns from main demo migration
- **Known Solutions**: EmptyProps system provides proven approach
- **Rollback**: Can revert to previous version if needed

### Estimated Effort
- **Assessment & Planning**: 1 hour
- **Core API Migration**: 2-3 hours  
- **Type Safety & Testing**: 1-2 hours
- **Enhanced Examples**: 1-2 hours
- **Documentation**: 1 hour
- **Total**: 6-9 hours

## Log

### Ready for Implementation
**Status**: Plan complete, ready to begin assessment and implementation

**Next Required Action**: Analyze current state of `examples/typed-demo` to determine specific migration needs

## Ideal Next Prompt

"I'm continuing work on the Inertia Wisp project. Feature 003 (updating the main demo example) has been successfully completed with the new EmptyProps system and typed props API. All 59 tests are passing and the main demo is fully modernized.

Now I'd like to update the `examples/typed-demo` project to use the same new API patterns. Please:

1. **Analyze Current State**: Examine the `examples/typed-demo` directory structure and code to understand what needs updating
2. **Create Migration Plan**: Based on the assessment, create a specific migration plan following the successful patterns from Feature 003
3. **Implement Changes**: Update the typed-demo to use:
   - The new `empty_middleware()` and `set_props()` pattern
   - Proper `InertiaContext(inertia.EmptyProps)` type signatures  
   - The new `assign_prop()`, `assign_always_prop()`, and `assign_optional_prop()` methods
   - Only public API imports (no `/internal` modules)
4. **Add Enhanced Examples**: Include any advanced typed prop patterns that would be valuable to showcase

The goal is to make typed-demo consistent with the main demo while potentially showcasing additional advanced patterns. Please start by examining the current state and let me know what you find."