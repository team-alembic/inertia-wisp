import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/string
import inertia_wisp/schema

pub type Address {
  Address(street: String, city: String, zip: String)
}

pub type Person {
  Person(name: String, age: Int, address: Address)
}

pub fn address_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Address")
  |> schema.decode_into(Address(street: "", city: "", zip: ""))
  |> schema.field("street", schema.StringType)
  |> schema.field("city", schema.StringType)
  |> schema.field("zip", schema.StringType)
  |> schema.schema()
}

pub fn person_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Person")
  |> schema.decode_into(Person(
    name: "",
    age: 0,
    address: Address(street: "", city: "", zip: ""),
  ))
  |> schema.field("name", schema.StringType)
  |> schema.field("age", schema.IntType)
  |> schema.field("address", schema.RecordType(address_schema))
  |> schema.schema()
}

pub fn nested_record_encodes_test() {
  let s = person_schema()
  let person =
    Person(
      name: "Alice",
      age: 30,
      address: Address(street: "123 Main St", city: "Springfield", zip: "12345"),
    )

  let json_data = schema.to_json(s, person)
  let json_string = json.to_string(json_data)

  // Verify top-level fields
  assert string.contains(json_string, "\"name\":\"Alice\"")
  assert string.contains(json_string, "\"age\":30")

  // Verify nested address fields
  assert string.contains(json_string, "\"street\":\"123 Main St\"")
  assert string.contains(json_string, "\"city\":\"Springfield\"")
  assert string.contains(json_string, "\"zip\":\"12345\"")
}

pub fn nested_record_decodes_test() {
  let s = person_schema()

  let json_data =
    json.object([
      #("name", json.string("Bob")),
      #("age", json.int(25)),
      #(
        "address",
        json.object([
          #("street", json.string("456 Elm St")),
          #("city", json.string("Shelbyville")),
          #("zip", json.string("54321")),
        ]),
      ),
    ])

  let json_string = json.to_string(json_data)
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)

  let assert Ok(decoded) = schema.decode(s, parsed)
  let person: Person = decoded

  assert person.name == "Bob"
  assert person.age == 25
  assert person.address.street == "456 Elm St"
  assert person.address.city == "Shelbyville"
  assert person.address.zip == "54321"
}

pub fn nested_record_round_trip_test() {
  let s = person_schema()
  let original =
    Person(
      name: "Charlie",
      age: 35,
      address: Address(
        street: "789 Oak Ave",
        city: "Capital City",
        zip: "99999",
      ),
    )

  // Encode
  let json_data = schema.to_json(s, original)
  let json_string = json.to_string(json_data)

  // Decode
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)
  let assert Ok(decoded) = schema.decode(s, parsed)
  let person: Person = decoded

  // Verify everything matches
  assert person.name == original.name
  assert person.age == original.age
  assert person.address.street == original.address.street
  assert person.address.city == original.address.city
  assert person.address.zip == original.address.zip
}

pub type Company {
  Company(name: String, employees: List(Person))
}

pub fn company_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Company")
  |> schema.decode_into(Company(name: "", employees: []))
  |> schema.field("name", schema.StringType)
  |> schema.field(
    "employees",
    schema.ListType(schema.RecordType(person_schema)),
  )
  |> schema.schema()
}

pub fn list_of_nested_records_test() {
  let s = company_schema()

  let company =
    Company(name: "Acme Corp", employees: [
      Person(
        name: "Alice",
        age: 30,
        address: Address(street: "123 Main", city: "NYC", zip: "10001"),
      ),
      Person(
        name: "Bob",
        age: 25,
        address: Address(street: "456 Elm", city: "LA", zip: "90001"),
      ),
    ])

  // Encode
  let json_data = schema.to_json(s, company)
  let json_string = json.to_string(json_data)

  // Verify structure
  assert string.contains(json_string, "\"name\":\"Acme Corp\"")
  assert string.contains(json_string, "\"Alice\"")
  assert string.contains(json_string, "\"Bob\"")

  // Decode
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)
  let assert Ok(decoded) = schema.decode(s, parsed)
  let decoded_company: Company = decoded

  assert decoded_company.name == "Acme Corp"
  assert list.length(decoded_company.employees) == 2

  let assert [emp1, emp2] = decoded_company.employees
  assert emp1.name == "Alice"
  assert emp1.age == 30
  assert emp2.name == "Bob"
  assert emp2.age == 25
}
