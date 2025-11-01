//// Props for users table page

import gleam/dict
import gleam/json
import gleam/option.{type Option}
import inertia_wisp/schema
import schemas/user.{type User}

/// Query parameter types for UsersTable page
pub type UsersTableQueryParams {
  UsersTableQueryParams(page: Int)
}

/// Schema for UsersTable query parameters
pub fn users_table_query_params_schema() -> schema.RecordSchema(_) {
  schema.record_schema("UsersTableQueryParams")
  |> schema.decode_into(UsersTableQueryParams(page: 1))
  |> schema.int_field("page")
  |> schema.schema()
}

/// Props for UsersTable page (v2 API - record-based)
pub type UsersTableProps {
  UsersTableProps(
    users: List(User),
    page: Int,
    total_pages: Int,
    demo_info: Option(String),
  )
}

/// Record schema for UsersTable props
pub fn users_table_props_schema() -> schema.RecordSchema(UsersTableProps) {
  schema.record_schema("UsersTablePageProps")
  |> schema.list_field("users", schema.RecordType(user.user_schema))
  |> schema.int_field("page")
  |> schema.int_field("total_pages")
  |> schema.field("demo_info", schema.OptionalType(schema.StringType))
  |> schema.schema()
}

/// Encoder for UsersTableProps (v2 API)
pub fn encode(props: UsersTableProps) -> dict.Dict(String, json.Json) {
  schema.to_json_dict(users_table_props_schema(), props)
}
