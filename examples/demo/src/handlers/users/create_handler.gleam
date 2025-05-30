import data/users
import gleam/dict
import handlers/utils
import inertia_wisp/inertia
import sqlight
import types/user.{type CreateUserRequest}
import validate
import validators/user_validator
import wisp

pub fn create_user_page(req: inertia.InertiaContext) -> wisp.Response {
  req
  |> utils.assign_common_props()
  |> inertia.render("CreateUser")
}

pub fn create_user(
  ctx: inertia.InertiaContext,
  db: sqlight.Connection,
) -> wisp.Response {
  use request <- utils.require_json(ctx, user.create_user_request_decoder())
  use <- validate_user_request(ctx, request, db)
  use <- insert_user(ctx, request, db)
  inertia.redirect(ctx, "/users")
}

fn validate_user_request(
  ctx: inertia.InertiaContext,
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
  ctx: inertia.InertiaContext,
  user_request: CreateUserRequest,
  db: sqlight.Connection,
  cont: fn() -> wisp.Response,
) -> wisp.Response {
  case users.create_user(db, user_request.name, user_request.email) {
    Ok(_) -> cont()
    Error(e) -> {
      let errors = dict.from_list([#("general", "Failed to create user")])
      validation_error_response(ctx, errors)
    }
  }
}

fn validation_error_response(
  req: inertia.InertiaContext,
  errors: dict.Dict(String, String),
) -> wisp.Response {
  req
  |> utils.assign_common_props()
  |> inertia.assign_errors(errors)
  |> inertia.render("CreateUser")
}
