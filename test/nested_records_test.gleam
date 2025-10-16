import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/string
import gleeunit/should
import inertia_wisp/schema

pub type Address {
  Address(street: String, city: String, zip: String)
}

pub type Person {
  Person(name: String, age: Int, address: Address)
}

pub fn address_schema() -> schema.RecordSchema {
  schema.record_schema("Address", Address(street: "", city: "", zip: ""))
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
  |> schema.field("zip", schema.StringType, fn(a: Address) { a.zip }, fn(a, z) {
    Address(..a, zip: z)
  })
  |> schema.schema()
}

pub fn person_schema() -> schema.RecordSchema {
  schema.record_schema(
    "Person",
    Person(name: "", age: 0, address: Address(street: "", city: "", zip: "")),
  )
  |> schema.field("name", schema.StringType, fn(p: Person) { p.name }, fn(p, n) {
    Person(..p, name: n)
  })
  |> schema.field("age", schema.IntType, fn(p: Person) { p.age }, fn(p, a) {
    Person(..p, age: a)
  })
  |> schema.field(
    "address",
    schema.RecordType(address_schema),
    fn(p: Person) { p.address },
    fn(p, addr) { Person(..p, address: addr) },
  )
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
  json_string |> string.contains("\"name\":\"Alice\"") |> should.be_true()
  json_string |> string.contains("\"age\":30") |> should.be_true()

  // Verify nested address fields
  json_string
  |> string.contains("\"street\":\"123 Main St\"")
  |> should.be_true()
  json_string |> string.contains("\"city\":\"Springfield\"") |> should.be_true()
  json_string |> string.contains("\"zip\":\"12345\"") |> should.be_true()
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

  person.name |> should.equal("Bob")
  person.age |> should.equal(25)
  person.address.street |> should.equal("456 Elm St")
  person.address.city |> should.equal("Shelbyville")
  person.address.zip |> should.equal("54321")
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
  person.name |> should.equal(original.name)
  person.age |> should.equal(original.age)
  person.address.street |> should.equal(original.address.street)
  person.address.city |> should.equal(original.address.city)
  person.address.zip |> should.equal(original.address.zip)
}

pub type Company {
  Company(name: String, employees: List(Person))
}

pub fn company_schema() -> schema.RecordSchema {
  schema.record_schema("Company", Company(name: "", employees: []))
  |> schema.field(
    "name",
    schema.StringType,
    fn(c: Company) { c.name },
    fn(c, n) { Company(..c, name: n) },
  )
  |> schema.field(
    "employees",
    schema.ListType(schema.RecordType(person_schema)),
    fn(c: Company) { c.employees },
    fn(c, emps) { Company(..c, employees: emps) },
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
  json_string |> string.contains("\"name\":\"Acme Corp\"") |> should.be_true()
  json_string |> string.contains("\"Alice\"") |> should.be_true()
  json_string |> string.contains("\"Bob\"") |> should.be_true()

  // Decode
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)
  let assert Ok(decoded) = schema.decode(s, parsed)
  let decoded_company: Company = decoded

  decoded_company.name |> should.equal("Acme Corp")
  decoded_company.employees |> list.length() |> should.equal(2)

  let assert [emp1, emp2] = decoded_company.employees
  emp1.name |> should.equal("Alice")
  emp1.age |> should.equal(30)
  emp2.name |> should.equal("Bob")
  emp2.age |> should.equal(25)
}
