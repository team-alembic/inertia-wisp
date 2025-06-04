import gleam/dynamic/decode
import gleam/json
import gleam/list
import shared_types/auth

// ===== DOMAIN TYPES =====

pub type User {
  User(id: Int, name: String, email: String)
}

pub fn encode_user(user: User) -> json.Json {
  json.object([
    #("id", json.int(user.id)),
    #("name", json.string(user.name)),
    #("email", json.string(user.email)),
  ])
}

pub type Pagination {
  Pagination(current_page: Int, total_pages: Int, total_items: Int)
}

pub fn encode_pagination(pagination: Pagination) -> json.Json {
  json.object([
    #("current_page", json.int(pagination.current_page)),
    #("total_pages", json.int(pagination.total_pages)),
    #("total_items", json.int(pagination.total_items)),
  ])
}

pub type ValidationErrors {
  ValidationErrors(errors: List(#(String, String)))
}

pub fn encode_validation_errors(errors: ValidationErrors) -> json.Json {
  json.object(
    errors.errors
    |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
  )
}

// ===== PROPS TYPES (with encoders) =====

pub type UserPageProp {
  Auth(auth: auth.Auth)
  CsrfToken(csrf_token: String)
  Users(users: List(User))
  PaginationProp(pagination: Pagination)
  UserProp(user: User)
  Success(success: String)
  Errors(errors: ValidationErrors)
}

pub fn encode_user_page_prop(prop: UserPageProp) -> json.Json {
  case prop {
    Auth(auth_val) -> auth.encode_auth(auth_val)
    CsrfToken(csrf_token) -> json.string(csrf_token)
    Users(users) -> json.array(users, encode_user)
    PaginationProp(pagination) -> encode_pagination(pagination)
    UserProp(user) -> encode_user(user)
    Success(success) -> json.string(success)
    Errors(errors) -> encode_validation_errors(errors)
  }
}

pub type CreateUserRequest {
  CreateUserRequest(name: String, email: String, token: String)
}

pub fn create_user_request_decoder() -> decode.Decoder(CreateUserRequest) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use token <- decode.field("_token", decode.string)
  decode.success(CreateUserRequest(name:, email:, token:))
}

pub type EditUserRequest {
  EditUserRequest(id: Int, name: String, email: String)
}

pub fn edit_user_request_decoder(id: Int) -> decode.Decoder(EditUserRequest) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  decode.success(EditUserRequest(id:, name:, email:))
}
