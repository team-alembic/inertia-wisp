import gleam/io
import gleam/string
import gleeunit/should
import inertia_wisp/schema

pub type User {
  User(id: Int, name: String, email: String)
}

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

pub fn simple_record_to_zod_test() {
  let zod_code = schema.to_zod_schema(user_schema())

  // Should contain schema export
  zod_code |> string.contains("export const UserSchema") |> should.be_true()

  // Should contain z.object
  zod_code |> string.contains("z.object({") |> should.be_true()

  // Should contain fields with correct types
  zod_code |> string.contains("id: z.number()") |> should.be_true()
  zod_code |> string.contains("name: z.string()") |> should.be_true()
  zod_code |> string.contains("email: z.string()") |> should.be_true()

  // Should have strict mode
  zod_code |> string.contains(".strict()") |> should.be_true()

  // Should contain type export
  zod_code |> string.contains("export type User") |> should.be_true()
  zod_code |> string.contains("z.infer<typeof UserSchema>") |> should.be_true()
}

pub type TaggedItem {
  TaggedItem(id: Int, tags: List(String), scores: List(Int))
}

pub fn tagged_item_schema() -> schema.RecordSchema {
  schema.record_schema("TaggedItem", TaggedItem(id: 0, tags: [], scores: []))
  |> schema.field("id", schema.IntType, fn(t: TaggedItem) { t.id }, fn(t, id) {
    TaggedItem(..t, id: id)
  })
  |> schema.field(
    "tags",
    schema.ListType(schema.StringType),
    fn(t: TaggedItem) { t.tags },
    fn(t, tags) { TaggedItem(..t, tags: tags) },
  )
  |> schema.field(
    "scores",
    schema.ListType(schema.IntType),
    fn(t: TaggedItem) { t.scores },
    fn(t, scores) { TaggedItem(..t, scores: scores) },
  )
  |> schema.schema()
}

pub fn list_fields_to_zod_test() {
  let zod_code = schema.to_zod_schema(tagged_item_schema())

  // Should contain array types
  zod_code
  |> string.contains("tags: z.array(z.string())")
  |> should.be_true()

  zod_code
  |> string.contains("scores: z.array(z.number())")
  |> should.be_true()

  zod_code
  |> string.contains("export const TaggedItemSchema")
  |> should.be_true()

  zod_code |> string.contains("export type TaggedItem") |> should.be_true()
}

pub type Address {
  Address(street: String, city: String)
}

pub type Person {
  Person(name: String, address: Address)
}

pub fn address_schema() -> schema.RecordSchema {
  schema.record_schema("Address", Address(street: "", city: ""))
  |> schema.field(
    "street",
    schema.StringType,
    fn(a: Address) { a.street },
    fn(a, s) { Address(..a, street: s) },
  )
  |> schema.field(
    "city",
    schema.StringType,
    fn(a: Address) { a.city },
    fn(a, c) { Address(..a, city: c) },
  )
  |> schema.schema()
}

pub fn person_schema() -> schema.RecordSchema {
  schema.record_schema(
    "Person",
    Person(name: "", address: Address(street: "", city: "")),
  )
  |> schema.field("name", schema.StringType, fn(p: Person) { p.name }, fn(p, n) {
    Person(..p, name: n)
  })
  |> schema.field(
    "address",
    schema.RecordType(address_schema),
    fn(p: Person) { p.address },
    fn(p, a) { Person(..p, address: a) },
  )
  |> schema.schema()
}

pub fn nested_record_to_zod_test() {
  let zod_code = schema.to_zod_schema(person_schema())

  // Should reference the nested schema
  zod_code |> string.contains("address: AddressSchema") |> should.be_true()

  zod_code |> string.contains("export const PersonSchema") |> should.be_true()
  zod_code |> string.contains("export type Person") |> should.be_true()
}

pub type Team {
  Team(name: String, members: List(Person))
}

pub fn team_schema() -> schema.RecordSchema {
  schema.record_schema("Team", Team(name: "", members: []))
  |> schema.field("name", schema.StringType, fn(t: Team) { t.name }, fn(t, n) {
    Team(..t, name: n)
  })
  |> schema.field(
    "members",
    schema.ListType(schema.RecordType(person_schema)),
    fn(t: Team) { t.members },
    fn(t, m) { Team(..t, members: m) },
  )
  |> schema.schema()
}

pub fn list_of_nested_records_to_zod_test() {
  let zod_code = schema.to_zod_schema(team_schema())

  // Should generate array of nested schema references
  zod_code
  |> string.contains("members: z.array(PersonSchema)")
  |> should.be_true()

  zod_code |> string.contains("export const TeamSchema") |> should.be_true()
  zod_code |> string.contains("export type Team") |> should.be_true()
}

pub type Grid {
  Grid(data: List(List(Int)))
}

pub fn grid_schema() -> schema.RecordSchema {
  schema.record_schema("Grid", Grid(data: []))
  |> schema.field(
    "data",
    schema.ListType(schema.ListType(schema.IntType)),
    fn(g: Grid) { g.data },
    fn(g, d) { Grid(data: d) },
  )
  |> schema.schema()
}

pub fn nested_lists_to_zod_test() {
  let zod_code = schema.to_zod_schema(grid_schema())

  // Should generate nested arrays
  zod_code
  |> string.contains("data: z.array(z.array(z.number()))")
  |> should.be_true()

  zod_code |> string.contains("export const GridSchema") |> should.be_true()
}

pub fn print_zod_examples_test() {
  io.println("\n========== User Schema (Simple) ==========")
  io.println(schema.to_zod_schema(user_schema()))

  io.println("\n========== TaggedItem Schema (With Lists) ==========")
  io.println(schema.to_zod_schema(tagged_item_schema()))

  io.println("\n========== Address Schema ==========")
  io.println(schema.to_zod_schema(address_schema()))

  io.println("\n========== Person Schema (Nested Record) ==========")
  io.println(schema.to_zod_schema(person_schema()))

  io.println("\n========== Team Schema (List of Nested Records) ==========")
  io.println(schema.to_zod_schema(team_schema()))

  io.println("\n========== Grid Schema (Nested Lists) ==========")
  io.println(schema.to_zod_schema(grid_schema()))

  io.println("\n==========================================\n")

  // Test always passes - this is just for visual inspection
  True |> should.be_true()
}
