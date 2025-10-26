import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result
import gleam/string

@external(erlang, "gleam_erlang_ffi", "identity")
pub fn unsafe_cast(a: a) -> b

@external(erlang, "erlang", "element")
fn element(index: Int, record: a) -> dynamic.Dynamic

@external(erlang, "erlang", "setelement")
fn setelement(index: Int, record: a, value: dynamic.Dynamic) -> a

/// A phantom type for type erasure
///
/// This type has no runtime representation and is used to erase type parameters
/// while maintaining structural type information (e.g., FieldType(Erased) is still
/// a FieldType, but the specific type parameter is erased).
pub type Erased

/// Erase the type parameter from a Field(t) to Field(Erased)
pub fn erase_field(field: Field(t)) -> Field(Erased) {
  unsafe_cast(field)
}

/// Erase the type parameter from a FieldType(t) to FieldType(Erased)
pub fn erase_field_type(field_type: FieldType(t)) -> FieldType(Erased) {
  unsafe_cast(field_type)
}

/// Field type information for code generation
///
/// The type parameter `t` represents the type of this field.
/// For nested schemas (RecordType/VariantType), `t` is the type that schema decodes to.
/// This allows us to track nested schema types while maintaining type erasure
/// where needed (in the Field/dict storage).
pub type FieldType(t) {
  StringType
  IntType
  FloatType
  BoolType
  ListType(inner: FieldType(t))
  RecordType(schema: fn() -> RecordSchema(t))
  VariantType(schema: fn() -> VariantSchema(t))
}

/// Validation rules for fields
pub type Validation {
  MinLength(min: Int)
  MaxLength(max: Int)
  Pattern(regex: String, message: String)
  Email
  Required
}

/// A field definition with type information, record index, and validations
///
/// The type parameter `t` represents the type of this field.
pub type Field(t) {
  Field(field_type: FieldType(t), index: Int, validations: List(Validation))
}

/// A schema for a record type
///
/// The phantom type parameter `t` represents the type this schema decodes to.
/// This provides type safety and prevents accidentally using the wrong schema
/// for decoding.
///
/// Note: Fields are stored as Field(Erased) to allow heterogeneous field types
/// within a single record. Each Field(u) is erased to Field(Erased) when stored.
pub type RecordSchema(t) {
  RecordSchema(
    name: String,
    fields: dict.Dict(String, Field(Erased)),
    default: t,
  )
}

/// A schema for a variant type (discriminated union)
///
/// The phantom type parameter `t` represents the type this schema decodes to.
pub type VariantSchema(t) {
  VariantSchema(
    name: String,
    cases: dict.Dict(String, RecordSchema(t)),
    tagger: fn(dynamic.Dynamic) -> String,
  )
}

/// Builder for constructing record schemas
pub type RecordSchemaBuilder(t) {
  RecordSchemaBuilder(schema: RecordSchema(t), next_index: Int)
}

/// Builder for constructing variant schemas
pub type VariantSchemaBuilder(t) {
  VariantSchemaBuilder(schema: VariantSchema(t))
}

/// Create a new schema builder for a record type
/// The default value is used as a starting point for decoding
pub fn record_schema(name: String, default: t) -> RecordSchemaBuilder(t) {
  RecordSchemaBuilder(
    schema: RecordSchema(name: name, fields: dict.new(), default: default),
    next_index: 2,
  )
}

/// Create a new schema builder for a variant type
/// The tagger function matches on the variant value and returns the tag string
pub fn variant_schema(
  name: String,
  tagger: fn(t) -> String,
) -> VariantSchemaBuilder(t) {
  VariantSchemaBuilder(
    schema: VariantSchema(
      name: name,
      cases: dict.new(),
      tagger: fn(v: dynamic.Dynamic) { tagger(unsafe_cast(v)) },
    ),
  )
}

/// Extract the RecordSchema from a builder
pub fn schema(sb: RecordSchemaBuilder(t)) -> RecordSchema(t) {
  sb.schema
}

/// Extract the VariantSchema from a builder
pub fn variant_schema_done(sb: VariantSchemaBuilder(t)) -> VariantSchema(t) {
  sb.schema
}

/// Add a field to a record schema
pub fn field(
  sb: RecordSchemaBuilder(t),
  name: String,
  field_type: FieldType(u),
) -> RecordSchemaBuilder(t) {
  let field =
    Field(field_type: field_type, index: sb.next_index, validations: [])

  let updated_schema =
    RecordSchema(
      ..sb.schema,
      fields: dict.insert(sb.schema.fields, name, erase_field(field)),
    )

  RecordSchemaBuilder(schema: updated_schema, next_index: field.index + 1)
}

/// Add a string field to a record schema
pub fn string_field(
  sb: RecordSchemaBuilder(t),
  name: String,
) -> RecordSchemaBuilder(t) {
  field(sb, name, StringType)
}

/// Add an integer field to a record schema
pub fn int_field(
  sb: RecordSchemaBuilder(t),
  name: String,
) -> RecordSchemaBuilder(t) {
  field(sb, name, IntType)
}

/// Add a boolean field to a record schema
pub fn bool_field(
  sb: RecordSchemaBuilder(t),
  name: String,
) -> RecordSchemaBuilder(t) {
  field(sb, name, BoolType)
}

/// Add a float field to a record schema
pub fn float_field(
  sb: RecordSchemaBuilder(t),
  name: String,
) -> RecordSchemaBuilder(t) {
  field(sb, name, FloatType)
}

/// Add a list field to a record schema
pub fn list_field(
  sb: RecordSchemaBuilder(t),
  name: String,
  inner: FieldType(u),
) -> RecordSchemaBuilder(t) {
  field(sb, name, ListType(inner))
}

/// Add a nested record field to a record schema
pub fn record_field(
  sb: RecordSchemaBuilder(t),
  name: String,
  schema: fn() -> RecordSchema(u),
) -> RecordSchemaBuilder(t) {
  field(sb, name, RecordType(schema))
}

/// Add a variant field to a record schema
pub fn variant_field(
  sb: RecordSchemaBuilder(t),
  name: String,
  schema: fn() -> VariantSchema(u),
) -> RecordSchemaBuilder(t) {
  field(sb, name, VariantType(schema))
}

/// Add a case to a variant schema
pub fn variant_case(
  sb: VariantSchemaBuilder(t),
  tag: String,
  record: RecordSchema(t),
) -> VariantSchemaBuilder(t) {
  let updated_cases = dict.insert(sb.schema.cases, tag, record)
  let updated_schema = VariantSchema(..sb.schema, cases: updated_cases)
  VariantSchemaBuilder(schema: updated_schema)
}

/// Add validations to the most recently added field (record schemas only)
pub fn validate(
  sb: RecordSchemaBuilder(t),
  _validations: List(Validation),
) -> RecordSchemaBuilder(t) {
  // TODO: Track last field name and update its validations
  sb
}

/// Encode a value to JSON using a record schema
pub fn to_json(schema: RecordSchema(t), value: t) -> json.Json {
  encode_record(schema, value)
}

/// Encode a value to JSON using a variant schema
pub fn variant_to_json(schema: VariantSchema(t), value: t) -> json.Json {
  encode_variant(schema, value)
}

fn encode_record(schema: RecordSchema(t), value: t) -> json.Json {
  let dynamic_value = unsafe_cast(value)

  schema.fields
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(name, field) = entry
    let field_value = element(field.index, dynamic_value)
    #(name, encode_field(field.field_type, field_value))
  })
  |> json.object()
}

fn encode_variant(schema: VariantSchema(t), value: t) -> json.Json {
  let dynamic_value = unsafe_cast(value)

  // Use tagger to get the tag for this value
  let tag = schema.tagger(dynamic_value)

  // Find the record schema for this tag
  case dict.get(schema.cases, tag) {
    Ok(record_schema) -> {
      // Manually encode all fields from the record schema
      let field_entries =
        record_schema.fields
        |> dict.to_list()
        |> list.map(fn(entry) {
          let #(name, field) = entry
          let field_value = element(field.index, dynamic_value)
          #(name, encode_field(field.field_type, field_value))
        })

      // Add the "type" discriminator field
      let all_entries = [#("type", json.string(tag)), ..field_entries]
      json.object(all_entries)
    }
    Error(_) -> {
      // Unknown tag - return error object
      json.object([
        #("type", json.string("unknown")),
        #("error", json.string("Unknown variant tag: " <> tag)),
      ])
    }
  }
}

fn encode_field(field_type: FieldType(t), value: dynamic.Dynamic) -> json.Json {
  case field_type {
    StringType -> {
      let assert Ok(str_value) = decode.run(value, decode.string)
      json.string(str_value)
    }
    IntType -> {
      let assert Ok(int_value) = decode.run(value, decode.int)
      json.int(int_value)
    }
    FloatType -> {
      let assert Ok(float_value) = decode.run(value, decode.float)
      json.float(float_value)
    }
    BoolType -> {
      let assert Ok(bool_value) = decode.run(value, decode.bool)
      json.bool(bool_value)
    }
    ListType(inner) -> {
      // Recursively encode list elements
      // This handles ListType(RecordType(...)) correctly via recursion
      let assert Ok(list_value) = decode.run(value, decode.list(decode.dynamic))
      json.array(list_value, fn(item) { encode_field(inner, item) })
    }
    RecordType(get_schema) -> {
      // Recursively encode nested records
      let nested_schema = get_schema()
      encode_record(nested_schema, unsafe_cast(value))
    }
    VariantType(get_schema) -> {
      // Recursively encode nested variants
      let nested_schema = get_schema()
      encode_variant(nested_schema, unsafe_cast(value))
    }
  }
}

/// Decode a dynamic value using a record schema
///
/// The phantom type parameter ensures type safety - you can only decode
/// into the type that the schema was created for.
pub fn decode(
  schema: RecordSchema(t),
  value: dynamic.Dynamic,
) -> Result(t, String) {
  decode_record(schema, value)
}

/// Decode a dynamic value using a variant schema
///
/// The phantom type parameter ensures type safety - you can only decode
/// into the type that the schema was created for.
pub fn variant_decode(
  schema: VariantSchema(t),
  value: dynamic.Dynamic,
) -> Result(t, String) {
  decode_variant(schema, value)
}

fn decode_record(
  schema: RecordSchema(t),
  value: dynamic.Dynamic,
) -> Result(t, String) {
  // Start with default value
  let result = schema.default

  // For each field, decode and apply setter
  schema.fields
  |> dict.to_list()
  |> list.try_fold(result, fn(acc, entry) {
    let #(field_name, field) = entry

    // Decode the field value from the dynamic input
    use field_value <- result.try(decode_field(
      field.field_type,
      field_name,
      value,
    ))

    // Use setter to update the record
    Ok(setelement(field.index, unsafe_cast(acc), field_value))
  })
}

fn decode_variant(
  schema: VariantSchema(t),
  value: dynamic.Dynamic,
) -> Result(t, String) {
  // Extract the "type" field to determine which variant
  let type_decoder = {
    use type_value <- decode.field("type", decode.string)
    decode.success(type_value)
  }

  use type_tag <- result.try(
    decode.run(value, type_decoder)
    |> result.map_error(fn(_) { "Failed to decode 'type' field from variant" }),
  )

  // Find the record schema for this tag
  case dict.get(schema.cases, type_tag) {
    Ok(record_schema) -> {
      // Use the record decoder to decode the variant
      decode_record(record_schema, value)
    }
    Error(_) ->
      Error("Unknown variant type: " <> type_tag <> " for " <> schema.name)
  }
}

fn decode_field(
  field_type: FieldType(t),
  field_name: String,
  value: dynamic.Dynamic,
) -> Result(dynamic.Dynamic, String) {
  // Special case for RecordType and ListType(RecordType) - decode recursively
  case field_type {
    RecordType(get_schema) -> {
      // First extract the field as dynamic
      let field_decoder = {
        use field_value <- decode.field(field_name, decode.dynamic)
        decode.success(field_value)
      }

      use field_value <- result.try(
        decode.run(value, field_decoder)
        |> result.map_error(fn(errors) {
          "Failed to decode field: "
          <> field_name
          <> " - "
          <> string_from_decode_errors(errors)
        }),
      )

      // Now recursively decode using the nested schema
      let nested_schema = get_schema()
      decode_record(nested_schema, field_value)
      |> result.map(unsafe_cast)
    }
    ListType(RecordType(get_schema)) -> {
      // Special case: list of records
      let field_decoder = {
        use field_value <- decode.field(field_name, decode.list(decode.dynamic))
        decode.success(field_value)
      }

      use list_items <- result.try(
        decode.run(value, field_decoder)
        |> result.map_error(fn(errors) {
          "Failed to decode field: "
          <> field_name
          <> " - "
          <> string_from_decode_errors(errors)
        }),
      )

      // Decode each item using the schema
      let nested_schema = get_schema()
      list_items
      |> list.try_map(fn(item) {
        decode_record(nested_schema, item)
        |> result.map_error(fn(err) { "List item decode error: " <> err })
      })
      |> result.map(unsafe_cast)
    }
    _ -> {
      // Standard decoding for other types
      let decoder = field_type_decoder(field_type)

      let field_decoder = {
        use field_value <- decode.field(field_name, decoder)
        decode.success(field_value)
      }

      decode.run(value, field_decoder)
      |> result.map(unsafe_cast)
      |> result.map_error(fn(errors) {
        "Failed to decode field: "
        <> field_name
        <> " - "
        <> string_from_decode_errors(errors)
      })
    }
  }
}

fn field_type_decoder(
  field_type: FieldType(t),
) -> decode.Decoder(dynamic.Dynamic) {
  case field_type {
    StringType -> decode.string |> decode.map(unsafe_cast)
    IntType -> decode.int |> decode.map(unsafe_cast)
    FloatType -> decode.float |> decode.map(unsafe_cast)
    BoolType -> decode.bool |> decode.map(unsafe_cast)
    ListType(inner) -> {
      // Recursively decode inner elements based on inner type
      let inner_decoder = field_type_decoder(inner)
      decode.list(inner_decoder) |> decode.map(unsafe_cast)
    }
    RecordType(_) -> {
      // RecordType is handled specially in decode_field
      // This case should not be reached for record types at top level
      decode.dynamic
    }
    VariantType(_) -> {
      // VariantType is handled specially in decode_field
      // This case should not be reached for variant types at top level
      decode.dynamic
    }
  }
}

fn string_from_decode_errors(errors: List(decode.DecodeError)) -> String {
  case errors {
    [] -> "unknown error"
    _ -> string.inspect(errors)
  }
}

/// Generate a Zod schema string for TypeScript from a record schema
pub fn to_zod_schema(schema: RecordSchema(t)) -> String {
  record_to_zod(schema)
}

/// Generate a Zod schema string for TypeScript from a variant schema
pub fn variant_to_zod_schema(schema: VariantSchema(t)) -> String {
  variant_to_zod(schema)
}

fn record_to_zod(schema: RecordSchema(t)) -> String {
  let schema_name = schema.name <> "Schema"
  let type_name = schema.name

  let fields_code =
    schema.fields
    |> dict.to_list()
    |> list.map(fn(entry) {
      let #(field_name, field) = entry
      let zod_type = field_type_to_zod(field.field_type)
      "  " <> field_name <> ": " <> zod_type <> ","
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

fn variant_to_zod(schema: VariantSchema(t)) -> String {
  let schema_name = schema.name <> "Schema"
  let type_name = schema.name

  // Check if this is a recursive type
  let is_recursive =
    schema.cases
    |> dict.values()
    |> list.any(fn(record_schema) {
      record_schema.fields
      |> dict.values()
      |> list.any(fn(field) {
        case field.field_type {
          VariantType(_) -> True
          ListType(VariantType(_)) -> True
          RecordType(_) -> False
          ListType(RecordType(_)) -> False
          ListType(ListType(RecordType(_))) -> False
          _ -> False
        }
      })
    })

  case is_recursive {
    True -> variant_to_zod_recursive(schema, schema_name, type_name)
    False -> variant_to_zod_simple(schema, schema_name, type_name)
  }
}

fn variant_to_zod_simple(
  schema: VariantSchema(t),
  schema_name: String,
  type_name: String,
) -> String {
  // Generate each variant case as a z.object
  let cases_code =
    schema.cases
    |> dict.to_list()
    |> list.map(fn(case_entry) {
      let #(tag, record_schema) = case_entry
      let fields =
        record_schema.fields
        |> dict.to_list()
        |> list.map(fn(field_entry) {
          let #(field_name, field) = field_entry
          let zod_type = field_type_to_zod(field.field_type)
          "    " <> field_name <> ": " <> zod_type <> ","
        })
        |> string.join("\n")

      let type_literal = "    type: z.literal(\"" <> tag <> "\"),"

      case dict.size(record_schema.fields) {
        0 -> "  z.object({\n" <> type_literal <> "\n  })"
        _ -> "  z.object({\n" <> type_literal <> "\n" <> fields <> "\n  })"
      }
    })
    |> string.join(",\n")

  let schema_def =
    "export const "
    <> schema_name
    <> " = z.discriminatedUnion(\"type\", [\n"
    <> cases_code
    <> ",\n"
    <> "]);\n\n"

  let type_def =
    "export type " <> type_name <> " = z.infer<typeof " <> schema_name <> ">;"

  schema_def <> type_def
}

fn variant_to_zod_recursive(
  schema: VariantSchema(t),
  schema_name: String,
  type_name: String,
) -> String {
  // Generate individual case schemas (only for non-recursive cases)
  let case_schemas =
    schema.cases
    |> dict.to_list()
    |> list.map(fn(case_entry) {
      let #(tag, record_schema) = case_entry
      let case_schema_name = record_schema.name <> "Schema"

      // Check if this case has recursive references
      let has_recursive =
        record_schema.fields
        |> dict.values()
        |> list.any(fn(field) {
          case field.field_type {
            VariantType(_) -> True
            ListType(VariantType(_)) -> True
            _ -> False
          }
        })

      case has_recursive {
        True -> ""
        // Don't generate const for recursive cases
        False -> {
          let fields =
            record_schema.fields
            |> dict.to_list()
            |> list.map(fn(field_entry) {
              let #(field_name, field) = field_entry
              let zod_type = field_type_to_zod(field.field_type)
              "  " <> field_name <> ": " <> zod_type <> ","
            })
            |> string.join("\n")

          let type_literal = "  type: z.literal(\"" <> tag <> "\"),"

          let type_name = record_schema.name

          case dict.size(record_schema.fields) {
            0 ->
              "export const "
              <> case_schema_name
              <> " = z.object({\n"
              <> type_literal
              <> "\n"
              <> "});\n\n"
              <> "export type "
              <> type_name
              <> " = z.infer<typeof "
              <> case_schema_name
              <> ">;\n"
            _ ->
              "export const "
              <> case_schema_name
              <> " = z.object({\n"
              <> type_literal
              <> "\n"
              <> fields
              <> "\n"
              <> "});\n\n"
              <> "export type "
              <> type_name
              <> " = z.infer<typeof "
              <> case_schema_name
              <> ">;\n"
          }
        }
      }
    })
    |> list.filter(fn(s) { s != "" })
    |> string.join("\n")

  // Generate manual union type
  let union_type_name = type_name <> "Type"
  let union_cases =
    schema.cases
    |> dict.to_list()
    |> list.map(fn(case_entry) {
      let #(tag, record_schema) = case_entry
      let case_schema_name = record_schema.name <> "Schema"
      // Check if this case has recursive references
      let has_recursive =
        record_schema.fields
        |> dict.values()
        |> list.any(fn(field) {
          case field.field_type {
            VariantType(_) -> True
            ListType(VariantType(_)) -> True
            _ -> False
          }
        })

      case has_recursive {
        True -> {
          // Generate inline type for recursive cases
          let fields =
            record_schema.fields
            |> dict.to_list()
            |> list.map(fn(field_entry) {
              let #(field_name, field) = field_entry
              let ts_type = field_type_to_ts_type(field.field_type, type_name)
              "    " <> field_name <> ": " <> ts_type <> ";"
            })
            |> string.join("\n")

          "  | {\n      type: \"" <> tag <> "\";\n" <> fields <> "\n    }"
        }
        False -> "  | z.infer<typeof " <> case_schema_name <> ">"
      }
    })
    |> string.join("\n")

  let union_type_def =
    "type " <> union_type_name <> " =\n" <> union_cases <> ";\n\n"

  // Generate schema references
  let schema_refs =
    schema.cases
    |> dict.to_list()
    |> list.map(fn(case_entry) {
      let #(tag, record_schema) = case_entry
      let case_schema_name = record_schema.name <> "Schema"
      // Check if this case has recursive references
      let has_recursive =
        record_schema.fields
        |> dict.values()
        |> list.any(fn(field) {
          case field.field_type {
            VariantType(_) -> True
            ListType(VariantType(_)) -> True
            _ -> False
          }
        })

      case has_recursive {
        True -> {
          // Generate inline object for recursive cases
          let fields =
            record_schema.fields
            |> dict.to_list()
            |> list.map(fn(field_entry) {
              let #(field_name, field) = field_entry
              let zod_type = field_type_to_zod(field.field_type)
              "    " <> field_name <> ": " <> zod_type <> ","
            })
            |> string.join("\n")

          "  z.object({\n    type: z.literal(\""
          <> tag
          <> "\"),\n"
          <> fields
          <> "\n  })"
        }
        False -> "  " <> case_schema_name
      }
    })
    |> string.join(",\n")

  let schema_def =
    "export const "
    <> schema_name
    <> ": z.ZodType<"
    <> union_type_name
    <> "> = z.lazy(() =>\n"
    <> "  z.discriminatedUnion(\"type\", [\n"
    <> schema_refs
    <> ",\n"
    <> "  ]),\n"
    <> ");\n\n"

  let type_export =
    "export type " <> type_name <> " = " <> union_type_name <> ";"

  case_schemas <> "\n" <> union_type_def <> schema_def <> type_export
}

fn field_type_to_ts_type(
  field_type: FieldType(t),
  variant_name: String,
) -> String {
  case field_type {
    StringType -> "string"
    IntType -> "number"
    FloatType -> "number"
    BoolType -> "boolean"
    ListType(inner) -> field_type_to_ts_type(inner, variant_name) <> "[]"
    RecordType(get_schema) -> {
      let nested_schema = get_schema()
      nested_schema.name
    }
    VariantType(_) -> variant_name <> "Type"
  }
}

fn field_type_to_zod(field_type: FieldType(t)) -> String {
  case field_type {
    StringType -> "z.string()"
    IntType -> "z.number()"
    FloatType -> "z.number()"
    BoolType -> "z.boolean()"
    ListType(inner) -> {
      let inner_zod = field_type_to_zod(inner)
      "z.array(" <> inner_zod <> ")"
    }
    RecordType(get_schema) -> {
      // Get the schema to extract its name
      let nested_schema = get_schema()
      nested_schema.name <> "Schema"
    }
    VariantType(get_schema) -> {
      // Get the schema to extract its name
      let nested_schema = get_schema()
      nested_schema.name <> "Schema"
    }
  }
}
