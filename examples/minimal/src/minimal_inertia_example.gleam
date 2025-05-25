import gleam/dict
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/http
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import inertia_gleam
import mist
import wisp
import wisp/wisp_mist

// Simple in-memory data store for the demo
type User {
  User(id: Int, name: String, email: String)
}

type AppState {
  AppState(users: List(User), next_id: Int)
}

type CreateUserRequest {
  CreateUserRequest(name: String, email: String, token: String)
}

// Global state for the demo (in a real app, use a proper database)
fn get_initial_state() -> AppState {
  AppState(
    users: [
      User(id: 1, name: "Alice", email: "alice@example.com"),
      User(id: 2, name: "Bob", email: "bob@example.com"),
    ],
    next_id: 3,
  )
}

pub fn main() {
  wisp.configure_logger()

  let assert Ok(_) =
    fn(req) { handle_request(req) }
    |> wisp_mist.handler("secret_key_change_me_in_production")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn handle_request(req: wisp.Request) -> wisp.Response {
  use <- wisp.serve_static(req, from: "./static", under: "/static")
  use req <- inertia_gleam.inertia_middleware(req)

  case wisp.path_segments(req), req.method {
    [], http.Get -> home_page(req)
    ["about"], http.Get -> about_page(req)
    ["users"], http.Get -> users_page(req)
    ["users", "create"], http.Get -> create_user_page(req)
    ["users"], http.Post -> create_user(req)
    ["users", id], http.Get -> show_user_page(req, id)
    ["users", id, "edit"], http.Get -> edit_user_page(req, id)
    ["users", id], http.Post -> update_user(req, id)
    ["users", id, "delete"], http.Post -> delete_user(req, id)
    _, _ -> wisp.not_found()
  }
}

fn home_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> inertia_gleam.assign_always_props([
    #(
      "auth",
      json.object([
        #("authenticated", json.bool(True)),
        #("user", json.string("demo_user")),
      ]),
    ),
    #("csrf_token", json.string("abc123xyz")),
  ])
  |> inertia_gleam.assign_props([
    #("message", json.string("Hello from Gleam!")),
    #("timestamp", json.string("2024-01-01T00:00:00Z")),
    #("user_count", json.int(list.length(get_initial_state().users))),
  ])
  |> inertia_gleam.render("Home")
}

fn about_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> inertia_gleam.assign_always_props([
    #(
      "auth",
      json.object([
        #("authenticated", json.bool(True)),
        #("user", json.string("demo_user")),
      ]),
    ),
    #("csrf_token", json.string("abc123xyz")),
  ])
  |> inertia_gleam.assign_prop("page_title", json.string("About Us"))
  |> inertia_gleam.render("About")
}

fn users_page(req: wisp.Request) -> wisp.Response {
  let users_json =
    list.map(get_initial_state().users, fn(user) {
      json.object([
        #("id", json.int(user.id)),
        #("name", json.string(user.name)),
        #("email", json.string(user.email)),
      ])
    })

  inertia_gleam.context(req)
  |> inertia_gleam.assign_always_props([
    #(
      "auth",
      json.object([
        #("authenticated", json.bool(True)),
        #("user", json.string("demo_user")),
      ]),
    ),
    #("csrf_token", json.string("abc123xyz")),
  ])
  |> inertia_gleam.assign_prop("users", json.array(users_json, fn(x) { x }))
  |> inertia_gleam.render("Users")
}

fn create_user_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> inertia_gleam.assign_always_props([
    #(
      "auth",
      json.object([
        #("authenticated", json.bool(True)),
        #("user", json.string("demo_user")),
      ]),
    ),
    #("csrf_token", json.string("abc123xyz")),
  ])
  |> inertia_gleam.render("CreateUser")
}

fn create_user(req: wisp.Request) -> wisp.Response {
  use json_data <- wisp.require_json(req)

  let user_decoder = {
    use name <- decode.field("name", decode.string)
    use email <- decode.field("email", decode.string)
    use token <- decode.field("_token", decode.string)
    decode.success(CreateUserRequest(name:, email:, token:))
  }

  case decode.run(json_data, user_decoder) {
    Ok(user_request) -> {
      // Simple validation
      let errors = validate_user_input(user_request.name, user_request.email, None)

      case dict.size(errors) {
        0 -> {
          // Simulate user creation success
          inertia_gleam.redirect_after_form(req, "/users")
        }
        _ -> {
          // Return with validation errors
          inertia_gleam.context(req)
          |> inertia_gleam.assign_always_props([
            #(
              "auth",
              json.object([
                #("authenticated", json.bool(True)),
                #("user", json.string("demo_user")),
              ]),
            ),
            #("csrf_token", json.string("abc123xyz")),
          ])
          |> inertia_gleam.assign_errors(errors)
          |> inertia_gleam.assign_props([
            #(
              "old",
              json.object([
                #("name", json.string(user_request.name)),
                #("email", json.string(user_request.email)),
              ]),
            ),
          ])
          |> inertia_gleam.render("CreateUser")
        }
      }
    }
    Error(_) -> {
      wisp.bad_request()
    }
  }
}

fn show_user_page(req: wisp.Request, id_str: String) -> wisp.Response {
  case int.parse(id_str) {
    Ok(id) -> {
      case find_user_by_id(id) {
        Ok(user) -> {
          let user_json =
            json.object([
              #("id", json.int(user.id)),
              #("name", json.string(user.name)),
              #("email", json.string(user.email)),
            ])

          inertia_gleam.context(req)
          |> inertia_gleam.assign_always_props([
            #(
              "auth",
              json.object([
                #("authenticated", json.bool(True)),
                #("user", json.string("demo_user")),
              ]),
            ),
            #("csrf_token", json.string("abc123xyz")),
          ])
          |> inertia_gleam.assign_prop("user", user_json)
          |> inertia_gleam.render("ShowUser")
        }
        Error(_) -> wisp.not_found()
      }
    }
    Error(_) -> wisp.not_found()
  }
}

fn edit_user_page(req: wisp.Request, id_str: String) -> wisp.Response {
  case int.parse(id_str) {
    Ok(id) -> {
      case find_user_by_id(id) {
        Ok(user) -> {
          let user_json =
            json.object([
              #("id", json.int(user.id)),
              #("name", json.string(user.name)),
              #("email", json.string(user.email)),
            ])

          inertia_gleam.context(req)
          |> inertia_gleam.assign_always_props([
            #(
              "auth",
              json.object([
                #("authenticated", json.bool(True)),
                #("user", json.string("demo_user")),
              ]),
            ),
            #("csrf_token", json.string("abc123xyz")),
          ])
          |> inertia_gleam.assign_prop("user", user_json)
          |> inertia_gleam.render("EditUser")
        }
        Error(_) -> wisp.not_found()
      }
    }
    Error(_) -> wisp.not_found()
  }
}

fn update_user(req: wisp.Request, id_str: String) -> wisp.Response {
  use json_data <- wisp.require_json(req)

  case int.parse(id_str) {
    Ok(id) -> {
      case find_user_by_id(id) {
        Ok(user) -> {
          let user_decoder = {
            use name <- decode.field("name", decode.string)
            use email <- decode.field("email", decode.string)
            use token <- decode.field("_token", decode.string)
            decode.success(CreateUserRequest(name:, email:, token:))
          }

          case decode.run(json_data, user_decoder) {
            Ok(user_request) -> {
              // Simple validation
              let errors = validate_user_input(user_request.name, user_request.email, Some(id))

              case dict.size(errors) {
                0 -> {
                  // Simulate user update success
                  inertia_gleam.redirect_after_form(req, "/users/" <> id_str)
                }
                _ -> {
                  // Return with validation errors
                  let user_json =
                    json.object([
                      #("id", json.int(user.id)),
                      #("name", json.string(user_request.name)),
                      #("email", json.string(user_request.email)),
                    ])

                  inertia_gleam.context(req)
                  |> inertia_gleam.assign_always_props([
                    #(
                      "auth",
                      json.object([
                        #("authenticated", json.bool(True)),
                        #("user", json.string("demo_user")),
                      ]),
                    ),
                    #("csrf_token", json.string("abc123xyz")),
                  ])
                  |> inertia_gleam.assign_errors(errors)
                  |> inertia_gleam.assign_prop("user", user_json)
                  |> inertia_gleam.render("EditUser")
                }
              }
            }
            Error(_) -> {
              wisp.bad_request()
            }
          }
        }
        Error(_) -> wisp.not_found()
      }
    }
    Error(_) -> wisp.not_found()
  }
}

fn delete_user(req: wisp.Request, id_str: String) -> wisp.Response {
  case int.parse(id_str) {
    Ok(id) -> {
      case find_user_by_id(id) {
        Ok(_user) -> {
          // Simulate user deletion success
          inertia_gleam.redirect_after_form(req, "/users")
        }
        Error(_) -> wisp.not_found()
      }
    }
    Error(_) -> wisp.not_found()
  }
}

// Helper functions

fn find_user_by_id(id: Int) -> Result(User, Nil) {
  get_initial_state().users
  |> list.find(fn(user) { user.id == id })
}

fn validate_user_input(
  name: String,
  email: String,
  existing_id: Option(Int),
) -> dict.Dict(String, String) {
  let errors = dict.new()

  let trimmed_name = string.trim(name)
  let errors = case trimmed_name {
    "" -> dict.insert(errors, "name", "Name is required")
    _ -> {
      case string.length(trimmed_name) < 2 {
        True ->
          dict.insert(errors, "name", "Name must be at least 2 characters")
        False -> errors
      }
    }
  }

  let trimmed_email = string.trim(email)
  let errors = case trimmed_email {
    "" -> dict.insert(errors, "email", "Email is required")
    _ -> {
      case string.contains(trimmed_email, "@") {
        False -> dict.insert(errors, "email", "Email must contain @")
        True -> {
          // Check for duplicate email (excluding current user if editing)
          let is_duplicate = case existing_id {
            Some(id) ->
              get_initial_state().users
              |> list.any(fn(user) {
                user.email == trimmed_email && user.id != id
              })
            None ->
              get_initial_state().users
              |> list.any(fn(user) { user.email == trimmed_email })
          }

          case is_duplicate {
            True -> dict.insert(errors, "email", "Email already exists")
            False -> errors
          }
        }
      }
    }
  }

  errors
}


