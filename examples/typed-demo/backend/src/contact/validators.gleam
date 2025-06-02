import shared/validation

// ===== CONTACT-SPECIFIC VALIDATION =====

pub fn validate_contact_name(name: String) -> Result(Nil, #(String, String)) {
  validation.validate_name(name)
}

pub fn validate_contact_email(email: String) -> Result(Nil, #(String, String)) {
  validation.validate_email(email)
}

pub fn validate_subject(subject: String) -> Result(Nil, #(String, String)) {
  validation.validate_required_text("Subject", subject, 3, 200)
}

pub fn validate_message(message: String) -> Result(Nil, #(String, String)) {
  validation.validate_required_text("Message", message, 10, 2000)
}

// Validate complete contact form request
pub fn validate_contact_form_request(name: String, email: String, subject: String, message: String) -> validation.ValidationErrors {
  validation.collect_validation_errors([
    validate_contact_name(name),
    validate_contact_email(email),
    validate_subject(subject),
    validate_message(message),
  ])
}