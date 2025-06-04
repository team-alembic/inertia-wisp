import gleam/json

// ===== DOMAIN TYPES =====

pub type Auth {
  Auth(authenticated: Bool, user: String)
}

pub fn encode_auth(auth: Auth) -> json.Json {
  json.object([
    #("authenticated", json.bool(auth.authenticated)),
    #("user", json.string(auth.user)),
  ])
}

/// Helper function to create an authenticated Auth value
pub fn authenticated_user(user: String) -> Auth {
  Auth(authenticated: True, user: user)
}

/// Helper function to create an unauthenticated Auth value
pub fn unauthenticated_user() -> Auth {
  Auth(authenticated: False, user: "")
}
