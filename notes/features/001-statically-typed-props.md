# Feature 001: Statically Typed Props System

## Plan

### Overview
Transform the inertia_gleam library's props system from a runtime `Dict(String, Prop)` approach to a compile-time parameterized type system that enables seamless interop between Gleam backend types and TypeScript frontend types.

### Goals
1. **Type Safety**: Props types known at compile time on both backend and frontend
2. **Seamless Interop**: Generate TypeScript types from Gleam types automatically
3. **Partial Reload Support**: Maintain lazy evaluation for selective prop updates
4. **Clean API**: Leverage Gleam's anonymous function syntax for prop assignments
5. **Performance**: Ensure no regression in runtime performance

### Current State Analysis
- `InertiaContext` uses `props: Dict(String, Prop)`
- Props are set dynamically at runtime
- No compile-time type checking for props
- Frontend types are manually maintained and can drift

### Proposed Design

#### Core Type Changes
```gleam
// Current
pub type InertiaContext {
  InertiaContext(
    // ... other fields
    props: Dict(String, Prop)
  )
}

// Proposed
pub type InertiaContext(props) {
  InertiaContext(
    // ... other fields
    props_transformers: List(#(String, fn(props) -> props)),
    props_encoder: fn(props) -> json.JSON,
    props_zero: props
  )
}
```

#### API Design
```gleam
// Usage example
context
|> assign_prop("id", UserProfilePageProps(_, id: 42))
|> assign_prop("email", UserProfilePageProps(_, email: "alice@example.com"))
|> assign_prop("name", UserProfilePageProps(_, name: user.name))
```

#### Type Generation
- Build-time tool to generate TypeScript definitions from Gleam types
- Output to shared location accessible by frontend build process

### Implementation Phases

#### Phase 1: Core Type System
1. **Update InertiaContext type** to be parameterized
2. **Implement prop transformation system**
   - `assign_prop` function
   - Lazy evaluation for partial reloads
   - Zero value initialization
3. **Update response rendering** to use new system

#### Phase 2: JSON Encoding
1. **User-provided encoder function** (props -> json.JSON)
2. **Integration with existing JSON library**

#### Phase 3: Type Generation Tooling
1. **Shared types project** structure setup (gleam project targeting both Erlang and JavaScript)
2. **TypeScript definition generation** using Gleam's built-in JavaScript compilation with .d.ts output
3. **Build integration** for automated type sharing between backend and frontend

#### Phase 4: Documentation & Examples
1. **Update existing API functions** to work with new system
2. **Update examples** to demonstrate new approach

### Technical Challenges & Solutions

#### Challenge 1: Zero Value Initialization
**Problem**: How to create "zero" values for arbitrary user types?
**Solution**: Require user to provide zero value factory function when creating context

#### Challenge 2: Partial Reload Mapping
**Problem**: Map prop names from client requests to transformation functions
**Solution**: Maintain name-to-transformer mapping in InertiaContext

#### Challenge 3: JSON Encoding
**Problem**: JSON encoding for user-defined types
**Solution**: Require users to provide encoder function (props -> json.JSON) when creating context. Gleam users are familiar with this pattern and often use language-server code actions to generate encoders.

#### Challenge 4: Type Generation
**Problem**: Sharing types between backend (Erlang) and frontend (JavaScript/TypeScript)
**Solution**: Use a dedicated shared Gleam project that can compile to both Erlang and JavaScript targets. Leverage Gleam's built-in TypeScript definition generation when compiling to JavaScript.

#### Challenge 5: API Design Consistency
**Problem**: Ensure new API is intuitive and consistent with Gleam conventions
**Solution**: Follow established Gleam patterns and provide clear examples

### Success Criteria
1. **Compile-time type safety** for props on backend
2. **Generated TypeScript types** match Gleam types exactly
3. **Documentation** covers all use cases and examples

### Risks & Mitigations
- **Risk**: Complex type system may be difficult to understand
  **Mitigation**: Comprehensive examples and clear documentation
- **Risk**: Type generation tooling complexity
  **Mitigation**: Use Gleam's built-in JavaScript compilation with TypeScript definitions

### Dependencies
- Current inertia_gleam codebase understanding
- JSON encoding libraries in Gleam ecosystem
- Gleam's JavaScript compilation with TypeScript definition output
- Multi-project structure setup (shared/backend/frontend)

### Deliverables
1. Updated `InertiaContext` type and core functions
2. Prop transformation and assignment API
3. JSON encoding integration
4. Shared types project structure and build configuration
5. Updated examples demonstrating new approach with multi-project setup
6. Documentation covering usage patterns

## Log
*Implementation notes will be added here during development*

## Conclusion
*Final design decisions and outcomes will be documented here after completion*