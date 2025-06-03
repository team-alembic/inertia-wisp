import gleam/dynamic/decode
import gleam/json
import gleam/option

// ===== PROPS TYPES (with encoders) =====

pub type ContactPageProp {
  Title(title: String)
  Message(message: String)
}

pub fn encode_contact_page_prop(prop: ContactPageProp) -> json.Json {
  case prop {
    Title(title) -> json.string(title)
    Message(message) -> json.string(message)
  }
}

// ===== REQUEST TYPES (with decoders) =====

pub type ContactFormRequest {
  ContactFormRequest(
    name: String,
    email: String,
    subject: String,
    message: String,
    urgent: option.Option(Bool),
  )
}

pub fn contact_form_request_decoder() -> decode.Decoder(ContactFormRequest) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use subject <- decode.field("subject", decode.string)
  use message <- decode.field("message", decode.string)
  use urgent <- decode.optional_field(
    "urgent",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(ContactFormRequest(name:, email:, subject:, message:, urgent:))
}

pub fn contact_form_request_zero() -> ContactFormRequest {
  ContactFormRequest(
    name: "",
    email: "",
    subject: "",
    message: "",
    urgent: option.None,
  )
}