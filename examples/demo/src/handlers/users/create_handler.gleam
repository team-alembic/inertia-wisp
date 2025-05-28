import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option
import handlers/utils
import inertia_wisp
import types/user.{type CreateUserRequest, CreateUserRequest}
import validators/user_validator
import wisp

pub fn create_user_page(req: inertia_wisp.InertiaContext) -> wisp.Response {
  req
  |> utils.assign_common_props()
  |> inertia_wisp.render("CreateUser")
}

pub fn create_user(ctx: inertia_wisp.InertiaContext) -> wisp.Response {
  use json_data <- wisp.require_json(ctx.request)

  case decode_user_request(json_data) {
    Ok(user_request) -> handle_valid_user_request(ctx, user_request)
    Error(_) -> wisp.bad_request()
  }
}

fn decode_user_request(
  json_data: decode.Dynamic,
) -> Result(CreateUserRequest, List(decode.DecodeError)) {
  let user_decoder = {
    use name <- decode.field("name", decode.string)
    use email <- decode.field("email", decode.string)
    use token <- decode.field("_token", decode.string)
    decode.success(CreateUserRequest(name:, email:, token:))
  }

  decode.run(json_data, user_decoder)
}

fn handle_valid_user_request(
  req: inertia_wisp.InertiaContext,
  user_request: CreateUserRequest,
) -> wisp.Response {
  let validation_result =
    user_validator.validate_user_input(
      user_request.name,
      user_request.email,
      option.None,
    )

  case validation_result {
    Ok(_) -> handle_successful_creation(req)
    Error(errors) -> handle_validation_errors(req, user_request, errors)
  }
}

fn handle_successful_creation(
  req: inertia_wisp.InertiaContext,
) -> wisp.Response {
  inertia_wisp.redirect(req, "/users")
}

fn handle_validation_errors(
  req: inertia_wisp.InertiaContext,
  user_request: CreateUserRequest,
  errors: dict.Dict(String, String),
) -> wisp.Response {
  req
  |> utils.assign_common_props()
  |> inertia_wisp.assign_errors(errors)
  |> inertia_wisp.assign_props([
    #(
      "old",
      json.object([
        #("name", json.string(user_request.name)),
        #("email", json.string(user_request.email)),
      ]),
    ),
  ])
  |> inertia_wisp.render("CreateUser")
}
