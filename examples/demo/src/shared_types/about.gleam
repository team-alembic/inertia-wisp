import gleam/json
import shared_types/auth

// ===== PROPS TYPES (with encoders) =====

pub type AboutPageProp {
  Auth(auth: auth.Auth)
  CsrfToken(csrf_token: String)
  PageTitle(page_title: String)
  Description(description: String)
}

pub fn encode_about_page_prop(prop: AboutPageProp) -> json.Json {
  case prop {
    Auth(auth_val) -> auth.encode_auth(auth_val)
    CsrfToken(csrf_token) -> json.string(csrf_token)
    PageTitle(page_title) -> json.string(page_title)
    Description(description) -> json.string(description)
  }
}