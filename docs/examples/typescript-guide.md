# TypeScript Integration Guide

This guide explains how to maintain type safety between the Gleam backend and React frontend in the Inertia Gleam project.

## Overview

The TypeScript setup ensures compile-time and runtime type safety by:

1. **TypeScript types** that mirror Gleam backend types
2. **Zod schemas** for runtime validation
3. **Page component props** that match backend data exactly
4. **Form state management** with proper typing

## Type System Architecture

### Backend → Frontend Type Flow

```
Gleam Types (Backend)     TypeScript Types (Frontend)     Zod Schemas (Runtime)
─────────────────────     ─────────────────────────────     ──────────────────────
User                 →    interface User                →  UserSchema
CreateUserRequest    →    interface CreateUserRequest   →  CreateUserRequestSchema
Auth object          →    interface Auth               →  AuthSchema
Validation errors    →    ValidationErrors             →  ValidationErrorsSchema
```

### Type Definitions Location

```
src/types/index.ts      - Static TypeScript type definitions
src/schemas/index.ts    - Zod schemas for runtime validation
```

## Page Component Types

Each page component has strongly typed props that correspond to backend handler data:

### Example: ShowUser Page

**Backend (Gleam):**
```gleam
inertia_gleam.context(req)
|> utils.assign_common_props()      // adds auth, csrf_token
|> inertia_gleam.assign_prop("user", user_data)
|> inertia_gleam.render("ShowUser")
```

**Frontend (TypeScript):**
```typescript
interface ShowUserPageProps extends BasePageProps {
  user: User;  // Matches the user_data from Gleam
}

export default function ShowUser({ user, auth, csrf_token }: ShowUserPageProps) {
  // TypeScript ensures user has id, name, email properties
  return <div>{user.name}</div>;
}
```

### Common Props Pattern

All pages inherit from `BasePageProps`:

```typescript
interface BasePageProps {
  auth?: Auth;           // From utils.assign_common_props()
  csrf_token: string;    // From utils.assign_common_props()
  errors?: ValidationErrors; // From inertia_gleam.assign_errors()
}
```

## Form Type Safety

### Form State Typing

Forms use local interfaces that match expected backend input:

```typescript
interface CreateUserFormData {
  name: string;
  email: string;
}

const [formData, setFormData] = useState<CreateUserFormData>({
  name: old?.name || "",
  email: old?.email || "",
});
```

### Form Submission Type Safety

The form data structure matches the Gleam `CreateUserRequest` type:

```typescript
// This object structure matches Gleam's CreateUserRequest decoder
router.post("/users", {
  ...formData,      // name, email
  _token: csrf_token, // token field
});
```

## Runtime Validation with Zod

### Schema Definition

Zod schemas mirror both TypeScript types and Gleam validation rules:

```typescript
export const CreateUserFormSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Email must be valid"),
});
```

### Client-Side Validation

```typescript
const validation = validateFormData(CreateUserFormSchema, formData);

if (!validation.success) {
  setClientErrors(validation.errors);
  return;
}

// Form data is guaranteed to be valid
router.post("/users", validation.data);
```

### Props Validation

Runtime validation ensures backend sends expected data:

```typescript
export default function MyPage(props: unknown) {
  // Validates props match expected schema
  const { user, auth } = validatePageProps(MyPagePropsSchema, props);
  
  // TypeScript now knows user and auth are properly typed
  return <div>{user.name}</div>;
}
```

## Maintaining Type Sync

### When Backend Types Change

1. **Update Gleam types** (e.g., add field to `User`)
2. **Update TypeScript types** in `src/types/index.ts`
3. **Update Zod schemas** in `src/schemas/index.ts`
4. **Run type check** to find usage that needs updating:
   ```bash
   npm run type-check
   ```

### Example: Adding a `role` field to User

**Step 1: Update Gleam (Backend)**
```gleam
pub type User {
  User(id: Int, name: String, email: String, role: String)
}
```

**Step 2: Update TypeScript**
```typescript
export interface User {
  id: number;
  name: string;
  email: string;
  role: string;  // Add new field
}
```

**Step 3: Update Zod Schema**
```typescript
export const UserSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.string().email(),
  role: z.string(),  // Add new field
});
```

**Step 4: Type Check**
```bash
npm run type-check
```

TypeScript will show errors wherever the new `role` field needs to be handled.

## Best Practices

### 1. Always Type Page Props

```typescript
// ✅ Good
interface MyPageProps extends BasePageProps {
  users: User[];
  filter: string;
}

export default function MyPage({ users, filter, auth }: MyPageProps) {
  // ...
}

// ❌ Bad
export default function MyPage(props: any) {
  // ...
}
```

### 2. Use Strict Form State Types

```typescript
// ✅ Good
interface LoginFormData {
  email: string;
  password: string;
}

const [formData, setFormData] = useState<LoginFormData>({
  email: "",
  password: "",
});

// ❌ Bad
const [formData, setFormData] = useState<any>({});
```

### 3. Validate Runtime Data

```typescript
// ✅ Good - Runtime validation
const { users } = validatePageProps(UsersPagePropsSchema, props);

// ❌ Bad - Assumes props are correct
const { users } = props as UsersPageProps;
```

### 4. Keep Types DRY

```typescript
// ✅ Good - Derive types from schemas
export type User = z.infer<typeof UserSchema>;

// ❌ Bad - Duplicate definitions
export const UserSchema = z.object({ /* ... */ });
export interface User { /* same fields again */ }
```

## Type Checking Commands

```bash
# Check all files once
npm run type-check

# Watch mode for development
npm run type-check:watch

# Build with type checking
npm run build
```

## Error Handling

### Common TypeScript Errors

**Error: Property 'x' does not exist on type 'Y'**
- Cause: Backend added/removed a prop
- Fix: Update the corresponding TypeScript interface

**Error: Argument of type 'Z' is not assignable**  
- Cause: Form data doesn't match expected backend input
- Fix: Update form interface or backend decoder

### Runtime Validation Errors

**Props validation fails**
- Cause: Backend sends unexpected data structure
- Debug: Check browser console for Zod error details
- Fix: Update schema or fix backend data serialization

## Testing Types

### Manual Testing

1. Change a Gleam type (add/remove field)
2. Run `npm run type-check`
3. Fix TypeScript errors that appear
4. Test form submissions still work

### Automated Testing

Consider adding tests that validate schemas:

```typescript
import { UserSchema } from '../schemas';

test('UserSchema matches expected structure', () => {
  const validUser = { id: 1, name: "John", email: "john@example.com" };
  expect(() => UserSchema.parse(validUser)).not.toThrow();
});
```

## Advanced Usage

### Conditional Props

For pages with optional data:

```typescript
interface UserPageProps extends BasePageProps {
  user?: User;  // Optional if user might not exist
  isEditing?: boolean;
}
```

### Union Types

For forms with different modes:

```typescript
type FormMode = 'create' | 'edit';

interface UserFormProps extends BasePageProps {
  mode: FormMode;
  user?: User;  // Required only in edit mode
}
```

### Generic Page Props

For reusable page patterns:

```typescript
interface ListPageProps<T> extends BasePageProps {
  items: T[];
  pagination: PaginationInfo;
}

type UsersPageProps = ListPageProps<User>;
```

This TypeScript setup provides a robust foundation for maintaining type safety across the full stack. The combination of compile-time TypeScript checking and runtime Zod validation catches errors early and ensures the frontend and backend stay in sync.