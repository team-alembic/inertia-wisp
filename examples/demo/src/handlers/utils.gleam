import gleam/int
import shared_types/auth
import wisp

pub fn require_int(
  param: String,
  cont: fn(Int) -> wisp.Response,
) -> wisp.Response {
  case int.parse(param) {
    Ok(value) -> cont(value)
    Error(_) -> wisp.not_found()
  }
}

/// Get common auth value
pub fn get_demo_auth() -> auth.Auth {
  auth.authenticated_user("demo_user")
}

/// Get common CSRF token
pub fn get_csrf_token() -> String {
  "abc123xyz"
}
