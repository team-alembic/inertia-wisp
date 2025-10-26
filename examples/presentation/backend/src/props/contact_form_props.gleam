//// Props for contact form page
////
//// This module defines props for the contact form and provides
//// JSON serialization.

import gleam/json
import inertia_wisp/page_schema
import inertia_wisp/prop
import inertia_wisp/schema

/// Prop types for contact form page
pub type ContactFormProp {
  NameProp(String)
  EmailProp(String)
  MessageProp(String)
}

/// Page schema for ContactForm page
pub fn contact_form_page_schema() -> page_schema.PageSchema {
  page_schema.page_schema("ContactForm")
  |> page_schema.prop("name", schema.StringType)
  |> page_schema.prop("email", schema.StringType)
  |> page_schema.prop("message", schema.StringType)
  |> page_schema.build()
}

/// Helper to create name prop
pub fn name(value: String) -> prop.Prop(ContactFormProp) {
  prop.DefaultProp("name", NameProp(value))
}

/// Helper to create email prop
pub fn email(value: String) -> prop.Prop(ContactFormProp) {
  prop.DefaultProp("email", EmailProp(value))
}

/// Helper to create message prop
pub fn message(value: String) -> prop.Prop(ContactFormProp) {
  prop.DefaultProp("message", MessageProp(value))
}

/// JSON encoder for contact form props
pub fn contact_form_prop_to_json(prop: ContactFormProp) -> json.Json {
  case prop {
    NameProp(value) -> json.string(value)
    EmailProp(value) -> json.string(value)
    MessageProp(value) -> json.string(value)
  }
}
