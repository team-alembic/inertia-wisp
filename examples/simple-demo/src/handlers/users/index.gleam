//// User index handler for the simple demo application.
////
//// This module handles GET requests to list all users.
//// Demonstrates Response Builder API with search functionality and LazyProps.

import data/users
import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleam/uri
import inertia_wisp/inertia

import props/user_props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle user index (GET)
///
/// This demonstrates the Response Builder API with:
/// 1. User listing (expensive operation - good for LazyProp)
/// 2. Search functionality via query parameters
/// 3. User count (another expensive operation)
/// 4. Error handling for database operations
pub fn handler(req: Request, db: Connection) -> Response {
  let search_query = get_search_query(req)
  let search_result = get_users(search_query, db)

  case search_result {
    Ok(users_data) -> {
      let props = [
        user_props.user_list(users_data),
        user_props.user_count(list.length(users_data)),
        user_props.search_query(search_query),
        // Optional Prop - only evaluated if requested
        user_props.user_analytics(fn() { compute_user_analytics(db) }),
        // Deferred Prop - will be evaluated in partial reload after initial response
        user_props.user_report(fn() { generate_user_report(db) }),
      ]

      req
      |> inertia.response_builder("Users/Index")
      |> inertia.on_error("Error")
      |> inertia.props(props, user_props.user_prop_to_json)
      |> inertia.response()
    }
    Error(errors) -> {
      req
      |> inertia.response_builder("Error")
      |> inertia.errors(errors)
      |> inertia.response()
    }
  }
}

/// Get users from search_query, handling database errors
fn generate_user_report(
  db: Connection,
) -> Result(users.UserReport, dict.Dict(String, String)) {
  users.generate_user_report(db)
  |> result.map_error(fn(_) {
    dict.from_list([
      #("report", "Unable to generate user report. Please try again later."),
    ])
  })
}

fn get_users(
  search_query: String,
  db: Connection,
) -> Result(List(users.User), dict.Dict(String, String)) {
  case users.search_users(db, search_query) {
    Ok(users_data) -> Ok(users_data)
    Error(_) -> {
      Error(
        dict.from_list([
          #(
            "message",
            "Database error occurred while fetching users. Please try again later.",
          ),
        ]),
      )
    }
  }
}

/// Extract search query from request parameters
fn get_search_query(req: Request) -> String {
  case req.query {
    option.Some(query_string) -> {
      case uri.parse_query(query_string) {
        Ok(params) -> {
          case list.key_find(params, "search") {
            Ok(search_term) -> search_term
            Error(_) -> ""
          }
        }
        Error(_) -> ""
      }
    }
    option.None -> ""
  }
}

fn compute_user_analytics(
  db: Connection,
) -> Result(users.UserAnalytics, dict.Dict(String, String)) {
  users.compute_user_analytics(db)
  |> result.map_error(fn(_) {
    dict.from_list([#("analytics", "Unable to compute user analytics")])
  })
}
