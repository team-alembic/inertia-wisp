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
pub fn user_schema() -> schema.RecordSchema {
  schema.record_schema("User", User(id: 0, name: "", email: ""))
  |> schema.field("id", schema.IntType, fn(u: User) { u.id }, fn(u, id) {
    User(..u, id: id)
  })
  |> schema.field(
    "name",
    schema.StringType,
    fn(u: User) { u.name },
    fn(u, name) { User(..u, name: name) },
  )
  |> schema.field(
    "email",
    schema.StringType,
    fn(u: User) { u.email },
    fn(u, email) { User(..u, email: email) },
  )
  |> schema.schema()
}
