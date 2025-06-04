import data/users as user_data
import gleam/dict
import handlers/utils
import inertia_wisp/inertia
import shared_types/users as user_props
import shared_types/users.{type User}
import sqlight
import validate
import validators/user_validator
import wisp

pub fn edit_user_page(
  ctx: inertia.InertiaContext(Nil),
  id_str: String,
  db: sqlight.Connection,
) -> wisp.Response {
  use id <- utils.require_int(id_str)
  use user <- find_user(id, db)

  let user_prop_data =
    user_props.User(id: user.id, name: user.name, email: user.email)

  ctx
  |> inertia.with_encoder(user_props.encode_user_page_prop)
  |> inertia.always_prop("auth", user_props.Auth(utils.get_demo_auth()))
  |> inertia.always_prop(
    "csrf_token",
    user_props.CsrfToken(utils.get_csrf_token()),
  )
  |> inertia.prop("user", user_props.UserProp(user_prop_data))
  |> inertia.render("EditUser")
}

fn find_user(
  id: Int,
  db: sqlight.Connection,
  cont: fn(User) -> wisp.Response,
) -> wisp.Response {
  case user_data.find_user_by_id(db, id) {
    Ok(user) -> cont(user)
    Error(_) -> wisp.not_found()
  }
}

pub fn update_user(
  ctx: inertia.InertiaContext(Nil),
  id_str: String,
  db: sqlight.Connection,
) -> wisp.Response {
  use id <- utils.require_int(id_str)
  let decoder = users.edit_user_request_decoder(id)
  use update_request <- inertia.require_json(ctx, decoder)
  use user <- find_user(id, db)
  use <- validate_update_request(ctx, update_request, user, db)
  case
    user_data.update_user(db, id, update_request.name, update_request.email)
  {
    Ok(_) -> inertia.redirect(ctx.request, "/users/" <> id_str)
    Error(_) -> {
      let errors = dict.from_list([#("general", "Failed to update user")])
      error_response(ctx, user, errors)
    }
  }
}

fn validate_update_request(
  ctx,
  update_request,
  user,
  db,
  cont: fn() -> wisp.Response,
) {
  let validation_result =
    user_validator.validate_update_request(user, update_request, db)
  case validation_result {
    validate.Valid -> cont()
    validate.Invalid(errors) -> error_response(ctx, user, errors)
  }
}

fn error_response(
  ctx: inertia.InertiaContext(Nil),
  user: User,
  errors: dict.Dict(String, String),
) -> wisp.Response {
  let user_prop_data =
    users.User(id: user.id, name: user.name, email: user.email)

  let validation_errors =
    user_props.ValidationErrors(errors: dict.to_list(errors))

  ctx
  |> inertia.with_encoder(user_props.encode_user_page_prop)
  |> inertia.always_prop("auth", user_props.Auth(utils.get_demo_auth()))
  |> inertia.always_prop(
    "csrf_token",
    user_props.CsrfToken(utils.get_csrf_token()),
  )
  |> inertia.prop("user", user_props.UserProp(user_prop_data))
  |> inertia.prop("errors", user_props.Errors(validation_errors))
  |> inertia.render("EditUser")
}
