//// Props for users table page

import gleam/dict
import gleam/json
import gleam/option
import gleam/result
import inertia_wisp/page_schema
import inertia_wisp/prop
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

// Prop types
pub type UsersTableProp {
  UsersProp(List(User))
  PageProp(Int)
  TotalPagesProp(Int)
  DemoInfoProp(String)
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

// Helper functions for creating props
pub fn users(users: List(User)) -> prop.Prop(UsersTableProp) {
  prop.LazyProp("users", fn() { Ok(UsersProp(users)) })
}

pub fn page(value: Int) -> prop.Prop(UsersTableProp) {
  prop.DefaultProp("page", PageProp(value))
}

pub fn total_pages(value: Int) -> prop.Prop(UsersTableProp) {
  prop.DefaultProp("total_pages", TotalPagesProp(value))
}

pub fn demo_info(
  resolver: fn() -> Result(String, dict.Dict(String, String)),
) -> prop.Prop(UsersTableProp) {
  prop.DeferProp("demo_info", option.None, fn() {
    resolver()
    |> result.map(DemoInfoProp)
  })
}

// JSON encoder
pub fn users_table_prop_to_json(prop: UsersTableProp) -> json.Json {
  case prop {
    UsersProp(users) -> {
      json.array(users, fn(user) { schema.to_json(user.user_schema(), user) })
    }
    PageProp(page_num) -> json.int(page_num)
    TotalPagesProp(total) -> json.int(total)
    DemoInfoProp(info) -> json.string(info)
  }
}
