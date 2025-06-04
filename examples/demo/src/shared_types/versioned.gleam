import gleam/json
import shared_types/auth

// ===== PROPS TYPES (with encoders) =====

pub type VersionedPageProp {
  Auth(auth: auth.Auth)
  CsrfToken(csrf_token: String)
  Version(version: String)
  BuildInfo(build_info: String)
}

pub fn encode_versioned_page_prop(prop: VersionedPageProp) -> json.Json {
  case prop {
    Auth(auth_val) -> auth.encode_auth(auth_val)
    CsrfToken(csrf_token) -> json.string(csrf_token)
    Version(version) -> json.string(version)
    BuildInfo(build_info) -> json.string(build_info)
  }
}