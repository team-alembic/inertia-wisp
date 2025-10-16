//// Page schema module for declaring page-level prop structures
////
//// This module provides a way to declare what props a page component expects
//// without needing to define encoding/decoding logic. It's used purely for
//// generating TypeScript/Zod schemas for the frontend.
////
//// Unlike RecordSchema/VariantSchema which are bidirectional (encode & decode),
//// PageSchema is output-only since we never parse props from the frontend.

import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import inertia_wisp/schema.{type FieldType}

/// A schema for a page component's props
pub type PageSchema {
  PageSchema(component: String, props: Dict(String, PropDeclaration))
}

/// Declaration of a single prop on a page
pub type PropDeclaration {
  PropDeclaration(field_type: FieldType, optional: Bool)
}

/// Builder for constructing page schemas
pub type PageSchemaBuilder {
  PageSchemaBuilder(schema: PageSchema)
}

/// Create a new page schema builder
pub fn page_schema(component: String) -> PageSchemaBuilder {
  PageSchemaBuilder(schema: PageSchema(component: component, props: dict.new()))
}

/// Add a required prop to the page schema
pub fn prop(
  builder: PageSchemaBuilder,
  name: String,
  field_type: FieldType,
) -> PageSchemaBuilder {
  let prop_decl = PropDeclaration(field_type: field_type, optional: False)
  let updated_props = dict.insert(builder.schema.props, name, prop_decl)
  let updated_schema = PageSchema(..builder.schema, props: updated_props)
  PageSchemaBuilder(schema: updated_schema)
}

/// Add an optional prop to the page schema (e.g., lazy props, deferred props)
pub fn optional_prop(
  builder: PageSchemaBuilder,
  name: String,
  field_type: FieldType,
) -> PageSchemaBuilder {
  let prop_decl = PropDeclaration(field_type: field_type, optional: True)
  let updated_props = dict.insert(builder.schema.props, name, prop_decl)
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
      let with_optional = case prop_decl.optional {
        True -> zod_type <> ".optional()"
        False -> zod_type
      }
      "  " <> prop_name <> ": " <> with_optional <> ","
    })
    |> string.join("\n")

  let schema_def =
    "export const "
    <> schema_name
    <> " = z.object({\n"
    <> fields_code
    <> "\n"
    <> "}).strict();\n\n"

  let type_def =
    "export type " <> type_name <> " = z.infer<typeof " <> schema_name <> ">;"

  schema_def <> type_def
}

// Helper function to convert FieldType to Zod type string
fn field_type_to_zod(field_type: FieldType) -> String {
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
