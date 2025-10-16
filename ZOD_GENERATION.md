# Zod Schema Generation

## Overview

The `to_zod_schema()` function generates TypeScript/Zod schema definitions from Gleam schemas. This enables automatic generation of frontend type-safe validation schemas from backend type definitions, ensuring perfect synchronization between frontend and backend.

## Benefits

- **Single Source of Truth**: Define types once in Gleam, generate Zod schemas automatically
- **Type Safety**: Generated TypeScript types match Gleam types exactly
- **Zero Manual Sync**: No need to manually keep frontend and backend types in sync
- **Validation Ready**: Generated Zod schemas can validate API responses immediately
- **IntelliSense Support**: Generated TypeScript types provide full IDE autocomplete

## API

```gleam
pub fn to_zod_schema(schema: RecordSchema) -> String
```

Takes a `RecordSchema` and returns a string containing:
1. A Zod schema constant (e.g., `UserSchema`)
2. A TypeScript type definition (e.g., `type User`)

## Generated Code Format

### Simple Record

**Input (Gleam):**
```gleam
pub type User {
  User(id: Int, name: String, email: String)
}

pub fn user_schema() -> schema.RecordSchema {
  schema.record_schema("User", User(id: 0, name: "", email: ""))
  |> schema.field("id", schema.IntType, fn(u) { u.id }, fn(u, id) {
    User(..u, id: id)
  })
  |> schema.field("name", schema.StringType, fn(u) { u.name }, fn(u, n) {
    User(..u, name: n)
  })
  |> schema.field("email", schema.StringType, fn(u) { u.email }, fn(u, e) {
    User(..u, email: e)
  })
  |> schema.schema()
}
```

**Output (TypeScript):**
```typescript
export const UserSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.string(),
}).strict();

export type User = z.infer<typeof UserSchema>;
```

### Lists

**Input (Gleam):**
```gleam
pub type TaggedItem {
  TaggedItem(id: Int, tags: List(String), scores: List(Int))
}

pub fn tagged_item_schema() -> schema.RecordSchema {
  schema.record_schema("TaggedItem", TaggedItem(id: 0, tags: [], scores: []))
  |> schema.field("id", schema.IntType, fn(t) { t.id }, fn(t, id) {
    TaggedItem(..t, id: id)
  })
  |> schema.field("tags", schema.ListType(schema.StringType), fn(t) { t.tags }, fn(t, tags) {
    TaggedItem(..t, tags: tags)
  })
  |> schema.field("scores", schema.ListType(schema.IntType), fn(t) { t.scores }, fn(t, s) {
    TaggedItem(..t, scores: s)
  })
  |> schema.schema()
}
```

**Output (TypeScript):**
```typescript
export const TaggedItemSchema = z.object({
  id: z.number(),
  tags: z.array(z.string()),
  scores: z.array(z.number()),
}).strict();

export type TaggedItem = z.infer<typeof TaggedItemSchema>;
```

### Nested Records

**Input (Gleam):**
```gleam
pub type Address {
  Address(street: String, city: String)
}

pub type Person {
  Person(name: String, address: Address)
}

pub fn address_schema() -> schema.RecordSchema {
  schema.record_schema("Address", Address(street: "", city: ""))
  |> schema.field("street", schema.StringType, fn(a) { a.street }, fn(a, s) {
    Address(..a, street: s)
  })
  |> schema.field("city", schema.StringType, fn(a) { a.city }, fn(a, c) {
    Address(..a, city: c)
  })
  |> schema.schema()
}

pub fn person_schema() -> schema.RecordSchema {
  schema.record_schema("Person", Person(name: "", address: Address(street: "", city: "")))
  |> schema.field("name", schema.StringType, fn(p) { p.name }, fn(p, n) {
    Person(..p, name: n)
  })
  |> schema.field("address", schema.RecordType(address_schema), fn(p) { p.address }, fn(p, a) {
    Person(..p, address: a)
  })
  |> schema.schema()
}
```

**Output (TypeScript):**
```typescript
// Address must be generated first
export const AddressSchema = z.object({
  street: z.string(),
  city: z.string(),
}).strict();

export type Address = z.infer<typeof AddressSchema>;

// Person references AddressSchema
export const PersonSchema = z.object({
  name: z.string(),
  address: AddressSchema,
}).strict();

export type Person = z.infer<typeof PersonSchema>;
```

### Lists of Nested Records

**Input (Gleam):**
```gleam
pub type Team {
  Team(name: String, members: List(Person))
}

pub fn team_schema() -> schema.RecordSchema {
  schema.record_schema("Team", Team(name: "", members: []))
  |> schema.field("name", schema.StringType, fn(t) { t.name }, fn(t, n) {
    Team(..t, name: n)
  })
  |> schema.field("members", schema.ListType(schema.RecordType(person_schema)), fn(t) { t.members }, fn(t, m) {
    Team(..t, members: m)
  })
  |> schema.schema()
}
```

**Output (TypeScript):**
```typescript
export const TeamSchema = z.object({
  name: z.string(),
  members: z.array(PersonSchema),
}).strict();

export type Team = z.infer<typeof TeamSchema>;
```

### Nested Lists

**Input (Gleam):**
```gleam
pub type Grid {
  Grid(data: List(List(Int)))
}

pub fn grid_schema() -> schema.RecordSchema {
  schema.record_schema("Grid", Grid(data: []))
  |> schema.field("data", schema.ListType(schema.ListType(schema.IntType)), fn(g) { g.data }, fn(g, d) {
    Grid(data: d)
  })
  |> schema.schema()
}
```

**Output (TypeScript):**
```typescript
export const GridSchema = z.object({
  data: z.array(z.array(z.number())),
}).strict();

export type Grid = z.infer<typeof GridSchema>;
```

## Type Mappings

| Gleam Type | Zod Type | TypeScript Type |
|------------|----------|-----------------|
| `String` | `z.string()` | `string` |
| `Int` | `z.number()` | `number` |
| `Float` | `z.number()` | `number` |
| `Bool` | `z.boolean()` | `boolean` |
| `List(T)` | `z.array(T)` | `T[]` |
| `RecordType` | `SchemaName` | `TypeName` |

## Usage in Application

### Step 1: Define Schemas in Gleam

```gleam
// backend/src/shared/user.gleam
import inertia_wisp/schema

pub type User {
  User(id: Int, name: String, email: String)
}

pub fn user_schema() -> schema.RecordSchema {
  schema.record_schema("User", User(id: 0, name: "", email: ""))
  |> schema.field("id", schema.IntType, fn(u) { u.id }, fn(u, id) {
    User(..u, id: id)
  })
  |> schema.field("name", schema.StringType, fn(u) { u.name }, fn(u, n) {
    User(..u, name: n)
  })
  |> schema.field("email", schema.StringType, fn(u) { u.email }, fn(u, e) {
    User(..u, email: e)
  })
  |> schema.schema()
}
```

### Step 2: Generate Zod Schemas

Create a codegen script:

```gleam
// backend/src/codegen.gleam
import gleam/io
import simplifile
import inertia_wisp/schema
import shared/user

pub fn main() {
  let output = 
    "import { z } from \"zod\";\n\n"
    <> schema.to_zod_schema(user.user_schema())
    <> "\n"
  
  let assert Ok(_) = simplifile.write(
    to: "frontend/src/generated/schemas.ts",
    contents: output
  )
  
  io.println("✓ Generated frontend/src/generated/schemas.ts")
}
```

Run with:
```bash
gleam run -m codegen
```

### Step 3: Use in Frontend

```typescript
// frontend/src/Pages/Users.tsx
import { UserSchema, type User } from "../generated/schemas";

function UsersPage({ users }: { users: User[] }) {
  // TypeScript knows the exact shape of users
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name} - {user.email}</li>
      ))}
    </ul>
  );
}

// Validate API responses
async function fetchUsers(): Promise<User[]> {
  const response = await fetch('/api/users');
  const data = await response.json();
  
  // Runtime validation with Zod
  const result = z.array(UserSchema).safeParse(data);
  
  if (!result.success) {
    throw new Error('Invalid user data from API');
  }
  
  return result.data; // Type-safe!
}
```

## Code Generation Workflow

### Manual Generation

```gleam
import inertia_wisp/schema
import gleam/io

pub fn main() {
  let zod_code = schema.to_zod_schema(my_schema())
  io.println(zod_code)
}
```

### Automated Generation

Create a Makefile target:

```makefile
.PHONY: codegen
codegen:
	gleam run -m codegen
	cd frontend && npm run typecheck
```

### Watch Mode

For development, set up a file watcher:

```bash
# Using entr or similar
ls backend/src/shared/*.gleam | entr make codegen
```

## Dependency Order

When generating multiple schemas, ensure dependencies are generated first:

```gleam
pub fn generate_all() -> String {
  "import { z } from \"zod\";\n\n"
  <> schema.to_zod_schema(address_schema())  // Generate Address first
  <> "\n\n"
  <> schema.to_zod_schema(person_schema())   // Then Person (depends on Address)
  <> "\n\n"
  <> schema.to_zod_schema(team_schema())     // Then Team (depends on Person)
}
```

## Features

### Strict Mode

All generated schemas use `.strict()` to reject unknown properties:

```typescript
const UserSchema = z.object({
  id: z.number(),
  name: z.string(),
}).strict();

// ✅ Valid
UserSchema.parse({ id: 1, name: "Alice" });

// ❌ Throws error - unknown property
UserSchema.parse({ id: 1, name: "Alice", extra: "field" });
```

### Type Inference

TypeScript types are inferred from Zod schemas:

```typescript
export const UserSchema = z.object({
  id: z.number(),
  name: z.string(),
}).strict();

// Automatically inferred type
export type User = z.infer<typeof UserSchema>;
// Equivalent to: { id: number; name: string; }
```

## Limitations and Future Work

### Current Limitations

1. **No variant types**: Discriminated unions not yet supported
2. **No optional fields**: All fields are currently required
3. **No validations**: Min/max length, patterns, etc. not yet generated
4. **No custom types**: Only built-in types supported

### Planned Features

1. **Variant Types**:
   ```typescript
   const ContentBlockSchema = z.discriminatedUnion("type", [
     z.object({ type: z.literal("heading"), text: z.string() }),
     z.object({ type: z.literal("paragraph"), text: z.string() }),
   ]);
   ```

2. **Optional Fields**:
   ```typescript
   z.object({
     name: z.string(),
     email: z.string().optional(),
   })
   ```

3. **Validations**:
   ```typescript
   z.object({
     name: z.string().min(2).max(100),
     email: z.string().email(),
     age: z.number().int().positive(),
   })
   ```

4. **Custom Transformations**:
   ```typescript
   z.object({
     date: z.string().datetime().transform(d => new Date(d)),
   })
   ```

## Best Practices

1. **Generate During Build**: Run codegen as part of CI/CD to ensure schemas stay in sync
2. **Check Generated Files**: Commit generated files to git for version control
3. **Validate at Boundaries**: Use Zod schemas to validate all external data
4. **Single Source of Truth**: Keep Gleam schemas as the authoritative source
5. **Test Generated Code**: Ensure TypeScript compiles and tests pass after generation

## Testing Generated Schemas

```typescript
// frontend/test/schemas.test.ts
import { describe, it, expect } from 'vitest';
import { UserSchema } from '../generated/schemas';

describe('UserSchema', () => {
  it('validates correct user data', () => {
    const result = UserSchema.safeParse({
      id: 1,
      name: "Alice",
      email: "alice@example.com"
    });
    
    expect(result.success).toBe(true);
  });
  
  it('rejects invalid data', () => {
    const result = UserSchema.safeParse({
      id: "not a number",
      name: "Alice",
    });
    
    expect(result.success).toBe(false);
  });
});
```

## Integration with Inertia.js

```typescript
// Validate Inertia page props
import { router } from '@inertiajs/react';
import { UserPagePropsSchema, type UserPageProps } from './generated/schemas';

function UsersPage(props: unknown) {
  // Validate props at runtime
  const validated = UserPagePropsSchema.parse(props);
  
  // Now TypeScript knows the exact shape
  const { users, pagination } = validated;
  
  return <div>{/* render */}</div>;
}
```

## Conclusion

The Zod schema generation provides a seamless bridge between Gleam backend types and TypeScript frontend types, ensuring type safety and validation across the entire stack. Combined with the schema's encode/decode capabilities, this creates a robust foundation for building type-safe full-stack applications.