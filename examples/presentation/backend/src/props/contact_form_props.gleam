//// Props for contact form page
////
//// This module defines props for the contact form and provides
//// JSON serialization using the v2 API with generic types.

import gleam/dict
import gleam/json
import inertia_wisp/schema

pub type ContactFormProps {
  ContactFormProps(name: String, email: String, message: String)
}

/// Record schema for ContactForm props
pub fn contact_form_props_schema() -> schema.RecordSchema(ContactFormProps) {
  schema.record_schema("ContactFormPageProps")
  |> schema.string_field("name")
  |> schema.string_field("email")
  |> schema.string_field("message")
  |> schema.schema()
}

/// JSON encoder for contact form props
pub fn encode(props: ContactFormProps) -> dict.Dict(String, json.Json) {
  schema.to_json_dict(contact_form_props_schema(), props)
}
