# Code Generation - Frontend/Backend Type Synchronization

## Overview

This presentation app now uses **automatic code generation** to keep TypeScript/Zod schemas synchronized with Gleam types. Instead of manually maintaining types in `shared/`, we define schemas in the backend and generate TypeScript code automatically.

## What Changed

### Before

```
shared/
  └── src/shared/
      ├── user.gleam          # Type + manual encoder
      └── forms.gleam         # Type + manual encoder

frontend/
  └── src/schemas.ts          # Manual Zod schemas
```

**Problems:**
- Types defined in 3 places (Gleam type, Gleam encoder, Zod schema)
- Manual synchronization required
- Easy to get out of sync
- Shared code requires JavaScript compilation

### After

```
backend/
  └── src/
      ├── schemas/
      │   ├── user.gleam              # Type + schema definition
      │   └── contact_form.gleam      # Type + schema definition
      └── codegen.gleam               # Code generator

shared/
  └── src/shared/
      └── forms.gleam                 # Only validation logic

frontend/
  └── src/generated/
      └── schemas.ts                  # Auto-generated!
```

**Benefits:**
- Single source of truth (Gleam schema)
- Automatic Zod generation
- Can't get out of sync
- Validation logic remains shared

## How It Works

### 1. Define Schema in Backend

```gleam
// backend/src/schemas/user.gleam
import inertia_wisp/schema

pub type User {
  User(id: Int, name: String, email: String)
}

pub fn user_schema() -> schema.RecordSchema {
  schema.record_schema("User", User(id: 0, name: "", email: ""))
  |> schema.field("id", schema.IntType, fn(u) { u.id }, fn(u, id) {
    User(..u, id: id)
  })
  |> schema.field("name", schema.StringType, fn(u) { u.name }, fn(u, name) {
    User(..u, name: name)
  })
  |> schema.field("email", schema.StringType, fn(u) { u.email }, fn(u, email) {
    User(..u, email: email)
  })
  |> schema.schema()
}
```

### 2. Register Schema in Codegen

```gleam
// backend/src/codegen.gleam
import schemas/user

pub fn main() {
  let output = 
    "import { z } from \"zod\";\n\n"
    <> schema.to_zod_schema(user.user_schema())
  
  simplifile.write(
    to: "../frontend/src/generated/schemas.ts",
    contents: output
  )
}
```

### 3. Run Codegen

```bash
make codegen
```

### 4. Generated Output

```typescript
// frontend/src/generated/schemas.ts
// Auto-generated from Gleam schemas - DO NOT EDIT

import { z } from "zod";

export const UserSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.string(),
}).strict();

export type User = z.infer<typeof UserSchema>;
```

### 5. Use in Backend

```gleam
import inertia_wisp/schema
import schemas/user

// Encoding
let json = schema.to_json(user.user_schema(), my_user)

// Decoding
let result = schema.decode(user.user_schema(), json_data)
```

### 6. Use in Frontend

```typescript
import { UserSchema, type User } from "./generated/schemas";

// Runtime validation
const user = UserSchema.parse(apiData);

// TypeScript knows exact shape
console.log(user.id, user.name, user.email);
```

## Workflow

### During Development

1. **Modify schema** in `backend/src/schemas/`
2. **Run codegen**: `make codegen`
3. **Build frontend**: Frontend now has updated types
4. **TypeScript errors** show where frontend needs updates

### During Build

The `make build` command automatically runs codegen:

```bash
make build  # Runs codegen, then builds frontend and backend
```

## Examples in This App

### User Schema

**Location:** `backend/src/schemas/user.gleam`

**Used by:**
- `handlers/users_table.gleam` - Paginated user list

**Generated:** `UserSchema` and `User` type

### ContactFormData Schema

**Location:** `backend/src/schemas/contact_form.gleam`

**Used by:**
- `handlers/forms.gleam` - Contact form submission

**Validation:** `shared/forms.gleam` contains `validate_name()` function

**Generated:** `ContactFormDataSchema` and `ContactFormData` type

### ImageData Schema

**Location:** `backend/src/schemas/content.gleam`

**Used by:**
- Slide content definitions (various `slides/slide_*.gleam` files)

**Generated:** `ImageDataSchema` and `ImageData` type

### SlideNavigation Schema

**Location:** `backend/src/schemas/content.gleam`

**Used by:**
- `handlers/slides.gleam` - Slide navigation
- `props/slide_props.gleam` - Slide page props

**Generated:** `SlideNavigationSchema` and `SlideNavigation` type

## Shared Validation Logic

Pure validation functions can remain in `shared/` for use by both frontend and backend:

```gleam
// shared/src/shared/forms.gleam
pub fn validate_name(name: String) -> Result(String, String) {
  case string.trim(name) {
    "" -> Error("Name is required")
    trimmed -> {
      case string.length(trimmed) < 2 {
        True -> Error("Name must be at least 2 characters")
        False -> Ok(trimmed)
      }
    }
  }
}
```

**Backend usage:** Import directly from `shared/forms`

**Frontend usage:** Compile with `gleam build --target javascript`

## What About Variant Types?

Complex types like `ContentBlock` (discriminated unions with recursive references) are not yet supported by the schema system. These remain in `shared/content.gleam` with manual JSON encoders until variant type support is added.

```gleam
// shared/src/shared/content.gleam - Still using manual encoding
pub type ContentBlock {
  Heading(text: String)
  Paragraph(text: String)
  Columns(left: List(ContentBlock), right: List(ContentBlock))  // Recursive!
  // ... other variants
}

pub fn content_block_to_json(block: ContentBlock) -> json.Json {
  // Manual encoding for now
}
```

**Future:** Variant type support will allow these to be migrated to schemas as well.

## Adding New Types

### Step 1: Create Schema Module

```gleam
// backend/src/schemas/post.gleam
import inertia_wisp/schema

pub type Post {
  Post(id: Int, title: String, body: String)
}

pub fn post_schema() -> schema.RecordSchema {
  schema.record_schema("Post", Post(id: 0, title: "", body: ""))
  |> schema.field("id", schema.IntType, fn(p) { p.id }, fn(p, id) {
    Post(..p, id: id)
  })
  |> schema.field("title", schema.StringType, fn(p) { p.title }, fn(p, title) {
    Post(..p, title: title)
  })
  |> schema.field("body", schema.StringType, fn(p) { p.body }, fn(p, body) {
    Post(..p, body: body)
  })
  |> schema.schema()
}
```

### Step 2: Add to Codegen

```gleam
// backend/src/codegen.gleam
import schemas/post

pub fn main() {
  let output = 
    "import { z } from \"zod\";\n\n"
    <> schema.to_zod_schema(user.user_schema())
    <> "\n\n"
    <> schema.to_zod_schema(contact_form.contact_form_data_schema())
    <> "\n\n"
    <> schema.to_zod_schema(content.image_data_schema())
    <> "\n\n"
    <> schema.to_zod_schema(content.slide_navigation_schema())
    <> "\n\n"
    <> schema.to_zod_schema(post.post_schema())  // Add new schemas here
  
  // ... write to file
}
```

### Step 3: Run Codegen

```bash
make codegen
```

### Step 4: Use Everywhere

**Backend:**
```gleam
import schemas/post

let json = schema.to_json(post.post_schema(), my_post)
```

**Frontend:**
```typescript
import { PostSchema, type Post } from "./generated/schemas";

const post: Post = PostSchema.parse(data);
```

## Nested Types

Schemas support nested records:

```gleam
pub type Author {
  Author(id: Int, name: String)
}

pub type Post {
  Post(id: Int, title: String, author: Author)
}

pub fn post_schema() -> schema.RecordSchema {
  schema.record_schema("Post", Post(...))
  |> schema.field("author", schema.RecordType(author_schema), ...)
  |> schema.schema()
}
```

Generates:

```typescript
export const PostSchema = z.object({
  id: z.number(),
  title: z.string(),
  author: AuthorSchema,  // References other schema
}).strict();
```

## Lists and Arrays

```gleam
pub type TaggedPost {
  TaggedPost(id: Int, tags: List(String))
}

pub fn tagged_post_schema() -> schema.RecordSchema {
  schema.record_schema("TaggedPost", TaggedPost(id: 0, tags: []))
  |> schema.field("tags", schema.ListType(schema.StringType), ...)
  |> schema.schema()
}
```

Generates:

```typescript
export const TaggedPostSchema = z.object({
  id: z.number(),
  tags: z.array(z.string()),
}).strict();
```

## Best Practices

### ✅ Do

- **Define schemas in backend** for all API types
- **Run codegen before building** (automated in Makefile)
- **Commit generated files** so changes are visible in git
- **Keep validation logic in shared/** if used by frontend and backend
- **Use schemas for encoding/decoding** instead of manual functions

### ❌ Don't

- **Don't edit generated files** - they're overwritten on every run
- **Don't define types in shared/** - use backend schemas instead
- **Don't manually write Zod schemas** - let codegen handle it
- **Don't skip codegen** - frontend types will be stale

## Troubleshooting

### "Module does not exist" in handlers

**Problem:** Handler imports from `shared/user` but type moved to `schemas/user`

**Solution:** Update imports:
```gleam
// Before
import shared/user.{type User, User, user_to_json}

// After
import schemas/user.{type User, User, user_schema}
import inertia_wisp/schema
```

### TypeScript errors about missing types

**Problem:** Generated schemas are out of date

**Solution:** Run codegen:
```bash
make codegen
```

### Generated file not found

**Problem:** Directory doesn't exist

**Solution:** Create it:
```bash
mkdir -p frontend/src/generated
```

## Summary

The codegen system provides:

- ✅ **Single source of truth** - Define types once in Gleam
- ✅ **Automatic synchronization** - Frontend types stay in sync
- ✅ **Type safety** - TypeScript + Zod validation
- ✅ **Less boilerplate** - No manual Zod schemas
- ✅ **Shared validation** - Pure functions remain in shared/
- ✅ **Build integration** - Runs automatically during build

This eliminates the manual work of keeping frontend and backend types synchronized while maintaining full type safety across the stack.