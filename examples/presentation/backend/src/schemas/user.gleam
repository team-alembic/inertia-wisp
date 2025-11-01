//// User schema definition
////
//// This module defines the User type and its schema for encoding/decoding.
//// The schema is used to generate TypeScript/Zod schemas for the frontend.

import inertia_wisp/schema

/// User data
pub type User {
  User(id: Int, name: String, email: String)
}

/// Schema for User type
pub fn user_schema() -> schema.RecordSchema(_) {
  schema.record_schema("User")
  |> schema.int_field("id")
  |> schema.string_field("name")
  |> schema.string_field("email")
  |> schema.schema()
}
