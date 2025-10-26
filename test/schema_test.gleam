import gleam/dynamic/decode
import gleam/json
import gleam/string
import inertia_wisp/schema

pub type User {
  User(id: Int, name: String, email: String)
}

pub fn user_schema() -> schema.RecordSchema(_) {
  schema.record_schema("User", User(id: 0, name: "", email: ""))
  |> schema.field("id", schema.IntType)
  |> schema.field("name", schema.StringType)
  |> schema.field("email", schema.StringType)
  |> schema.schema()
}

pub fn schema_encodes_to_json_test() {
  let s = user_schema()
  let user = User(id: 42, name: "Alice", email: "alice@example.com")

  let result = schema.to_json(s, user)
  let json_string = json.to_string(result)

  // Verify JSON structure contains expected fields (order independent)
  assert string.contains(json_string, "\"id\":42")
  assert string.contains(json_string, "\"name\":\"Alice\"")
  assert string.contains(json_string, "\"email\":\"alice@example.com\"")
}

pub fn schema_decodes_from_dynamic_test() {
  let s = user_schema()

  // Create a dynamic value that represents JSON-like data
  let json_data =
    json.object([
      #("id", json.int(99)),
      #("name", json.string("Bob")),
      #("email", json.string("bob@example.com")),
    ])

  // Convert to string and parse back to dynamic
  let json_string = json.to_string(json_data)
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)

  // Decode using schema
  let assert Ok(decoded_user) = schema.decode(s, parsed)
  let user: User = decoded_user

  assert user.id == 99
  assert user.name == "Bob"
  assert user.email == "bob@example.com"
}

pub fn schema_round_trip_test() {
  let s = user_schema()
  let original = User(id: 42, name: "Alice", email: "alice@example.com")

  // Encode to JSON
  let json_data = schema.to_json(s, original)

  // Convert to string and parse back to dynamic
  let json_string = json.to_string(json_data)
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)

  // Decode back to User
  let assert Ok(decoded) = schema.decode(s, parsed)
  let user: User = decoded

  // Should match original
  assert user.id == original.id
  assert user.name == original.name
  assert user.email == original.email
}

pub type UserWithTags {
  UserWithTags(id: Int, name: String, tags: List(String))
}

pub fn user_with_tags_schema() -> schema.RecordSchema(_) {
  schema.record_schema("UserWithTags", UserWithTags(id: 0, name: "", tags: []))
  |> schema.field("id", schema.IntType)
  |> schema.field("name", schema.StringType)
  |> schema.field("tags", schema.ListType(schema.StringType))
  |> schema.schema()
}

pub fn schema_decodes_list_of_strings_test() {
  let s = user_with_tags_schema()

  let json_data =
    json.object([
      #("id", json.int(1)),
      #("name", json.string("Alice")),
      #("tags", json.array(["rust", "gleam", "typescript"], json.string)),
    ])

  let json_string = json.to_string(json_data)
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)

  let assert Ok(decoded) = schema.decode(s, parsed)
  let user: UserWithTags = decoded

  assert user.id == 1
  assert user.name == "Alice"
  assert user.tags == ["rust", "gleam", "typescript"]
}

pub fn schema_encodes_list_of_strings_test() {
  let s = user_with_tags_schema()
  let user = UserWithTags(id: 1, name: "Bob", tags: ["admin", "moderator"])

  let json_data = schema.to_json(s, user)
  let json_string = json.to_string(json_data)

  assert string.contains(json_string, "\"id\":1")
  assert string.contains(json_string, "\"name\":\"Bob\"")
  assert string.contains(json_string, "\"admin\"")
  assert string.contains(json_string, "\"moderator\"")
}

pub type NumberGrid {
  NumberGrid(rows: List(List(Int)))
}

pub fn number_grid_schema() -> schema.RecordSchema(_) {
  schema.record_schema("NumberGrid", NumberGrid(rows: []))
  |> schema.field("rows", schema.ListType(schema.ListType(schema.IntType)))
  |> schema.schema()
}

pub fn schema_decodes_nested_lists_test() {
  let s = number_grid_schema()

  let json_data =
    json.object([
      #(
        "rows",
        json.array(
          [
            json.array([1, 2, 3], json.int),
            json.array([4, 5, 6], json.int),
            json.array([7, 8, 9], json.int),
          ],
          fn(x) { x },
        ),
      ),
    ])

  let json_string = json.to_string(json_data)
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)

  let assert Ok(decoded) = schema.decode(s, parsed)
  let grid: NumberGrid = decoded

  assert grid.rows == [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
}

pub fn schema_round_trip_nested_lists_test() {
  let s = number_grid_schema()
  let original = NumberGrid(rows: [[1, 2], [3, 4], [5, 6]])

  let json_data = schema.to_json(s, original)
  let json_string = json.to_string(json_data)
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)

  let assert Ok(decoded) = schema.decode(s, parsed)
  let grid: NumberGrid = decoded

  assert grid.rows == original.rows
}
