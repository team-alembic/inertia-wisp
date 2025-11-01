//// Users table handler for pagination demonstration
////
//// Demonstrates Inertia's partial reload with `only` parameter

import gleam/erlang/process
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import inertia_wisp/inertia
import inertia_wisp/query_params
import props/users_table_props.{UsersTableProps, UsersTableQueryParams}
import schemas/user.{type User, User}
import wisp.{type Request, type Response}

/// Display the paginated users table
pub fn show_users_table(req: Request) -> Response {
  // Decode query parameters using schema
  let UsersTableQueryParams(page:) =
    query_params.decode_from_request(
      users_table_props.users_table_query_params_schema(),
      req,
    )
    |> result.unwrap(UsersTableQueryParams(page: 1))

  let per_page = 10
  let total_pages = { 100 + per_page - 1 } / per_page

  // Compute paginated users
  let all_users = generate_users(100)
  let paginated_users = paginate(all_users, page, per_page)

  // Build base props
  let props =
    UsersTableProps(
      users: paginated_users,
      page: page,
      total_pages: total_pages,
      demo_info: option.None,
    )

  req
  |> inertia.response_builder("UsersTable")
  |> inertia.props(props, users_table_props.encode)
  |> inertia.defer("demo_info", fn(props) {
    // Artificial delay to demonstrate deferred loading
    process.sleep(2000)
    Ok(
      UsersTableProps(
        ..props,
        demo_info: option.Some("🎉 This DeferProp loaded after 2 seconds!"),
      ),
    )
  })
  |> inertia.response(200)
}

/// Generate sample users for demonstration
pub fn generate_users(count: Int) -> List(User) {
  list.range(1, count)
  |> list.map(fn(id) {
    User(
      id: id,
      name: "User " <> int.to_string(id),
      email: "user" <> int.to_string(id) <> "@example.com",
    )
  })
}

/// Paginate a list of users
pub fn paginate(users: List(User), page: Int, per_page: Int) -> List(User) {
  case page < 1 {
    True -> []
    False -> {
      let start = { page - 1 } * per_page
      users
      |> list.drop(start)
      |> list.take(per_page)
    }
  }
}
