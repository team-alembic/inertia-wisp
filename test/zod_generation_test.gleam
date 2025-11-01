import gleam/string
import inertia_wisp/schema

pub type User {
  User(id: Int, name: String, email: String)
}

pub fn user_schema() -> schema.RecordSchema(_) {
  schema.record_schema("User")
  |> schema.field("id", schema.IntType)
  |> schema.field("name", schema.StringType)
  |> schema.field("email", schema.StringType)
  |> schema.schema()
}

pub fn simple_record_to_zod_test() {
  let zod_code = schema.to_zod_schema(user_schema())

  // Should contain schema export
  assert string.contains(zod_code, "export const UserSchema")

  // Should contain z.object
  assert string.contains(zod_code, "z.object({")

  // Should contain fields with correct types
  assert string.contains(zod_code, "id: z.number()")
  assert string.contains(zod_code, "name: z.string()")
  assert string.contains(zod_code, "email: z.string()")

  // Should have strict mode
  assert string.contains(zod_code, ".strict()")

  // Should contain type export
  assert string.contains(zod_code, "export type User")
  assert string.contains(zod_code, "z.infer<typeof UserSchema>")
}

pub type TaggedItem {
  TaggedItem(id: Int, tags: List(String), scores: List(Int))
}

pub fn tagged_item_schema() -> schema.RecordSchema(_) {
  schema.record_schema("TaggedItem")
  |> schema.decode_into(TaggedItem(id: 0, tags: [], scores: []))
  |> schema.field("id", schema.IntType)
  |> schema.field("tags", schema.ListType(schema.StringType))
  |> schema.field("scores", schema.ListType(schema.IntType))
  |> schema.schema()
}

pub fn list_fields_to_zod_test() {
  let zod_code = schema.to_zod_schema(tagged_item_schema())

  // Should contain array types
  assert string.contains(zod_code, "tags: z.array(z.string())")
  assert string.contains(zod_code, "scores: z.array(z.number())")
  assert string.contains(zod_code, "export const TaggedItemSchema")
  assert string.contains(zod_code, "export type TaggedItem")
}

pub type Address {
  Address(street: String, city: String)
}

pub type Person {
  Person(name: String, address: Address)
}

pub fn address_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Address")
  |> schema.field("street", schema.StringType)
  |> schema.field("city", schema.StringType)
  |> schema.schema()
}

pub fn person_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Person")
  |> schema.decode_into(Person(name: "", address: Address(street: "", city: "")))
  |> schema.field("name", schema.StringType)
  |> schema.field("address", schema.RecordType(address_schema))
  |> schema.schema()
}

pub fn nested_record_to_zod_test() {
  let zod_code = schema.to_zod_schema(person_schema())

  // Should reference the nested schema
  assert string.contains(zod_code, "address: AddressSchema")
  assert string.contains(zod_code, "export const PersonSchema")
  assert string.contains(zod_code, "export type Person")
}

pub type Team {
  Team(name: String, members: List(Person))
}

pub fn team_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Team")
  |> schema.field("name", schema.StringType)
  |> schema.field("members", schema.ListType(schema.RecordType(person_schema)))
  |> schema.schema()
}

pub fn list_of_nested_records_to_zod_test() {
  let zod_code = schema.to_zod_schema(team_schema())

  // Should generate array of nested schema references
  assert string.contains(zod_code, "members: z.array(PersonSchema)")
  assert string.contains(zod_code, "export const TeamSchema")
  assert string.contains(zod_code, "export type Team")
}

pub type Grid {
  Grid(data: List(List(Int)))
}

pub fn grid_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Grid")
  |> schema.field("data", schema.ListType(schema.ListType(schema.IntType)))
  |> schema.schema()
}

pub fn nested_lists_to_zod_test() {
  let zod_code = schema.to_zod_schema(grid_schema())

  // Should generate nested arrays
  assert string.contains(zod_code, "data: z.array(z.array(z.number()))")
  assert string.contains(zod_code, "export const GridSchema")
}
