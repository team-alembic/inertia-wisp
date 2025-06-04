import data/users as user_data
import gleam/dict
import handlers/utils
import inertia_wisp/inertia
import shared_types/users as user_props
import shared_types/users.{type CreateUserRequest}
import sqlight
import validate
import validators/user_validator
import wisp

pub fn create_user_page(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
  ctx
  |> inertia.with_encoder(user_props.encode_user_page_prop)
  |> inertia.always_prop("auth", user_props.Auth(utils.get_demo_auth()))
  |> inertia.always_prop(
    "csrf_token",
    user_props.CsrfToken(utils.get_csrf_token()),
  )
  |> inertia.render("CreateUser")
}

pub fn create_user(
  ctx: inertia.InertiaContext(Nil),
  db: sqlight.Connection,
) -> wisp.Response {
  use request <- inertia.require_json(ctx, users.create_user_request_decoder())
  use <- validate_user_request(ctx, request, db)
  use <- insert_user(ctx, request, db)
  inertia.redirect(ctx.request, "/users")
}

fn validate_user_request(
  ctx: inertia.InertiaContext(Nil),
  user_request: users.CreateUserRequest,
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
  ctx: inertia.InertiaContext(Nil),
  user_request: CreateUserRequest,
  db: sqlight.Connection,
  cont: fn() -> wisp.Response,
) -> wisp.Response {
  case user_data.create_user(db, user_request.name, user_request.email) {
    Ok(_) -> cont()
    Error(_e) -> {
      let errors = dict.from_list([#("general", "Failed to create user")])
      validation_error_response(ctx, errors)
    }
  }
}

fn validation_error_response(
  ctx: inertia.InertiaContext(Nil),
  errors: dict.Dict(String, String),
) -> wisp.Response {
  let validation_errors =
    user_props.ValidationErrors(errors: dict.to_list(errors))

  ctx
  |> inertia.with_encoder(user_props.encode_user_page_prop)
  |> inertia.always_prop("auth", user_props.Auth(utils.get_demo_auth()))
  |> inertia.always_prop(
    "csrf_token",
    user_props.CsrfToken(utils.get_csrf_token()),
  )
  |> inertia.prop("errors", user_props.Errors(validation_errors))
  |> inertia.render("CreateUser")
}
