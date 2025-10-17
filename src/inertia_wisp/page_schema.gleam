//// Page schema module for declaring page-level prop structures
////
//// This module provides a way to declare what props a page component expects
//// and automatically generate prop encoders. It's used for generating
//// TypeScript/Zod schemas and creating JSON encoders.
////
//// Unlike RecordSchema/VariantSchema which are bidirectional (encode & decode),
//// PageSchema is output-only since we never parse props from the frontend.

import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/string
import inertia_wisp/schema.{type FieldType}

/// A schema for a page component's props
pub type PageSchema {
  PageSchema(
    component: String,
    props: Dict(String, PropDeclaration),
    tagger: fn(dynamic.Dynamic) -> String,
  )
}

/// Declaration of a single prop on a page
pub type PropDeclaration {
  PropDeclaration(
    field_type: FieldType,
    optional: Bool,
    extractor: fn(dynamic.Dynamic) -> dynamic.Dynamic,
  )
}

/// Builder for constructing page schemas
pub type PageSchemaBuilder {
  PageSchemaBuilder(schema: PageSchema)
}

/// Create a new page schema builder
pub fn page_schema(component: String) -> PageSchemaBuilder {
  PageSchemaBuilder(
    schema: PageSchema(component: component, props: dict.new(), tagger: fn(_) {
      ""
    }),
  )
}

/// Add a required prop to the page schema
pub fn prop(
  builder: PageSchemaBuilder,
  name: String,
  field_type: FieldType,
  extractor: fn(p) -> a,
) -> PageSchemaBuilder {
  let prop_decl =
    PropDeclaration(
      field_type: field_type,
      optional: False,
      extractor: fn(value) {
        schema.unsafe_cast(extractor(schema.unsafe_cast(value)))
      },
    )
  let updated_props = dict.insert(builder.schema.props, name, prop_decl)
  let updated_schema = PageSchema(..builder.schema, props: updated_props)
  PageSchemaBuilder(schema: updated_schema)
}

/// Add an optional prop to the page schema (e.g., lazy props, deferred props)
pub fn optional_prop(
  builder: PageSchemaBuilder,
  name: String,
  field_type: FieldType,
  extractor: fn(p) -> a,
) -> PageSchemaBuilder {
  let prop_decl =
    PropDeclaration(
      field_type: field_type,
      optional: True,
      extractor: fn(value) {
        schema.unsafe_cast(extractor(schema.unsafe_cast(value)))
      },
    )
  let updated_props = dict.insert(builder.schema.props, name, prop_decl)
  let updated_schema = PageSchema(..builder.schema, props: updated_props)
  PageSchemaBuilder(schema: updated_schema)
}

/// Set the tagger function for the page schema
/// The tagger identifies which prop a given value represents
pub fn tagger(
  builder: PageSchemaBuilder,
  tagger_fn: fn(p) -> String,
) -> PageSchemaBuilder {
  let updated_schema =
    PageSchema(..builder.schema, tagger: fn(value) {
      tagger_fn(schema.unsafe_cast(value))
    })
  PageSchemaBuilder(schema: updated_schema)
}

/// Finalize the page schema
pub fn build(builder: PageSchemaBuilder) -> PageSchema {
  builder.schema
}

/// Create a JSON encoder function from a PageSchema
/// This returns a function that can be passed to inertia.props()
pub fn create_encoder(page_schema: PageSchema) -> fn(p) -> json.Json {
  fn(prop: p) -> json.Json {
    let dynamic_prop = schema.unsafe_cast(prop)
    let prop_name = page_schema.tagger(dynamic_prop)

    case dict.get(page_schema.props, prop_name) {
      Ok(prop_decl) -> {
        let value = prop_decl.extractor(dynamic_prop)
        encode_prop(prop_decl.field_type, value)
      }
      Error(_) -> {
        // Prop not declared in schema - this shouldn't happen
        json.null()
      }
    }
  }
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

/// Encode a prop value to JSON based on its FieldType
fn encode_prop(field_type: FieldType, value: dynamic.Dynamic) -> json.Json {
  case field_type {
    schema.StringType -> {
      let assert Ok(str_value) = decode.run(value, decode.string)
      json.string(str_value)
    }
    schema.IntType -> {
      let assert Ok(int_value) = decode.run(value, decode.int)
      json.int(int_value)
    }
    schema.FloatType -> {
      let assert Ok(float_value) = decode.run(value, decode.float)
      json.float(float_value)
    }
    schema.BoolType -> {
      let assert Ok(bool_value) = decode.run(value, decode.bool)
      json.bool(bool_value)
    }
    schema.ListType(inner) -> {
      let assert Ok(list_value) = decode.run(value, decode.list(decode.dynamic))
      json.array(list_value, fn(item) { encode_prop(inner, item) })
    }
    schema.RecordType(get_schema) -> {
      let record_schema = get_schema()
      schema.to_json(record_schema, schema.unsafe_cast(value))
    }
    schema.VariantType(get_schema) -> {
      let variant_schema = get_schema()
      schema.variant_to_json(variant_schema, schema.unsafe_cast(value))
    }
  }
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
