# Feature 006: Implement Typed Form Submissions for Typed-Demo

## Plan

### Overview
Extend the typed-demo with comprehensive form submission examples that demonstrate type safety between TypeScript frontend and Gleam backend for request bodies. Integrate with Inertia.js `useForm` hook to provide a complete full-stack type-safe form experience.

### Problem Statement
Currently, the typed-demo only demonstrates type safety for **page props** (server → client). We need to complete the picture by showing type safety for **form submissions** (client → server):

1. **Request Body Types**: Shared between TypeScript and Gleam for form data
2. **Validation**: Type-safe validation on both client and server
3. **Error Handling**: Proper error types and display patterns
4. **Integration**: Seamless integration with Inertia.js `useForm` hook

### Current State Assessment
- ✅ **Page Props**: Full type safety with JSON decoders (Feature 005 complete)
- ✅ **Option Types**: Proper handling of optional data (Feature 005 complete)  
- ❌ **Form Submissions**: No shared types for request bodies
- ❌ **Form Validation**: No type-safe validation examples
- ❌ **Form Examples**: No practical form submission demonstrations

### Success Criteria
1. **Shared Request Types**: TypeScript and Gleam share the same form data structures
2. **Type-Safe Validation**: Client and server validation using same type definitions
3. **Inertia.js Integration**: `useForm` hook works seamlessly with typed data
4. **Error Handling**: Proper error types and display patterns
5. **Real-World Examples**: Practical forms (create user, edit profile, etc.)
6. **Documentation**: Clear examples for other developers to follow

### Architecture Design

#### 1. **Shared Request Types**
Create request body types in the shared module alongside existing page props:
```gleam
// New request types in shared/src/types.gleam
pub type CreateUserRequest {
  CreateUserRequest(
    name: String,
    email: String,
    bio: option.Option(String),
  )
}

pub type UpdateProfileRequest {
  UpdateProfileRequest(
    name: String,
    bio: String,
    interests: List(String),
  )
}
```

#### 2. **JSON Decoders for Requests**
Similar to page props, create decoders for incoming request bodies:
```gleam
pub fn decode_create_user_request(data: decode.Dynamic) {
  let assert Ok(request) = decode.run(data, create_user_request_decoder())
  request
}
```

#### 3. **TypeScript Form Integration**
Generate TypeScript types and integrate with Inertia.js `useForm`:
```typescript
import { CreateUserRequest } from "../../shared/build/dev/javascript/shared_types/types.mjs";
import { useForm } from "@inertiajs/react";

function CreateUserForm() {
  const { data, setData, post, errors } = useForm<CreateUserRequest>({
    name: "",
    email: "",
    bio: null, // Option type handling
  });
  
  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    post("/users"); // Type-safe submission
  };
}
```

#### 4. **Server-Side Integration**
Backend handlers that use the shared types:
```gleam
fn create_user_handler(ctx: InertiaContext, request: wisp.Request) {
  let decoded_body = decode_create_user_request(request.body)
  // Process typed request body
  // Return typed response
}
```

### Implementation Strategy

#### Phase 1: Shared Request Types
1. **Add request types to shared module**:
   - `CreateUserRequest` with required and optional fields
   - `UpdateProfileRequest` for editing existing data
   - `LoginRequest` for authentication example
   - Include proper Option type usage

2. **Create request decoders**:
   - Following same pattern as page props decoders
   - Proper error handling with meaningful messages
   - Support for optional fields and complex types

#### Phase 2: Backend Form Handlers
1. **Create form submission endpoints**:
   - POST `/users` (create user)
   - PUT/PATCH `/users/:id` (update profile) 
   - POST `/login` (authentication example)

2. **Integrate with existing backend**:
   - Add new routes to typed-demo backend
   - Use shared decoders to parse request bodies
   - Return appropriate responses (success/error)

#### Phase 3: Frontend Form Components
1. **Create form components with useForm**:
   - `CreateUserForm` component
   - `EditProfileForm` component  
   - `LoginForm` component

2. **Type-safe form handling**:
   - Proper TypeScript integration with `useForm<T>`
   - Client-side validation using shared types
   - Error display with proper typing

#### Phase 4: Form Pages and Navigation
1. **Add form pages to routing**:
   - `/users/create` - Create user form
   - `/users/:id/edit` - Edit profile form
   - `/login` - Login form

2. **Navigation updates**:
   - Add links to forms from existing pages
   - Breadcrumb navigation
   - Success/error redirects

### Expected Changes

#### Shared Types Module (`src/shared/src/types.gleam`)
```gleam
// Add request types
pub type CreateUserRequest {
  CreateUserRequest(
    name: String,
    email: String,
    bio: option.Option(String),
  )
}

// Add request decoders
pub fn decode_create_user_request(data: decode.Dynamic) {
  let assert Ok(request) = decode.run(data, create_user_request_decoder())
  request
}
```

#### Backend Routes (`src/backend/src/typed_demo_backend.gleam`)
```gleam
// Add form submission routes
["users"], http.Post -> handlers.create_user_handler(ctx, req)
["users", user_id], http.Put -> handlers.update_user_handler(ctx, req, user_id)
```

#### Frontend Components (`src/frontend/src/forms/`)
```typescript
// New form components with type safety
export default function CreateUserForm() {
  const { data, setData, post, errors } = useForm<CreateUserRequest>({
    name: "",
    email: "",
    bio: null,
  });
}
```

### Technical Challenges

#### 1. **Request Body Parsing**
- Wisp request body handling vs Inertia.js form encoding
- Proper JSON vs form-data handling
- Error handling for malformed requests

#### 2. **Validation Strategy**
- Client-side validation using TypeScript types
- Server-side validation using Gleam decoders
- Consistent error message formats

#### 3. **Option Type Handling in Forms**
- Form inputs for optional fields (empty string vs None)
- Proper serialization/deserialization
- UI patterns for optional data

#### 4. **Error Response Types**
- Standardized error response format
- Validation error types that work with Inertia.js
- TypeScript integration for error handling

### Risk Assessment
- **Medium Risk**: More complex than page props due to bidirectional data flow
- **Integration Risk**: Inertia.js form handling specifics
- **Type Complexity**: Request/response type coordination
- **Validation Risk**: Ensuring client/server validation consistency

### Dependencies
- **Feature 005**: JSON decoders (completed) - provides foundation pattern
- **Inertia.js**: `useForm` hook and form submission handling
- **Wisp**: Request body parsing and response handling
- **Existing Backend**: Current typed-demo backend structure

### Estimated Effort
- **Shared Types**: 3-4 hours (request types, decoders, validation)
- **Backend Integration**: 4-5 hours (routes, handlers, request parsing)
- **Frontend Forms**: 5-6 hours (components, useForm integration, validation)
- **Error Handling**: 3-4 hours (error types, display, integration)
- **Testing & Polish**: 3-4 hours (edge cases, UX improvements)
- **Total**: 18-23 hours

### Success Metrics
1. **Type Safety**: Forms cannot be submitted with wrong data types
2. **Developer Experience**: Clear error messages and IntelliSense support
3. **User Experience**: Proper form validation and error display
4. **Code Quality**: Consistent patterns that can be replicated
5. **Documentation**: Examples that other developers can follow

## Log

### Status: Ready for Implementation
**Next Required Action**: Begin implementing shared request types and decoders

**Key Files to Create/Modify**:
- `src/shared/src/types.gleam` - Add request types and decoders
- `src/backend/src/handlers.gleam` - Form submission handlers  
- `src/backend/src/typed_demo_backend.gleam` - Add routes
- `src/frontend/src/forms/` - New form components directory
- `src/frontend/src/main.tsx` - Add form routes

## Conclusion

This feature will complete the type safety picture for the typed-demo by adding comprehensive form submission examples. It demonstrates the full power of shared types between Gleam and TypeScript, covering both directions of data flow.

The implementation will serve as a production-ready template for building type-safe forms in Inertia Wisp applications, showing best practices for:
- Shared request/response types
- Proper validation patterns  
- Error handling strategies
- Integration with Inertia.js form utilities

## Ideal Next Prompt

"I'm ready to implement Feature 006: Typed Form Submissions for the typed-demo. We completed Feature 005 (JSON decoders) successfully, which provides the foundation pattern for this work.

Please implement comprehensive typed form submissions that demonstrate:

1. **Shared request types** between TypeScript and Gleam (following the same pattern as page props)
2. **Integration with Inertia.js useForm hook** for type-safe form handling
3. **Real-world form examples** like create user, edit profile, etc.
4. **Proper error handling** with typed validation errors

Key requirements:
- Create shared request types in `src/shared/src/types.gleam` (similar to existing page props)
- Add JSON decoders for request bodies (following Feature 005 pattern)  
- Build form components that use `useForm<RequestType>` for type safety
- Add backend routes that handle the typed form submissions
- Include proper Option type handling for optional form fields
- Demonstrate both client-side and server-side validation

The goal is to show a complete, production-ready pattern for type-safe forms that other developers can follow when building Inertia Wisp applications."