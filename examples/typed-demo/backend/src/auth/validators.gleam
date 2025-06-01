import shared/validation

// ===== AUTH-SPECIFIC VALIDATION =====

pub fn validate_login_email(email: String) -> Result(Nil, #(String, String)) {
  validation.validate_email(email)
}

pub fn validate_login_password(
  password: String,
) -> Result(Nil, #(String, String)) {
  validation.validate_password(password)
}

// Check actual credentials (mock implementation)
pub fn check_credentials(
  email: String,
  password: String,
) -> Result(Nil, #(String, String)) {
  case email == "demo@example.com" && password == "password123" {
    True -> Ok(Nil)
    False -> Error(#("password", "Is incorrect"))
  }
}

// Validate complete login request
pub fn validate_login_credentials(
  email: String,
  password: String,
) -> validation.ValidationErrors {
  validation.collect_validation_errors([
    validate_login_email(email),
    validate_login_password(password),
    check_credentials(email, password),
  ])
}
