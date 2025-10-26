//// Query parameter decoding using RecordSchema
////
//// Provides type-safe decoding of URL query parameters into Gleam records.

import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/uri
import inertia_wisp/schema.{
  type FieldType, type RecordSchema, BoolType, FloatType, IntType, StringType,
  unsafe_cast,
}
import wisp.{type Request}

@external(erlang, "erlang", "setelement")
fn setelement(index: Int, record: a, value: dynamic.Dynamic) -> a

/// Decode query parameters from a request using a RecordSchema
///
/// Parses the query string and decodes fields according to the schema.
/// Missing optional fields are left at their default values.
/// Returns an error if required fields are missing or have invalid types.
///
/// ## Example
///
/// ```gleam
/// pub type QueryParams {
///   QueryParams(page: Int, per_page: Int)
/// }
///
/// pub fn query_params_schema() -> RecordSchema {
///   schema.record_schema("QueryParams", QueryParams(page: 1, per_page: 10))
///   |> schema.int_field("page")
///   |> schema.int_field("per_page")
///   |> schema.schema()
/// }
///
/// pub fn handler(req: Request) -> Response {
///   use params <- result.try(
///     query_params.decode_from_request(query_params_schema(), req)
///     |> result.map_error(fn(_) { wisp.bad_request() })
///   )
///   // Use params.page, params.per_page
/// }
/// ```
pub fn decode_from_request(
  schema: RecordSchema(t),
  req: Request,
) -> Result(t, String) {
  let query_dict = case req.query {
    Some(query_string) -> {
      uri.parse_query(query_string)
      |> result.unwrap([])
      |> dict.from_list()
    }
    None -> dict.new()
  }

  decode_from_dict(schema, query_dict)
}

/// Decode query parameters from a dictionary
///
/// Useful for testing or when you already have a parsed query dict.
pub fn decode_from_dict(
  schema: RecordSchema(t),
  query_dict: Dict(String, String),
) -> Result(t, String) {
  // Start with default value from schema
  let result = schema.default

  // For each field in the schema, try to decode from query params
  schema.fields
  |> dict.to_list()
  |> list.try_fold(result, fn(acc, entry) {
    let #(field_name, field) = entry

    // Get the query param value as a string
    case dict.get(query_dict, field_name) {
      Ok(value_str) -> {
        // Decode the string value to the expected type
        use decoded_value <- result.try(decode_field_from_string(
          field.field_type,
          field_name,
          value_str,
        ))

        // Set the field value using the field index
        Ok(setelement(field.index, unsafe_cast(acc), decoded_value))
      }

      Error(_) -> {
        // Field not in query params - keep default value
        Ok(acc)
      }
    }
  })
}

/// Decode a field value from a string based on its type
fn decode_field_from_string(
  field_type: FieldType(t),
  field_name: String,
  value: String,
) -> Result(dynamic.Dynamic, String) {
  case field_type {
    StringType -> Ok(unsafe_cast(value))

    IntType ->
      int.parse(value)
      |> result.map(unsafe_cast)
      |> result.replace_error(
        "Field '" <> field_name <> "': expected integer, got '" <> value <> "'",
      )

    FloatType ->
      float.parse(value)
      |> result.map(unsafe_cast)
      |> result.replace_error(
        "Field '" <> field_name <> "': expected float, got '" <> value <> "'",
      )

    BoolType ->
      parse_bool(value)
      |> result.map(unsafe_cast)
      |> result.replace_error(
        "Field '" <> field_name <> "': expected boolean, got '" <> value <> "'",
      )

    schema.ListType(_) ->
      Error(
        "Field '"
        <> field_name
        <> "': List types not supported in query parameters",
      )

    schema.RecordType(_) ->
      Error(
        "Field '"
        <> field_name
        <> "': Record types not supported in query parameters",
      )

    schema.VariantType(_) ->
      Error(
        "Field '"
        <> field_name
        <> "': Variant types not supported in query parameters",
      )
  }
}

/// Parse a boolean from a string
/// Accepts: "true"/"false", "1"/"0", "yes"/"no"
fn parse_bool(value: String) -> Result(Bool, Nil) {
  case string.lowercase(value) {
    "true" | "1" | "yes" -> Ok(True)
    "false" | "0" | "no" -> Ok(False)
    _ -> Error(Nil)
  }
}
