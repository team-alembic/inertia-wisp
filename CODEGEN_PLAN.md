# DESIGN PLAN: Type-Safe Frontend-Backend Integration via Code Generation

## Overview

Replace the manual `shared/` package and TypeScript Zod schemas with a specification-driven code generation system. The spec defines types, routes, pages, and validations in Gleam data structures (with YAML support added later), generating type-safe code for both frontend (TypeScript/Zod) and backend (Gleam).

## Goals

- Eliminate manual synchronization of types between frontend and backend
- Provide compile-time safety across the frontend-backend boundary
- Remove magic strings for page component names
- Generate type-safe wrappers for Inertia router and form functions
- Support complex types including recursive discriminated unions
- Make the system completely optional for application developers

## Architecture

### 1. Spec Definition (Gleam Data Structures)

**Location**: `inertia-wisp/src/inertia_wisp_codegen/spec.gleam`

The spec consists of three main sections:

```gleam
pub type Spec {
  Spec(
    types: List(TypeDef),
    pages: List(PageDef),
    routes: List(RouteDef),
  )
}
```

**TypeDef**: Defines shared data types
```gleam
pub type TypeDef {
  RecordTypeDef(
    name: String,
    fields: List(Field),
    validations: List(Validation),
  )
  VariantTypeDef(
    name: String,
    variants: List(VariantDef),
  )
}

pub type Field {
  Field(
    name: String,
    field_type: FieldType,
    optional: Bool,
  )
}

pub type FieldType {
  StringType
  IntType
  FloatType
  BoolType
  ListType(inner: FieldType)
  RecordType(type_name: String)
}

pub type VariantDef {
  VariantDef(
    tag: String,
    fields: List(Field),
  )
}

pub type Validation {
  MinLength(field: String, min: Int)
  MaxLength(field: String, max: Int)
  Pattern(field: String, regex: String, message: String)
  Email(field: String)
  Required(field: String)
}
```

**PageDef**: Defines frontend pages and their props
```gleam
pub type PageDef {
  PageDef(
    name: String,
    component_path: String,  // e.g., "Pages/Slide"
    props: List(PropDef),
  )
}

pub type PropDef {
  PropDef(
    name: String,
    prop_type: String,  // References a TypeDef name
    kind: PropKind,
  )
}

pub type PropKind {
  DefaultProp
  OptionalProp
  LazyProp
  DeferredProp
  AlwaysProp
  MergeProp(deep: Bool)
}
```

**RouteDef**: Defines backend routes with params and bodies
```gleam
pub type RouteDef {
  RouteDef(
    name: String,
    path: String,
    method: HttpMethod,
    params: List(ParamDef),
    query_params: List(ParamDef),
    body: Option(String),  // References a TypeDef name
    page: String,  // References a PageDef name
  )
}

pub type HttpMethod {
  GET
  POST
  PUT
  PATCH
  DELETE
}

pub type ParamDef {
  ParamDef(
    name: String,
    param_type: ParamType,
  )
}

pub type ParamType {
  StringParam
  IntParam
  UUIDParam
}
```

### 2. Generated Code Structure

**For Backend (Gleam)**:
- `backend/src/generated/types.gleam` - Type definitions with JSON encoders
- `backend/src/generated/decoders.gleam` - Dynamic decoders for request bodies
- `backend/src/generated/params.gleam` - Route parameter parsers
- `backend/src/generated/props.gleam` - Prop factory functions
- `backend/src/generated/pages.gleam` - Page component constants (no magic strings!)

**For Frontend (TypeScript)**:
- `frontend/src/generated/types.ts` - TypeScript type definitions
- `frontend/src/generated/schemas.ts` - Zod schemas
- `frontend/src/generated/routes.ts` - Typed route helpers
- `frontend/src/generated/forms.ts` - Typed form hooks with validation

### 3. Example Spec for Slide Page

```gleam
import inertia_wisp_codegen/spec.{
  type Spec, Spec, RecordTypeDef, Field, PageDef, RouteDef, PropDef,
  StringType, IntType, BoolType, ListType, RecordType,
  DefaultProp, GET, IntParam,
}

pub fn presentation_spec() -> Spec {
  Spec(
    types: [
      // ImageData type
      RecordTypeDef(
        name: "ImageData",
        fields: [
          Field(name: "url", field_type: StringType, optional: False),
          Field(name: "alt", field_type: StringType, optional: False),
          Field(name: "width", field_type: IntType, optional: False),
        ],
        validations: [],
      ),
      
      // Slide type
      RecordTypeDef(
        name: "Slide",
        fields: [
          Field(name: "number", field_type: IntType, optional: False),
          Field(name: "title", field_type: StringType, optional: False),
          Field(name: "content", field_type: ListType(RecordType("ContentBlock")), optional: False),
          Field(name: "notes", field_type: StringType, optional: False),
          Field(name: "max_steps", field_type: IntType, optional: False),
        ],
        validations: [],
      ),
      
      // SlideNavigation type
      RecordTypeDef(
        name: "SlideNavigation",
        fields: [
          Field(name: "current", field_type: IntType, optional: False),
          Field(name: "total", field_type: IntType, optional: False),
          Field(name: "has_previous", field_type: BoolType, optional: False),
          Field(name: "has_next", field_type: BoolType, optional: False),
          Field(name: "previous_url", field_type: StringType, optional: False),
          Field(name: "next_url", field_type: StringType, optional: False),
        ],
        validations: [],
      ),
    ],
    
    pages: [
      PageDef(
        name: "Slide",
        component_path: "Pages/Slide",
        props: [
          PropDef(name: "slide", prop_type: "Slide", kind: DefaultProp),
          PropDef(name: "navigation", prop_type: "SlideNavigation", kind: DefaultProp),
          PropDef(name: "presentation_title", prop_type: "String", kind: DefaultProp),
        ],
      ),
    ],
    
    routes: [
      RouteDef(
        name: "slides.show",
        path: "/slides/:number",
        method: GET,
        params: [ParamDef(name: "number", param_type: IntParam)],
        query_params: [],
        body: None,
        page: "Slide",
      ),
    ],
  )
}
```

### 4. Generated Backend Code Examples

**`backend/src/generated/types.gleam`**:
```gleam
// Auto-generated from spec - DO NOT EDIT

import gleam/json

pub type Slide {
  Slide(
    number: Int,
    title: String,
    content: List(ContentBlock),
    notes: String,
    max_steps: Int,
  )
}

pub fn slide_to_json(slide: Slide) -> json.Json {
  let Slide(number:, title:, content:, notes:, max_steps:) = slide
  json.object([
    #("number", json.int(number)),
    #("title", json.string(title)),
    #("content", json.array(content, content_block_to_json)),
    #("notes", json.string(notes)),
    #("max_steps", json.int(max_steps)),
  ])
}
```

**`backend/src/generated/pages.gleam`**:
```gleam
// Auto-generated from spec - DO NOT EDIT
// Page component constants to eliminate magic strings

pub const slide = "Pages/Slide"
pub const contact_form = "Pages/ContactForm"
pub const users_table = "Pages/UsersTable"
```

**`backend/src/generated/props.gleam`**:
```gleam
// Auto-generated from spec - DO NOT EDIT

import inertia_wisp/prop.{type Prop, DefaultProp, LazyProp}
import generated/types

// Slide page prop constructors
pub fn slide_prop(slide: types.Slide) -> Prop(types.Slide) {
  DefaultProp("slide", slide)
}

pub fn navigation_prop(nav: types.SlideNavigation) -> Prop(types.SlideNavigation) {
  DefaultProp("navigation", nav)
}

pub fn presentation_title_prop(title: String) -> Prop(String) {
  DefaultProp("presentation_title", title)
}
```

**Handler usage becomes**:
```gleam
import generated/pages
import generated/props
import generated/types

pub fn view_slide(req: Request, number: Int) -> Response {
  let slide = get_slide(number)
  let nav = navigation(number, total_slides)
  
  let props = [
    props.slide_prop(slide),
    props.navigation_prop(nav),
    props.presentation_title_prop("Inertia Wisp Presentation"),
  ]
  
  req
  |> inertia.response_builder(pages.slide)  // No magic string!
  |> inertia.props(props, types.slide_page_props_to_json)  // Generated encoder
  |> inertia.response(200)
}
```

### 5. Generated Frontend Code Examples

**`frontend/src/generated/schemas.ts`**:
```typescript
// Auto-generated from spec - DO NOT EDIT

import { z } from "zod";

export const SlideSchema = z.object({
  number: z.number(),
  title: z.string(),
  content: z.array(ContentBlockSchema),
  notes: z.string(),
  max_steps: z.number(),
}).strict();

export type Slide = z.infer<typeof SlideSchema>;

export const SlideNavigationSchema = z.object({
  current: z.number(),
  total: z.number(),
  has_previous: z.boolean(),
  has_next: z.boolean(),
  previous_url: z.string(),
  next_url: z.string(),
}).strict();

export type SlideNavigation = z.infer<typeof SlideNavigationSchema>;

export const SlidePagePropsSchema = z.object({
  slide: SlideSchema,
  navigation: SlideNavigationSchema,
  presentation_title: z.string(),
}).strict();

export type SlidePageProps = z.infer<typeof SlidePagePropsSchema>;
```

**`frontend/src/generated/routes.ts`**:
```typescript
// Auto-generated from spec - DO NOT EDIT

import { router } from "@inertiajs/react";

export const routes = {
  slides: {
    show: (number: number) => `/slides/${number}`,
  },
  users: {
    index: () => `/users`,
    show: (id: string) => `/users/${id}`,
  },
} as const;

// Typed reload helper
export function reloadSlide(
  number: number,
  options?: {
    only?: Array<"slide" | "navigation" | "presentation_title">;
    preserveScroll?: boolean;
  }
) {
  return router.reload({
    ...options,
    data: { number },
  });
}
```

### 6. Code Generator Implementation

**Location**: `inertia-wisp/src/inertia_wisp_codegen.gleam`

Main entry point:
```gleam
import gleam/io
import inertia_wisp_codegen/spec.{type Spec}
import inertia_wisp_codegen/generators/gleam_types
import inertia_wisp_codegen/generators/typescript_types
import inertia_wisp_codegen/generators/zod_schemas
// ... other generators

pub fn main() {
  // Load spec from application
  let spec = load_spec()
  
  // Generate backend code
  gleam_types.generate(spec)
  |> write_file("backend/src/generated/types.gleam")
  
  // Generate frontend code
  typescript_types.generate(spec)
  |> write_file("frontend/src/generated/types.ts")
  
  zod_schemas.generate(spec)
  |> write_file("frontend/src/generated/schemas.ts")
  
  io.println("✓ Code generation complete")
}

pub fn check_mode() {
  // --check flag: verify generated files match spec
  // Exit with error if any file is out of date
}
```

### 7. Generator Modules Structure

Each generator is responsible for one output file:

- `inertia_wisp_codegen/generators/gleam_types.gleam`
- `inertia_wisp_codegen/generators/gleam_decoders.gleam`
- `inertia_wisp_codegen/generators/gleam_props.gleam`
- `inertia_wisp_codegen/generators/gleam_pages.gleam`
- `inertia_wisp_codegen/generators/typescript_types.gleam`
- `inertia_wisp_codegen/generators/zod_schemas.gleam`
- `inertia_wisp_codegen/generators/route_helpers.gleam`

Each generator:
1. Takes the `Spec` as input
2. Outputs a string containing the generated code
3. Includes header comment: `// Auto-generated from spec - DO NOT EDIT`

### 8. Handling Complex Types (Discriminated Unions)

For recursive discriminated unions like `ContentBlock`, we use `VariantTypeDef`:

**Generated Gleam**:
```gleam
pub type ContentBlock {
  Heading(text: String)
  Subheading(text: String)
  Columns(left: List(ContentBlock), right: List(ContentBlock))
  // ... other variants
}

pub fn content_block_to_json(block: ContentBlock) -> json.Json {
  case block {
    Heading(text:) -> json.object([
      #("type", json.string("heading")),
      #("text", json.string(text)),
    ])
    // ... other cases
  }
}
```

**Generated TypeScript/Zod**:
```typescript
export const ContentBlockSchema: z.ZodType<ContentBlockType> = z.lazy(() =>
  z.discriminatedUnion("type", [
    z.object({ type: z.literal("heading"), text: z.string() }),
    z.object({ 
      type: z.literal("columns"),
      left: z.array(ContentBlockSchema),
      right: z.array(ContentBlockSchema),
    }),
    // ... other variants
  ]),
);
```

## Implementation Tasks

### Phase 1: Core Infrastructure (Foundation)
1. Create `inertia_wisp_codegen` module structure
2. Define spec data structures (`spec.gleam`)
3. Implement basic CLI (codegen only, no check flag yet)
4. Create file I/O utilities for reading/writing generated code

### Phase 2: Simple Type Generation
5. Implement Gleam type generator for simple record types (no variants)
6. Implement TypeScript type generator for simple objects
7. Implement Zod schema generator for simple objects
8. Create test spec with one simple type (e.g., `User`)
9. Test round-trip: spec → generate → compile

### Phase 3: Page and Prop Generation
10. Implement Gleam pages constant generator
11. Implement Gleam prop factory generator
12. Test with `User` page having simple props

### Phase 4: Discriminated Union Support
13. Extend spec to support variant types
14. Implement Gleam variant type generator
15. Implement TypeScript/Zod discriminated union generator
16. Test with `ContentBlock` recursive type

### Phase 5: Route and Param Support
17. Implement route definition parsing
18. Generate TypeScript route helper functions
19. Generate Gleam param parsers
20. Test with slide route

### Phase 6: Form and Validation Support
21. Add validation to spec
22. Generate Zod validations
23. Generate typed `useForm` wrappers
24. Test with `ContactForm`
25. Implement `--check` flag for CI validation

### Phase 7: Integration and Migration
26. Generate complete spec for existing presentation app
27. Run codegen and verify output
28. Update one handler to use generated code
29. Update one component to use generated code
30. Verify tests still pass
31. Document usage in README

### Phase 8: Developer Experience
32. Add YAML parsing for spec definition
33. Convert existing Gleam spec to YAML format
34. Add Makefile target: `make codegen`
35. Add Makefile target: `make codegen-check`
36. Create migration guide from manual types to spec
37. Add error messages for common spec mistakes

## Success Criteria

- [ ] All existing `shared/` types can be expressed in spec
- [ ] Generated Gleam code compiles without errors
- [ ] Generated TypeScript code compiles without errors
- [ ] All Zod schemas validate correctly
- [ ] No magic strings in handlers (page names are constants)
- [ ] Type errors surface at compile time when spec changes
- [ ] `--check` mode catches out-of-date generated code
- [ ] Documentation shows clear migration path
- [ ] System is completely optional for application developers

## Design Decisions

### Props Ownership
Props exist to serve the Page being rendered, while params and post bodies exist to serve the Routes. The spec includes both routes and pages separately. Note that the same Page can be rendered by multiple routes.

### Validation Philosophy
Validation is primarily server-side. Inertia has good support for propagating server-side error messages back to form inputs. Client-side validation is optional for cases where the designer has indicated that immediate feedback is preferred to a form submission error message.

The spec only encodes shared validations that would be exercised both client-side and server-side. In practice this means simple declarative validation like length and regex matching. More complex logic might be better enabled by the application developer defining a gleam package that can be compiled to both JS and Erlang. We limit the scope of these validations to what can be easily supported by Zod.

### Specification Format
Initially defined in Gleam data structures for type safety during development. YAML parsing added in Phase 8 for better ergonomics in production use.

### Integration with inertia_wisp
Codegen is a utility provided to application developers, not a core requirement. The core `inertia_wisp` library doesn't assume this spec system is being used. Codegen lives in the `inertia_wisp` package and can be run with `gleam run -m inertia_wisp_codegen`.

## Open Questions for Human Review

1. **Variant type representation**: Should we make the spec more explicit about discriminated unions, or keep it simpler and handle them as special cases in generators?

2. **Validation complexity**: We agreed on simple validations. Should we support custom validation function names that developers implement separately?

3. **Prop encoding function**: Currently each page has a custom prop encoder. Should we generate a single encoder per page, or one per type and compose them?

4. **Error handling**: What should happen if spec has errors (missing type references, duplicate names)? Fail fast or collect all errors?

5. **Incremental generation**: Should we support generating only backend or only frontend, or always generate both?