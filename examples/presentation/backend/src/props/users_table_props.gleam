//// Props for users table page

import gleam/dict
import gleam/json
import gleam/option.{type Option}
import inertia_wisp/page_schema
import inertia_wisp/schema
import schemas/user.{type User}

/// Query parameter types for UsersTable page
pub type UsersTableQueryParams {
  UsersTableQueryParams(page: Int)
}

/// Schema for UsersTable query parameters
pub fn users_table_query_params_schema() -> schema.RecordSchema(_) {
  schema.record_schema("UsersTableQueryParams", UsersTableQueryParams(page: 1))
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

/// Page schema for UsersTable page
pub fn users_table_page_schema() -> page_schema.PageSchema {
  page_schema.page_schema("UsersTable")
  |> page_schema.prop(
    "users",
    schema.ListType(schema.RecordType(user.user_schema)),
  )
  |> page_schema.prop("page", schema.IntType)
  |> page_schema.prop("total_pages", schema.IntType)
  |> page_schema.deferred_prop("demo_info", schema.StringType)
  |> page_schema.build()
}

/// Encoder for UsersTableProps (v2 API)
pub fn encode(props: UsersTableProps) -> dict.Dict(String, json.Json) {
  let base = [
    #("users", json.array(props.users, schema.to_json(user.user_schema(), _))),
    #("page", json.int(props.page)),
    #("total_pages", json.int(props.total_pages)),
  ]

  // Add demo_info only if it's Some
  case props.demo_info {
    option.Some(info) ->
      dict.from_list([#("demo_info", json.string(info)), ..base])
    option.None -> dict.from_list(base)
  }
}
