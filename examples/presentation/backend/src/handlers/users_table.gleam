//// Users table handler for pagination demonstration
////
//// Demonstrates Inertia's partial reload with `only` parameter

import gleam/erlang/process
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import gleam/uri
import inertia_wisp/inertia
import inertia_wisp/prop.{DefaultProp, DeferProp}
import shared/user.{type User, User, user_to_json}
import wisp.{type Request, type Response}

// Prop types and JSON encoding
pub type UsersProp {
  UsersProp(List(User))
  PageProp(Int)
  TotalPagesProp(Int)
  DemoInfoProp(String)
}

fn users_prop_to_json(prop: UsersProp) -> json.Json {
  case prop {
    UsersProp(users) -> {
      json.array(users, user_to_json)
    }
    PageProp(page) -> json.int(page)
    TotalPagesProp(total) -> json.int(total)
    DemoInfoProp(info) -> json.string(info)
  }
}

/// Display the paginated users table
pub fn show_users_table(req: Request) -> Response {
  // Parse page from query string, default to 1
  let page = parse_query_param(req, "page", int.parse, 1)

  // Generate and paginate users
  let all_users = generate_users(100)
  let per_page = 10
  let paginated_users = paginate(all_users, page, per_page)
  let total_pages = { 100 + per_page - 1 } / per_page

  // Build props
  let props = [
    DefaultProp("users", UsersProp(paginated_users)),
    DefaultProp("page", PageProp(page)),
    DefaultProp("total_pages", TotalPagesProp(total_pages)),
    DeferProp("demo_info", option.None, fn() {
      // Artificial delay to demonstrate deferred loading
      process.sleep(2000)
      Ok(DemoInfoProp("🎉 This DeferProp loaded after 2 seconds!"))
    }),
  ]

  req
  |> inertia.response_builder("UsersTable")
  |> inertia.props(props, users_prop_to_json)
  |> inertia.response(200)
}

/// Parse a query parameter from the request
///
/// Accepts a parameter name, a parser function, and a default value.
/// Returns the parsed value or the default if parsing fails.
fn parse_query_param(
  req: Request,
  param_name: String,
  parser: fn(String) -> Result(a, Nil),
  default: a,
) -> a {
  case req.query {
    option.Some(query_string) -> {
      uri.parse_query(query_string)
      |> result.unwrap([])
      |> list.key_find(param_name)
      |> result.try(parser)
      |> result.unwrap(default)
    }
    option.None -> default
  }
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
