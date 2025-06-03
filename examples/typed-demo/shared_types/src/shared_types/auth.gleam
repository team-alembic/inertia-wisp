import gleam/dynamic/decode
import gleam/json
import gleam/option

// ===== PROPS TYPES (with encoders) =====

pub type LoginPageProp {
  Title(title: String)
  Message(message: String)
  DemoInfo(demo_info: List(String))
}

/// Login Page Props JSON encoder
pub fn encode_login_page_prop(prop: LoginPageProp) -> json.Json {
  case prop {
    Title(value) -> json.string(value)
    Message(value) -> json.string(value)
    DemoInfo(value) -> json.array(value, json.string)
  }
}

// ===== REQUEST TYPES (with decoders) =====

pub type LoginRequest {
  LoginRequest(
    email: String,
    password: String,
    remember_me: option.Option(Bool),
  )
}

pub fn login_request_decoder() -> decode.Decoder(LoginRequest) {
  use email <- decode.field("email", decode.string)
  use password <- decode.field("password", decode.string)
  use remember_me <- decode.optional_field(
    "remember_me",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(LoginRequest(email:, password:, remember_me:))
}
