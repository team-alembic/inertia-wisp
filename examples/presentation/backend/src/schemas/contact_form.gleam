//// Contact form schema definition
////
//// This module defines the ContactFormData type and its schema for encoding/decoding.
//// The schema is used to generate TypeScript/Zod schemas for the frontend.

import gleam/dynamic
import inertia_wisp/schema

/// Contact form submission data
pub type ContactFormData {
  ContactFormData(name: String, email: String, message: String)
}

/// Schema for ContactFormData type
pub fn contact_form_data_schema() -> schema.RecordSchema(ContactFormData) {
  schema.record_schema(
    "ContactFormData",
    ContactFormData(name: "", email: "", message: ""),
  )
  |> schema.string_field("name")
  |> schema.string_field("email")
  |> schema.string_field("message")
  |> schema.schema()
}

/// Decode form data from JSON using schema
pub fn decode(json_data: dynamic.Dynamic) -> Result(ContactFormData, String) {
  schema.decode(contact_form_data_schema(), json_data)
}
