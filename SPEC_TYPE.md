# Spec Type - Application Specification

## Overview

The `Spec` type represents the complete contract between frontend and backend in an Inertia.js application. It ties together:

1. **Schemas** - Data types with encoders/decoders
2. **Pages** - React components with their props
3. **Routes** - Backend endpoints that render pages

This single source of truth enables code generation, type checking, and ensures frontend-backend synchronization.

## Type Definitions

### Core Spec Type

```gleam
pub type Spec {
  Spec(
    schemas: List(RecordSchema),
    pages: List(PageDef),
    routes: List(RouteDef),
  )
}
```

### Page Definition

A page represents a React component with typed props:

```gleam
pub type PageDef {
  PageDef(
    name: String,           // Page identifier (e.g., "UserShow")
    component_path: String, // React component path (e.g., "Pages/Users/Show")
    props: List(PropDef),   // Props this page expects
  )
}
```

### Prop Definition

Defines a single prop for a page:

```gleam
pub type PropDef {
  PropDef(
    name: String,        // Prop name (e.g., "user")
    schema_name: String, // Type reference (e.g., "User")
    kind: PropKind,      // How Inertia handles this prop
  )
}
```

### Prop Kinds

```gleam
pub type PropKind {
  DefaultProp              // Always included in response
  LazyProp                 // Only when explicitly requested
  DeferredProp             // Loaded asynchronously after initial load
  AlwaysProp               // Never cached, included in every request
  OptionalProp             // Only when explicitly requested
  MergeProp(deep: Bool)    // Merged with existing prop value
}
```

### Route Definition

Defines a backend endpoint:

```gleam
pub type RouteDef {
  RouteDef(
    name: String,                    // Route name (e.g., "users.show")
    path: String,                    // URL pattern (e.g., "/users/:id")
    method: HttpMethod,              // GET, POST, PUT, PATCH, DELETE
    params: List(ParamDef),          // Path parameters
    query_params: List(ParamDef),    // Query parameters
    body: Option(String),            // Request body schema name
    page: String,                    // Page to render
  )
}
```

### Parameter Definition

```gleam
pub type ParamDef {
  ParamDef(
    name: String,
    param_type: ParamType,  // StringParam, IntParam, FloatParam, BoolParam, UUIDParam
  )
}
```

## Building a Spec

### Using Builder API

```gleam
import inertia_wisp/spec
import inertia_wisp/schema

pub fn app_spec() -> spec.Spec {
  spec.new()
  |> spec.with_schemas([
    user_schema(),
    post_schema(),
    pagination_schema(),
  ])
  |> spec.with_pages([
    spec.PageDef(
      name: "PostIndex",
      component_path: "Pages/Posts/Index",
      props: [
        spec.PropDef(name: "posts", schema_name: "Post", kind: spec.LazyProp),
        spec.PropDef(name: "pagination", schema_name: "PaginationInfo", kind: spec.DefaultProp),
      ],
    ),
    spec.PageDef(
      name: "PostShow",
      component_path: "Pages/Posts/Show",
      props: [
        spec.PropDef(name: "post", schema_name: "Post", kind: spec.DefaultProp),
      ],
    ),
  ])
  |> spec.with_routes([
    spec.RouteDef(
      name: "posts.index",
      path: "/posts",
      method: spec.GET,
      params: [],
      query_params: [
        spec.ParamDef(name: "page", param_type: spec.IntParam),
      ],
      body: option.None,
      page: "PostIndex",
    ),
    spec.RouteDef(
      name: "posts.show",
      path: "/posts/:id",
      method: spec.GET,
      params: [
        spec.ParamDef(name: "id", param_type: spec.IntParam),
      ],
      query_params: [],
      body: option.None,
      page: "PostShow",
    ),
  ])
}
```

## Lookup Functions

The spec module provides convenient lookup functions:

### Schema Lookup

```gleam
let schemas = spec.schema_map(app_spec)
let assert Ok(user_schema) = dict.get(schemas, "User")
```

### Page Lookup

```gleam
let pages = spec.page_map(app_spec)
let assert Ok(post_index_page) = dict.get(pages, "PostIndex")
```

### Route Lookup

```gleam
let routes = spec.route_map(app_spec)
let assert Ok(posts_index_route) = dict.get(routes, "posts.index")
```

## Complete Example

```gleam
// Define types
pub type User {
  User(id: Int, name: String, email: String)
}

pub type Post {
  Post(id: Int, title: String, body: String, author: User)
}

// Define schemas
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

pub fn post_schema() -> schema.RecordSchema {
  let default_user = User(id: 0, name: "", email: "")
  schema.record_schema("Post", Post(id: 0, title: "", body: "", author: default_user))
  |> schema.field("id", schema.IntType, fn(p) { p.id }, fn(p, id) {
    Post(..p, id: id)
  })
  |> schema.field("title", schema.StringType, fn(p) { p.title }, fn(p, t) {
    Post(..p, title: t)
  })
  |> schema.field("body", schema.StringType, fn(p) { p.body }, fn(p, b) {
    Post(..p, body: b)
  })
  |> schema.field("author", schema.RecordType(user_schema), fn(p) { p.author }, fn(p, a) {
    Post(..p, author: a)
  })
  |> schema.schema()
}

// Build the spec
pub fn blog_spec() -> spec.Spec {
  spec.new()
  |> spec.with_schemas([user_schema(), post_schema()])
  |> spec.with_pages([
    spec.PageDef(
      name: "PostIndex",
      component_path: "Pages/Posts/Index",
      props: [
        spec.PropDef(name: "posts", schema_name: "Post", kind: spec.LazyProp),
      ],
    ),
    spec.PageDef(
      name: "PostShow",
      component_path: "Pages/Posts/Show",
      props: [
        spec.PropDef(name: "post", schema_name: "Post", kind: spec.DefaultProp),
        spec.PropDef(name: "related", schema_name: "Post", kind: spec.DeferredProp),
      ],
    ),
  ])
  |> spec.with_routes([
    spec.RouteDef(
      name: "posts.index",
      path: "/posts",
      method: spec.GET,
      params: [],
      query_params: [],
      body: option.None,
      page: "PostIndex",
    ),
    spec.RouteDef(
      name: "posts.show",
      path: "/posts/:id",
      method: spec.GET,
      params: [spec.ParamDef(name: "id", param_type: spec.IntParam)],
      query_params: [],
      body: option.None,
      page: "PostShow",
    ),
  ])
}
```

## Use Cases

### 1. Code Generation

Generate TypeScript types and Zod schemas:

```gleam
import gleam/list
import simplifile

pub fn generate_frontend_types(app_spec: spec.Spec) {
  let zod_schemas = 
    app_spec.schemas
    |> list.map(schema.to_zod_schema)
    |> string.join("\n\n")
  
  let output = "import { z } from \"zod\";\n\n" <> zod_schemas
  
  simplifile.write(
    to: "frontend/src/generated/schemas.ts",
    contents: output
  )
}
```

### 2. Route Validation

Ensure all routes reference valid pages:

```gleam
pub fn validate_routes(app_spec: spec.Spec) -> Result(Nil, String) {
  let page_names = app_spec.pages |> list.map(fn(p) { p.name })
  
  app_spec.routes
  |> list.try_each(fn(route) {
    case list.contains(page_names, route.page) {
      True -> Ok(Nil)
      False -> Error("Route " <> route.name <> " references unknown page: " <> route.page)
    }
  })
}
```

### 3. Page Props Validation

Ensure all prop schemas exist:

```gleam
pub fn validate_page_props(app_spec: spec.Spec) -> Result(Nil, String) {
  let schema_names = app_spec.schemas |> list.map(fn(s) { s.name })
  
  app_spec.pages
  |> list.flat_map(fn(page) { page.props })
  |> list.try_each(fn(prop) {
    case list.contains(schema_names, prop.schema_name) {
      True -> Ok(Nil)
      False -> Error("Prop references unknown schema: " <> prop.schema_name)
    }
  })
}
```

### 4. Generate Route Helpers

Generate type-safe route functions:

```gleam
pub fn generate_route_helpers(app_spec: spec.Spec) -> String {
  app_spec.routes
  |> list.map(generate_route_function)
  |> string.join("\n\n")
}

fn generate_route_function(route: spec.RouteDef) -> String {
  // Generate TypeScript function for this route
  // e.g., postsShow(id: number) => `/posts/${id}`
  todo
}
```

## Integration with Schema System

The Spec type works seamlessly with the schema system:

```gleam
// 1. Define schemas (with encode/decode capabilities)
let user_schema = user_schema()

// 2. Add to spec
let app_spec = spec.new() |> spec.with_schemas([user_schema])

// 3. Generate frontend code
let zod_code = schema.to_zod_schema(user_schema)

// 4. Use in handlers
let json = schema.to_json(user_schema, my_user)
let decoded = schema.decode(user_schema, json_data)
```

## Benefits

1. **Single Source of Truth**: All frontend-backend contract info in one place
2. **Type Safety**: Compile-time checking of references between schemas, pages, and routes
3. **Code Generation**: Generate TypeScript, Zod, and route helpers automatically
4. **Validation**: Validate spec consistency before deployment
5. **Documentation**: Spec serves as living documentation of your API
6. **Tooling**: Enable IDE support, API explorers, and testing tools

## Best Practices

1. **Keep Spec in One File**: Define your entire application spec in a single module
2. **Validate Early**: Run spec validation in CI/CD before deployment
3. **Generate During Build**: Regenerate frontend code as part of build process
4. **Version Control**: Check generated files into git for visibility
5. **Document Prop Kinds**: Clearly document when to use lazy vs deferred props
6. **Consistent Naming**: Use consistent naming conventions (e.g., `posts.index`, `posts.show`)

## Future Enhancements

- Variant type support (discriminated unions)
- Form schemas with validations
- API documentation generation
- OpenAPI/Swagger export
- GraphQL schema generation
- Route parameter validation at runtime
- Automatic test generation from spec

## Conclusion

The Spec type provides a powerful foundation for building type-safe, full-stack applications with Gleam and React. By defining your entire application contract in one place, you enable robust code generation, validation, and tooling while maintaining perfect synchronization between frontend and backend.