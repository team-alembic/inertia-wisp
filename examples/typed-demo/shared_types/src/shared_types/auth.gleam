import gleam/dynamic/decode
import gleam/json
import gleam/option
import inertia_wisp/inertia

// ===== PROPS TYPES (with encoders) =====

/// Login Page Props type
pub type LoginPageProps {
  LoginPageProps(title: String, message: String, demo_info: List(String))
}

/// Login Page Props JSON encoder
pub fn encode_login_page_props(props: LoginPageProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
    #("demo_info", json.array(props.demo_info, json.string)),
  ])
}

/// Zero value for Login Page Props
pub const zero_login_page_props = LoginPageProps(
  title: "",
  message: "",
  demo_info: [],
)

@target(erlang)
/// Use Login Page Props for the current InertiaJS handler
pub fn with_login_page_props(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> inertia.InertiaContext(LoginPageProps) {
  ctx
  |> inertia.set_props(zero_login_page_props, encode_login_page_props)
}

//prop assignment functions. Generates tuples for use with inertia.assign_prop_t
pub fn title(t: String) {
  #("title", fn(p) { LoginPageProps(..p, title: t) })
}

pub fn message(m: String) {
  #("message", fn(p) { LoginPageProps(..p, message: m) })
}

pub fn demo_info(f: fn() -> List(String)) {
  #("demo_info", fn(p) { LoginPageProps(..p, demo_info: f()) })
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
