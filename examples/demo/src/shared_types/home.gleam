import gleam/json
import shared_types/auth

// ===== PROPS TYPES (with encoders) =====

pub type HomePageProp {
  Auth(auth: auth.Auth)
  CsrfToken(csrf_token: String)
  Message(message: String)
  Timestamp(timestamp: String)
  UserCount(user_count: Int)
}

pub fn encode_home_page_prop(prop: HomePageProp) -> json.Json {
  case prop {
    Auth(auth) -> auth.encode_auth(auth)
    CsrfToken(csrf_token) -> json.string(csrf_token)
    Message(message) -> json.string(message)
    Timestamp(timestamp) -> json.string(timestamp)
    UserCount(user_count) -> json.int(user_count)
  }
}