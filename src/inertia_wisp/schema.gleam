import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import gleam/string

@external(erlang, "gleam_erlang_ffi", "identity")
fn unsafe_cast(a: a) -> b

/// Convert any value to Dynamic
///
/// This is a wrapper around unsafe_cast for converting values to Dynamic.
pub fn to_dynamic(value: t) -> dynamic.Dynamic {
  unsafe_cast(value)
}

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
fn erase_field(field: Field(t)) -> Field(Erased) {
  unsafe_cast(field)
}

/// Field type information for code generation
///
/// The type parameter `t` represents the type of this field.
/// For nested schemas (RecordType/VariantType), `t` is the type that schema decodes to.
/// This allows us to track nested schema types while maintaining type erasure
/// where needed (in the Field/dict storage).
///
/// The OptionalType wrapper indicates fields that may not be present, which generates
/// `.optional()` in TypeScript/Zod schemas and expects `Option(t)` in Gleam.
pub type FieldType(t) {
  StringType
  IntType
  FloatType
  BoolType
  ListType(inner: FieldType(t))
  OptionalType(inner: FieldType(t))
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
/// The `default` field is optional - it's only needed if you plan to decode
/// in Gleam. For page props that are only decoded on the frontend via Zod,
/// you can pass `None` to avoid creating unnecessary default values.
///
/// Note: Fields are stored as Field(Erased) to allow heterogeneous field types
/// within a single record. Each Field(u) is erased to Field(Erased) when stored.
pub type RecordSchema(t) {
  RecordSchema(
    name: String,
    fields: dict.Dict(String, Field(Erased)),
    default: option.Option(t),
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
///
/// By default, schemas have no default value and can only be used for encoding
/// and TypeScript generation. If you need to decode in Gleam, use `decode_into()`
/// to provide a default value after building the schema.
pub fn record_schema(name: String) -> RecordSchemaBuilder(t) {
  RecordSchemaBuilder(
    schema: RecordSchema(name: name, fields: dict.new(), default: option.None),
    next_index: 2,
  )
}

/// Set a default value on a schema to enable decoding
///
/// The default value is used as a starting point when decoding - field values
/// from the input override the default. This is only needed if you plan to
/// decode values in Gleam; schemas used only for encoding/TypeScript generation
/// don't need a default.
pub fn decode_into(
  builder: RecordSchemaBuilder(t),
  default: t,
) -> RecordSchemaBuilder(t) {
  RecordSchemaBuilder(
    ..builder,
    schema: RecordSchema(..builder.schema, default: option.Some(default)),
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
  encode_record(schema, to_dynamic(value))
}

/// Encode a value to a Dict(String, Json) using a record schema
///
/// This is useful for building response encoders where you need to conditionally
/// include/exclude fields or combine multiple records.
///
/// ## Example
///
/// ```gleam
/// fn encode_user_props(props: UserProps) -> dict.Dict(String, json.Json) {
///   // Start with base fields from schema
///   let base = schema.to_json_dict(user_schema(), props.user)
///
///   // Conditionally add optional fields
///   case props.avatar {
///     Some(avatar) -> dict.insert(base, "avatar", json.string(avatar))
///     None -> base
///   }
/// }
/// ```
pub fn to_json_dict(
  schema: RecordSchema(t),
  value: t,
) -> dict.Dict(String, json.Json) {
  encode_record_to_dict(schema, to_dynamic(value))
}

/// Encode a value to JSON using a variant schema
pub fn variant_to_json(schema: VariantSchema(t), value: t) -> json.Json {
  encode_variant(schema, to_dynamic(value))
}

fn encode_record(schema: RecordSchema(t), value: dynamic.Dynamic) -> json.Json {
  encode_record_to_dict(schema, value)
  |> dict.to_list()
  |> json.object()
}

fn encode_record_to_dict(
  schema: RecordSchema(t),
  value: dynamic.Dynamic,
) -> dict.Dict(String, json.Json) {
  schema.fields
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(name, field) = entry
    let field_value = element(field.index, value)
    #(name, encode_field(field.field_type, field_value))
  })
  |> dict.from_list()
}

fn encode_variant(schema: VariantSchema(t), value: dynamic.Dynamic) -> json.Json {
  // Use tagger to get the tag for this value
  let tag = schema.tagger(value)

  // Find the record schema for this tag
  case dict.get(schema.cases, tag) {
    Ok(record_schema) -> {
      // Manually encode all fields from the record schema
      let field_entries =
        record_schema.fields
        |> dict.to_list()
        |> list.map(fn(entry) {
          let #(name, field) = entry
          let field_value = element(field.index, value)
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
    OptionalType(inner) -> {
      // Encode Option(t) - Some(value) encodes the inner value, None encodes null
      // The value is already an Option - it was extracted directly from the record
      let option_value = unsafe_cast(value)
      case option_value {
        option.Some(inner_value) -> encode_field(inner, to_dynamic(inner_value))
        option.None -> json.null()
      }
    }
    RecordType(get_schema) -> {
      // Recursively encode nested records
      let nested_schema = get_schema()
      encode_record(nested_schema, value)
    }
    VariantType(get_schema) -> {
      // Recursively encode nested variants
      let nested_schema = get_schema()
      encode_variant(nested_schema, value)
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
  // Check if we have a default value for decoding
  case schema.default {
    option.None ->
      Error(
        "Cannot decode schema '"
        <> schema.name
        <> "' - no default value provided. Use option.Some(default_value) when creating the schema if you need to decode it.",
      )
    option.Some(default_value) -> {
      // Start with default value
      let result = default_value

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
        Ok(setelement(field.index, acc, field_value))
      })
    }
  }
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
  // Special case for RecordType, OptionalType, and ListType(RecordType) - decode recursively
  case field_type {
    OptionalType(inner) -> {
      // For optional fields, decode and validate with decode.optional wrapper
      let decoder = field_type_decoder(inner)
      let field_decoder = {
        use field_value <- decode.field(field_name, decode.optional(decoder))
        decode.success(field_value)
      }

      decode.run(value, field_decoder)
      |> result.map(to_dynamic)
      |> result.map_error(fn(errors) {
        "Failed to decode optional field: "
        <> field_name
        <> " - "
        <> string_from_decode_errors(errors)
      })
    }
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
      |> result.map(to_dynamic)
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
      |> result.map(to_dynamic)
    }
    _ -> {
      // Standard decoding for other types - validate the type
      let decoder = field_type_decoder(field_type)
      let field_decoder = {
        use field_value <- decode.field(field_name, decoder)
        decode.success(field_value)
      }

      decode.run(value, field_decoder)
      |> result.map_error(fn(errors) {
        "Failed to decode field: "
        <> field_name
        <> " - "
        <> string_from_decode_errors(errors)
      })
    }
  }
}

/// Create a decoder that validates a Dynamic value has the correct type,
/// then converts it back to Dynamic for storage in a record.
///
/// This round-trip is necessary because:
/// 1. We need to validate the incoming data has the correct type
/// 2. We need to store it as Dynamic for use with setelement()
fn field_type_decoder(
  field_type: FieldType(t),
) -> decode.Decoder(dynamic.Dynamic) {
  case field_type {
    StringType -> decode.string |> decode.map(dynamic.string)
    IntType -> decode.int |> decode.map(dynamic.int)
    FloatType -> decode.float |> decode.map(dynamic.float)
    BoolType -> decode.bool |> decode.map(dynamic.bool)
    ListType(inner) -> {
      // Recursively validate inner elements
      let inner_decoder = field_type_decoder(inner)
      decode.list(inner_decoder) |> decode.map(dynamic.list)
    }
    OptionalType(inner) -> {
      // Validate the inner type if present
      let inner_decoder = field_type_decoder(inner)
      decode.optional(inner_decoder) |> decode.map(to_dynamic)
    }
    RecordType(_) | VariantType(_) -> {
      // RecordType and VariantType are handled specially in decode_field
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

  let fields_code = fields_to_zod_lines(schema.fields, "  ")

  let schema_def =
    "export const "
    <> schema_name
    <> " = z.object({\n"
    <> fields_code
    <> "\n"
    <> "}).strict();\n\n"

  let type_def = type_infer_definition(type_name, schema_name)

  schema_def <> type_def
}

/// Generate a TypeScript/Zod schema for an Inertia.js page
///
/// This takes a RecordSchema and generates TypeScript with page-specific conventions:
/// - Adds `errors: z.record(z.string(), z.string()).optional()` automatically
/// - Detects OptionalType fields and marks them as optional in the TypeScript schema
/// - Uses `.strict()` mode for validation
///
/// ## Parameters
///
/// - `schema`: The RecordSchema defining the props structure
///
/// ## Example
///
/// ```gleam
/// // With schema name "DashboardPageProps"
/// schema.to_page_props_zod_schema(dashboard_props_schema())
/// // Generates: DashboardPagePropsSchema and DashboardPageProps type
/// ```
pub fn to_page_props_zod_schema(schema schema: RecordSchema(t)) -> String {
  let schema_name = schema.name <> "Schema"
  let type_name = schema.name

  let fields_code =
    fields_to_zod_lines(schema.fields, "  ")
    <> "\n  errors: z.record(z.string(), z.string()).optional(),"

  let schema_def =
    "export const "
    <> schema_name
    <> " = z.object({\n"
    <> fields_code
    <> "\n"
    <> "}).strict();\n\n"

  let type_def = type_infer_definition(type_name, schema_name)

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
          OptionalType(VariantType(_)) -> True
          OptionalType(ListType(VariantType(_))) -> True
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
      let fields = fields_to_zod_lines(record_schema.fields, "    ")

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

  let type_def = type_infer_definition(type_name, schema_name)

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
            OptionalType(VariantType(_)) -> True
            OptionalType(ListType(VariantType(_))) -> True
            _ -> False
          }
        })

      case has_recursive {
        True -> ""
        // Don't generate const for recursive cases
        False -> {
          let fields = fields_to_zod_lines(record_schema.fields, "  ")

          let type_literal = "  type: z.literal(\"" <> tag <> "\"),"

          let case_type_name = record_schema.name

          case dict.size(record_schema.fields) {
            0 ->
              "export const "
              <> case_schema_name
              <> " = z.object({\n"
              <> type_literal
              <> "\n"
              <> "});\n\n"
              <> type_infer_definition(case_type_name, case_schema_name)
              <> "\n"
            _ ->
              "export const "
              <> case_schema_name
              <> " = z.object({\n"
              <> type_literal
              <> "\n"
              <> fields
              <> "\n"
              <> "});\n\n"
              <> type_infer_definition(case_type_name, case_schema_name)
              <> "\n"
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
            OptionalType(VariantType(_)) -> True
            OptionalType(ListType(VariantType(_))) -> True
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
            OptionalType(VariantType(_)) -> True
            OptionalType(ListType(VariantType(_))) -> True
            _ -> False
          }
        })

      case has_recursive {
        True -> {
          // Generate inline object for recursive cases
          let fields = fields_to_zod_lines(record_schema.fields, "    ")

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

// ============================================================================
// Code Generation Helpers
// ============================================================================

/// Generate Zod field declarations from a record schema's fields
/// Returns lines like "  field_name: z.string(),"
fn fields_to_zod_lines(
  fields: dict.Dict(String, Field(t)),
  indent: String,
) -> String {
  fields
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(field_name, field) = entry
    let zod_type = field_type_to_zod(field.field_type)
    indent <> field_name <> ": " <> zod_type <> ","
  })
  |> string.join("\n")
}

/// Generate a TypeScript type definition from a schema name
/// Returns: "export type TypeName = z.infer<typeof TypeNameSchema>;"
fn type_infer_definition(type_name: String, schema_name: String) -> String {
  "export type " <> type_name <> " = z.infer<typeof " <> schema_name <> ">;"
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
    OptionalType(inner) ->
      field_type_to_ts_type(inner, variant_name) <> " | undefined"
    RecordType(get_schema) -> {
      let nested_schema = get_schema()
      nested_schema.name
    }
    VariantType(_) -> variant_name <> "Type"
  }
}

pub fn field_type_to_zod(field_type: FieldType(t)) -> String {
  case field_type {
    StringType -> "z.string()"
    IntType -> "z.number()"
    FloatType -> "z.number()"
    BoolType -> "z.boolean()"
    ListType(inner) -> {
      let inner_zod = field_type_to_zod(inner)
      "z.array(" <> inner_zod <> ")"
    }
    OptionalType(inner) -> {
      let inner_zod = field_type_to_zod(inner)
      inner_zod <> ".optional()"
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
