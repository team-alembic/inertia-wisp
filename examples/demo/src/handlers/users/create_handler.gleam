import data/users
import gleam/dict
import gleam/json
import gleam/list
import handlers/utils
import inertia_wisp/inertia

import props
import sqlight
import types/user.{type CreateUserRequest}
import validate
import validators/user_validator
import wisp

pub fn create_user_page(ctx: inertia.InertiaContext(inertia.EmptyProps)) -> wisp.Response {
  // Create initial props
  let initial_props = props.UserProps(
    auth: json.null(),
    csrf_token: "",
    users: [],
    pagination: json.null(),
    user: json.null(),
    success: "",
    errors: json.null(),
  )

  // Transform to typed context
  ctx
  |> inertia.set_props(initial_props, props.encode_user_props)
  |> utils.assign_user_common_props()
  |> inertia.render("CreateUser")
}

pub fn create_user(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  db: sqlight.Connection,
) -> wisp.Response {
  use request <- utils.require_json(ctx, user.create_user_request_decoder())
  use <- validate_user_request(ctx, request, db)
  use <- insert_user(ctx, request, db)
  inertia.redirect(ctx.request, "/users")
}

fn validate_user_request(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  user_request: user.CreateUserRequest,
  db,
  cont: fn() -> wisp.Response,
) -> wisp.Response {
  let validation_result =
    user_validator.validate_create_request(user_request, db)
  case validation_result {
    validate.Valid -> cont()
    validate.Invalid(errors) -> validation_error_response(ctx, errors)
  }
}

fn insert_user(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  user_request: CreateUserRequest,
  db: sqlight.Connection,
  cont: fn() -> wisp.Response,
) -> wisp.Response {
  case users.create_user(db, user_request.name, user_request.email) {
    Ok(_) -> cont()
    Error(_e) -> {
      let errors = dict.from_list([#("general", "Failed to create user")])
      validation_error_response(ctx, errors)
    }
  }
}

fn validation_error_response(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  errors: dict.Dict(String, String),
) -> wisp.Response {
  // Create initial props
  let initial_props = props.UserProps(
    auth: json.null(),
    csrf_token: "",
    users: [],
    pagination: json.null(),
    user: json.null(),
    success: "",
    errors: json.null(),
  )

  // Transform to typed context
  ctx
  |> inertia.set_props(initial_props, props.encode_user_props)
  |> utils.assign_user_common_props()
  |> inertia.assign_prop("errors", fn(props) {
    props.UserProps(..props, errors: json.object(dict.to_list(errors) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })))
  })
  |> inertia.render("CreateUser")
}
