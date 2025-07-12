//// User index handler for the simple demo application.
////
//// This module handles the users index page which displays a list of all users
//// with search functionality. It demonstrates LazyProp usage for expensive
//// database operations.

import data/users
import gleam/http/request
import gleam/list
import inertia_wisp/inertia
import inertia_wisp/internal/types
import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Display list of all users (demonstrates LazyProp for expensive operations)
pub fn handler(req: Request, db: Connection) -> Response {
  let search_query = case request.get_query(req) {
    Ok(query_params) -> {
      case list.key_find(query_params, "search") {
        Ok(query) -> query
        Error(_) -> ""
      }
    }
    Error(_) -> ""
  }

  let props = [
    types.LazyProp("users", fn() {
      let assert Ok(users_list) = users.search_users(db, search_query)
      user_props.UserList(users_list)
    }),
    types.LazyProp("user_count", fn() {
      let assert Ok(count) = users.get_user_count(db)
      user_props.UserCount(count)
    }),
    types.DefaultProp("search_query", user_props.SearchQuery(search_query)),
  ]

  let page =
    inertia.eval(req, "Users/Index", props, user_props.encode_user_prop)
  inertia.render(req, page)
}
