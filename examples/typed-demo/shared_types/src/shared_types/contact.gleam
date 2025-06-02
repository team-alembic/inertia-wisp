import gleam/dynamic/decode
import gleam/json
import gleam/option
import inertia_wisp/inertia

// ===== PROPS TYPES (with encoders) =====

pub type ContactPageProps {
  ContactPageProps(title: String, message: String)
}

pub fn encode_contact_page_props(props: ContactPageProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
  ])
}

/// Zero value for Contact Page Props
pub const zero_contact_page_props = ContactPageProps(
  title: "",
  message: "",
)

@target(erlang)
/// Use Contact Page Props for the current InertiaJS handler
pub fn with_contact_page_props(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> inertia.InertiaContext(ContactPageProps) {
  ctx
  |> inertia.set_props(zero_contact_page_props, encode_contact_page_props)
}

//prop assignment functions. Generates tuples for use with inertia.assign_prop_t
pub fn title(t: String) {
  #("title", fn(p) { ContactPageProps(..p, title: t) })
}

pub fn message(m: String) {
  #("message", fn(p) { ContactPageProps(..p, message: m) })
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