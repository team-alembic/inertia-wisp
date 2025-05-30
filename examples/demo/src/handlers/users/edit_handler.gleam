import data/users
import gleam/dict
import handlers/utils
import inertia_wisp/inertia
import sqlight
import types/user.{type User}
import validate
import validators/user_validator
import wisp

pub fn edit_user_page(
  req: inertia.InertiaContext,
  id_str: String,
  db: sqlight.Connection,
) -> wisp.Response {
  use id <- utils.require_int(id_str)
  use user <- find_user(id, db)
  req
  |> utils.assign_common_props()
  |> inertia.assign_prop("user", user.user_to_json(user))
  |> inertia.render("EditUser")
}

fn find_user(
  id: Int,
  db: sqlight.Connection,
  cont: fn(User) -> wisp.Response,
) -> wisp.Response {
  case users.find_user_by_id(db, id) {
    Ok(user) -> cont(user)
    Error(_) -> wisp.not_found()
  }
}

pub fn update_user(
  ctx: inertia.InertiaContext,
  id_str: String,
  db: sqlight.Connection,
) -> wisp.Response {
  use id <- utils.require_int(id_str)
  let decoder = user.edit_user_request_decoder(id)
  use update_request <- utils.require_json(ctx, decoder)
  use user <- find_user(id, db)
  use <- validate_update_request(ctx, update_request, user, db)
  case users.update_user(db, id, update_request.name, update_request.email) {
    Ok(_) -> inertia.redirect(ctx, "/users/" <> id_str)
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

fn error_response(ctx, user, errors) {
  ctx
  |> utils.assign_common_props()
  |> inertia.assign_prop("user", user.user_to_json(user))
  |> inertia.assign_errors(errors)
  |> inertia.render("EditUser")
}
