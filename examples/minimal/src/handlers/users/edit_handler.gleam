import data/users
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option
import handlers/utils
import inertia_gleam
import types/user.{type CreateUserRequest, type User, CreateUserRequest}
import validators/user_validator
import wisp

pub fn edit_user_page(req: wisp.Request, id_str: String) -> wisp.Response {
  case utils.parse_user_id(id_str) {
    Ok(id) -> handle_valid_edit_request(req, id)
    Error(_) -> wisp.not_found()
  }
}

pub fn update_user(req: wisp.Request, id_str: String) -> wisp.Response {
  use json_data <- wisp.require_json(req)

  case utils.parse_user_id(id_str) {
    Ok(id) -> handle_valid_update_request(req, id, id_str, json_data)
    Error(_) -> wisp.not_found()
  }
}

fn handle_valid_edit_request(req: wisp.Request, id: Int) -> wisp.Response {
  case users.find_user_by_id(id) {
    Ok(user) -> render_edit_page(req, user)
    Error(_) -> wisp.not_found()
  }
}

fn handle_valid_update_request(
  req: wisp.Request,
  id: Int,
  id_str: String,
  json_data,
) -> wisp.Response {
  case users.find_user_by_id(id) {
    Ok(found_user) ->
      process_update_request(req, id, id_str, found_user, json_data)
    Error(_) -> wisp.not_found()
  }
}

fn process_update_request(
  req: wisp.Request,
  id: Int,
  id_str: String,
  found_user: User,
  json_data,
) -> wisp.Response {
  case decode_user_request(json_data) {
    Ok(user_request) ->
      handle_decoded_update(req, id, id_str, found_user, user_request)
    Error(_) -> wisp.bad_request()
  }
}

fn handle_decoded_update(
  req: wisp.Request,
  id: Int,
  id_str: String,
  found_user: User,
  user_request: CreateUserRequest,
) -> wisp.Response {
  let validation_result =
    user_validator.validate_user_input(
      user_request.name,
      user_request.email,
      option.Some(id),
    )

  case validation_result {
    Ok(_) -> handle_successful_update(req, id_str)
    Error(errors) ->
      handle_update_validation_errors(req, found_user, user_request, errors)
  }
}

fn decode_user_request(
  json_data,
) -> Result(CreateUserRequest, List(decode.DecodeError)) {
  let user_decoder = {
    use name <- decode.field("name", decode.string)
    use email <- decode.field("email", decode.string)
    use token <- decode.field("_token", decode.string)
    decode.success(CreateUserRequest(name:, email:, token:))
  }

  decode.run(json_data, user_decoder)
}

fn render_edit_page(req: wisp.Request, user: User) -> wisp.Response {
  let user_data = utils.serialize_user_data(user)

  inertia_gleam.context(req)
  |> utils.assign_common_props()
  |> inertia_gleam.assign_prop("user", user_data)
  |> inertia_gleam.render("EditUser")
}

fn handle_successful_update(req: wisp.Request, id_str: String) -> wisp.Response {
  inertia_gleam.redirect(req, "/users/" <> id_str)
}

fn handle_update_validation_errors(
  req: wisp.Request,
  found_user: User,
  user_request: CreateUserRequest,
  errors: dict.Dict(String, String),
) -> wisp.Response {
  let user_data = serialize_user_with_form_data(found_user, user_request)

  inertia_gleam.context(req)
  |> utils.assign_common_props()
  |> inertia_gleam.assign_errors(errors)
  |> inertia_gleam.assign_prop("user", user_data)
  |> inertia_gleam.render("EditUser")
}

fn serialize_user_with_form_data(
  found_user: User,
  user_request: CreateUserRequest,
) -> json.Json {
  json.object([
    #("id", json.int(found_user.id)),
    #("name", json.string(user_request.name)),
    #("email", json.string(user_request.email)),
  ])
}
