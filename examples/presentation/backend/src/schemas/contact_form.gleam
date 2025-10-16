//// Contact form schema definition
////
//// This module defines the ContactFormData type and its schema for encoding/decoding.
//// The schema is used to generate TypeScript/Zod schemas for the frontend.

import inertia_wisp/schema

/// Contact form submission data
pub type ContactFormData {
  ContactFormData(name: String, email: String, message: String)
}

/// Schema for ContactFormData type
pub fn contact_form_data_schema() -> schema.RecordSchema {
  schema.record_schema(
    "ContactFormData",
    ContactFormData(name: "", email: "", message: ""),
  )
  |> schema.string_field("name", fn(f: ContactFormData) { f.name }, fn(f, name) {
    ContactFormData(..f, name:)
  })
  |> schema.string_field(
    "email",
    fn(f: ContactFormData) { f.email },
    fn(f, email) { ContactFormData(..f, email:) },
  )
  |> schema.string_field(
    "message",
    fn(f: ContactFormData) { f.message },
    fn(f, message) { ContactFormData(..f, message:) },
  )
  |> schema.schema()
}
