//// Page schema module for declaring page-level prop structures
////
//// This module provides a way to declare what props a page component expects
//// and automatically generate prop encoders. It's used for generating
//// TypeScript/Zod schemas and creating JSON encoders.
////
//// Unlike RecordSchema/VariantSchema which are bidirectional (encode & decode),
//// PageSchema is output-only since we never parse props from the frontend.

import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import inertia_wisp/schema.{type Erased, type FieldType, unsafe_cast}

/// A schema for a page component's props
///
/// Note: Props are stored as PropDeclaration(Erased) to allow heterogeneous prop types.
/// Each PropDeclaration(t) is erased to PropDeclaration(Erased) when stored.
pub type PageSchema {
  PageSchema(component: String, props: Dict(String, PropDeclaration(Erased)))
}

/// Behavior of a prop in Inertia.js
pub type PropBehavior {
  DefaultProp
  LazyProp
  OptionalProp
  AlwaysProp
  DeferProp
  MergeProp
}

/// Declaration of a single prop on a page
///
/// The type parameter `t` represents the type of this prop field.
pub type PropDeclaration(t) {
  PropDeclaration(field_type: FieldType(t), behavior: PropBehavior)
}

/// Builder for constructing page schemas
pub type PageSchemaBuilder {
  PageSchemaBuilder(schema: PageSchema)
}

/// Erase the type parameter from PropDeclaration(t) to PropDeclaration(Erased)
fn erase_prop_decl(prop: PropDeclaration(t)) -> PropDeclaration(Erased) {
  unsafe_cast(prop)
}

/// Create a new page schema builder
pub fn page_schema(component: String) -> PageSchemaBuilder {
  PageSchemaBuilder(schema: PageSchema(component: component, props: dict.new()))
}

/// Add a default prop to the page schema
pub fn prop(
  builder: PageSchemaBuilder,
  name: String,
  field_type: FieldType(t),
) -> PageSchemaBuilder {
  prop_with_behavior(builder, name, field_type, DefaultProp)
}

/// Add a deferred prop to the page schema (loaded lazily, optional in TypeScript)
pub fn deferred_prop(
  builder: PageSchemaBuilder,
  name: String,
  field_type: FieldType(t),
) -> PageSchemaBuilder {
  prop_with_behavior(builder, name, field_type, DeferProp)
}

/// Add an optional prop to the page schema
pub fn optional_prop(
  builder: PageSchemaBuilder,
  name: String,
  field_type: FieldType(t),
) -> PageSchemaBuilder {
  prop_with_behavior(builder, name, field_type, OptionalProp)
}

/// Add a prop with a specific behavior
fn prop_with_behavior(
  builder: PageSchemaBuilder,
  name: String,
  field_type: FieldType(t),
  behavior: PropBehavior,
) -> PageSchemaBuilder {
  let prop_decl = PropDeclaration(field_type: field_type, behavior: behavior)
  let updated_props =
    dict.insert(builder.schema.props, name, erase_prop_decl(prop_decl))
  let updated_schema = PageSchema(..builder.schema, props: updated_props)
  PageSchemaBuilder(schema: updated_schema)
}

/// Finalize the page schema
pub fn build(builder: PageSchemaBuilder) -> PageSchema {
  builder.schema
}

/// Generate TypeScript/Zod schema from page schema
pub fn to_zod_schema(page_schema: PageSchema) -> String {
  let schema_name = page_schema.component <> "PagePropsSchema"
  let type_name = page_schema.component <> "PageProps"

  let fields_code =
    page_schema.props
    |> dict.to_list()
    |> list.map(fn(entry) {
      let #(prop_name, prop_decl) = entry
      let zod_type = field_type_to_zod(prop_decl.field_type)
      let with_optional = case prop_decl.behavior {
        OptionalProp | DeferProp -> zod_type <> ".optional()"
        _ -> zod_type
      }
      "  " <> prop_name <> ": " <> with_optional <> ","
    })
    |> string.join("\n")

  // Add errors as a standard optional prop on all pages (Inertia.js convention)
  let fields_with_errors =
    fields_code <> "\n  errors: z.record(z.string(), z.string()).optional(),"

  let schema_def =
    "export const "
    <> schema_name
    <> " = z.object({\n"
    <> fields_with_errors
    <> "\n"
    <> "}).strict();\n\n"

  let type_def =
    "export type " <> type_name <> " = z.infer<typeof " <> schema_name <> ">;"

  schema_def <> type_def
}

// Helper function to convert FieldType to Zod type string
fn field_type_to_zod(field_type: FieldType(t)) -> String {
  case field_type {
    schema.StringType -> "z.string()"
    schema.IntType -> "z.number()"
    schema.FloatType -> "z.number()"
    schema.BoolType -> "z.boolean()"
    schema.ListType(inner) -> "z.array(" <> field_type_to_zod(inner) <> ")"
    schema.RecordType(get_schema) -> {
      let schema = get_schema()
      schema.name <> "Schema"
    }
    schema.VariantType(get_schema) -> {
      let schema = get_schema()
      schema.name <> "Schema"
    }
  }
}
