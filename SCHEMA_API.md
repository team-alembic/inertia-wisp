# Schema API for Type-Safe Frontend-Backend Integration

## Motivation

The original plan was to define types in a separate spec format (Gleam data structures or YAML) that would generate both Gleam types and TypeScript types. However, this felt unsatisfactory because:

1. **Redundancy**: Describing Gleam types to generate Gleam types is circular
2. **Separation**: Schema definitions would be far from the actual type definitions
3. **Maintenance**: Two sources of truth (spec + generated code) that can drift

## New Approach: Co-located Schemas

Instead of separate spec files, we define schemas **alongside** the Gleam types they describe. A single schema function serves **three purposes**:

1. **JSON Encoding**: Replaces manual `to_json` functions
2. **JSON Decoding**: Replaces manual `decode` functions  
3. **Code Generation**: Provides metadata to generate TypeScript/Zod schemas

## API Structure

### Core Types

```gleam
pub type FieldType {
  StringType
  IntType
  FloatType
  BoolType
  ListType(inner: FieldType)
  RecordType(schema: fn() -> RecordSchema)
}

pub type Field {
  Field(
    field_type: FieldType,
    get: fn(Dynamic) -> Dynamic,
    set: fn(Dynamic, Dynamic) -> Dynamic,
    optional: Bool,
    validations: List(Validation),
  )
}

pub type RecordSchema {
  RecordSchema(name: String, fields: Dict(String, Field))
}
```

### Builder API

```gleam
// Create a new schema with a default value for decoding
pub fn record_schema(name: String, default: t) -> SchemaBuilder(t)

// Add a field
pub fn field(
  schema: SchemaBuilder(t),
  name: String,
  field_type: FieldType,
  getter: fn(t) -> field_value,
  setter: fn(t, field_value) -> t,
) -> SchemaBuilder(t)

// Extract the final schema
pub fn schema(builder: SchemaBuilder(t)) -> RecordSchema

// Generic encoding/decoding
pub fn to_json(schema: RecordSchema, value: t) -> json.Json
pub fn decode(schema: RecordSchema, value: Dynamic) -> Result(t, String)

// Code generation
pub fn to_zod_schema(schema: RecordSchema) -> String
```

## Usage Examples

### Simple Record Type

**Traditional approach (two functions)**:
```gleam
pub type User {
  User(id: Int, name: String, email: String)
}

pub fn user_to_json(u: User) -> json.Json {
  json.object([
    #("id", json.int(u.id)),
    #("name", json.string(u.name)),
    #("email", json.string(u.email)),
  ])
}

pub fn decode_user(dyn: Dynamic) -> Result(User, List(DecodeError)) {
  use id <- result.try(dynamic.field("id", dynamic.int)(dyn))
  use name <- result.try(dynamic.field("name", dynamic.string)(dyn))
  use email <- result.try(dynamic.field("email", dynamic.string)(dyn))
  Ok(User(id: id, name: name, email: email))
}
```

**Schema approach (one function)**:
```gleam
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

// Usage
let json = schema.to_json(user_schema(), my_user)
let result = schema.decode(user_schema(), dynamic_data)

// Generate TypeScript/Zod schema
let zod_code = schema.to_zod_schema(user_schema())
// Produces:
// export const UserSchema = z.object({
//   id: z.number(),
//   name: z.string(),
//   email: z.string(),
// }).strict();
// 
// export type User = z.infer<typeof UserSchema>;
```

### With Validations

```gleam
pub fn user_schema() -> schema.RecordSchema {
  schema.record_schema("User", User(id: 0, name: "", email: ""))
  |> schema.field("id", schema.IntType, fn(u) { u.id }, fn(u, id) {
    User(..u, id: id)
  })
  |> schema.field("name", schema.StringType, fn(u) { u.name }, fn(u, name) {
    User(..u, name: name)
  })
  |> schema.validate([schema.MinLength(min: 2), schema.MaxLength(max: 100)])
  |> schema.field("email", schema.StringType, fn(u) { u.email }, fn(u, email) {
    User(..u, email: email)
  })
  |> schema.validate([schema.Email])
  |> schema.schema()
}
```

### Nested Types

```gleam
pub type Address {
  Address(street: String, city: String, zip: String)
}

pub type Person {
  Person(name: String, address: Address)
}

pub fn address_schema() -> schema.RecordSchema {
  schema.record_schema("Address", Address(street: "", city: "", zip: ""))
  |> schema.field("street", schema.StringType, fn(a) { a.street }, fn(a, s) {
    Address(..a, street: s)
  })
  |> schema.field("city", schema.StringType, fn(a) { a.city }, fn(a, c) {
    Address(..a, city: c)
  })
  |> schema.field("zip", schema.StringType, fn(a) { a.zip }, fn(a, z) {
    Address(..a, zip: z)
  })
  |> schema.schema()
}

pub fn person_schema() -> schema.RecordSchema {
  let default_address = Address(street: "", city: "", zip: "")
  schema.record_schema("Person", Person(name: "", address: default_address))
  |> schema.field("name", schema.StringType, fn(p) { p.name }, fn(p, n) {
    Person(..p, name: n)
  })
  |> schema.field(
    "address",
    schema.RecordType(address_schema),
    fn(p) { p.address },
    fn(p, a) { Person(..p, address: a) },
  )
  |> schema.schema()
}
```

## Zod Schema Generation

The schema system can generate TypeScript/Zod schemas for frontend validation:

```gleam
import inertia_wisp/schema
import gleam/io

pub fn main() {
  let zod_code = schema.to_zod_schema(user_schema())
  io.println(zod_code)
}
```

**Output:**
```typescript
export const UserSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.string(),
}).strict();

export type User = z.infer<typeof UserSchema>;
```

### Supported Features

- **Primitive types**: String, Int, Float, Bool map to Zod equivalents
- **Lists**: `List(T)` becomes `z.array(T)`
- **Nested records**: References other schemas by name
- **Lists of records**: `List(RecordType(...))` becomes `z.array(SchemaName)`
- **Nested lists**: `List(List(Int))` becomes `z.array(z.array(z.number()))`
- **Strict validation**: All schemas use `.strict()` to reject unknown properties

See `ZOD_GENERATION.md` for complete documentation and examples.

## Code Generation

The code generator will:

1. **Discover schemas**: Scan for functions returning `RecordSchema`
2. **Extract metadata**: Read field names, types, and validations from the schema
3. **Generate TypeScript types**: 
   ```typescript
   export type User = {
     id: number;
     name: string;
     email: string;
   }
   ```
4. **Generate Zod schemas**:
   ```typescript
   export const UserSchema = z.object({
     id: z.number(),
     name: z.string().min(2).max(100),
     email: z.string().email(),
   }).strict();
   ```

## Main Spec File

The main spec file references schemas and adds routing/page information:

```gleam
// examples/presentation/backend/src/spec.gleam

import shared/user.{user_schema}
import shared/content.{slide_schema, slide_navigation_schema}
import inertia_wisp_codegen/spec

pub fn app_spec() -> spec.Spec {
  spec.Spec(
    schemas: [
      user_schema(),
      slide_schema(),
      slide_navigation_schema(),
    ],
    pages: [
      spec.PageDef(
        name: "Slide",
        component_path: "Pages/Slide",
        props: [
          spec.PropDef(name: "slide", schema: "Slide", kind: spec.DefaultProp),
          spec.PropDef(name: "navigation", schema: "SlideNavigation", kind: spec.DefaultProp),
          spec.PropDef(name: "presentation_title", schema: "String", kind: spec.DefaultProp),
        ],
      ),
    ],
    routes: [
      spec.RouteDef(
        name: "slides.show",
        path: "/slides/:number",
        method: spec.GET,
        params: [spec.ParamDef(name: "number", param_type: spec.IntParam)],
        page: "Slide",
      ),
    ],
  )
}
```

## Benefits

1. **Single Source of Truth**: Type definition and schema are adjacent in the same file
2. **Type Safety**: Getters and setters are type-checked by the Gleam compiler
3. **DRY**: One schema function replaces two (encoder + decoder)
4. **Co-location**: Schema lives with the type it describes
5. **Flexibility**: Can still write manual encoders/decoders for special cases
6. **Introspection**: Code generator can read the schema metadata at compile time

## Future Work

- **Variant types**: Support for discriminated unions (multi-constructor types)
- **Optional fields**: Better API for optional/nullable fields
- **Custom validations**: Allow developers to register custom validation functions
- **Schema registry**: For recursive type references
- **Dynamic decoding**: Complete implementation of the `decode` function
- **YAML schemas**: Alternative to Gleam schemas for configuration-heavy use cases

## Status

✅ Basic schema API implemented and compiling
✅ Simple record types working
✅ JSON encoding working
✅ Field getters/setters working
✅ JSON decoding working (full round-trip support)
✅ Nested records with lazy schema functions
✅ Lists of nested records
✅ Zod schema generation (TypeScript/Zod output)
🚧 Validation system needs completion
⏳ Variant type support not yet started
⏳ Full code generator (pages, routes, props) not yet started