//// Props for contact form page
////
//// This module defines props for the contact form and provides
//// JSON serialization using the v2 API with generic types.

import gleam/dict
import gleam/json
import inertia_wisp/page_schema
import inertia_wisp/schema

/// Props structure for contact form page (v2 API)
pub type ContactFormProps {
  ContactFormProps(name: String, email: String, message: String)
}

/// Page schema for ContactForm page
pub fn contact_form_page_schema() -> page_schema.PageSchema {
  page_schema.page_schema("ContactForm")
  |> page_schema.prop("name", schema.StringType)
  |> page_schema.prop("email", schema.StringType)
  |> page_schema.prop("message", schema.StringType)
  |> page_schema.build()
}

/// JSON encoder for contact form props (v2 API)
/// Returns a Dict for efficient field filtering
pub fn encode(props: ContactFormProps) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("name", json.string(props.name)),
    #("email", json.string(props.email)),
    #("message", json.string(props.message)),
  ])
}
