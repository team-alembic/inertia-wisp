import gleam/dynamic/decode
import gleam/json
import gleeunit/should
import inertia_wisp/schema

pub type TaggedItem {
  TaggedItem(tags: List(String))
}

pub fn tagged_item_schema() -> schema.RecordSchema {
  schema.record_schema("TaggedItem", TaggedItem(tags: []))
  |> schema.field(
    "tags",
    schema.ListType(schema.StringType),
    fn(item: TaggedItem) { item.tags },
    fn(item, tags) { TaggedItem(..item, tags: tags) },
  )
  |> schema.schema()
}

pub fn list_of_strings_decodes_test() {
  let s = tagged_item_schema()

  let json_data =
    json.object([
      #("tags", json.array(["a", "b", "c"], json.string)),
    ])

  let json_string = json.to_string(json_data)
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)

  let assert Ok(decoded) = schema.decode(s, parsed)
  let item: TaggedItem = decoded

  item.tags |> should.equal(["a", "b", "c"])
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
    fn(g, data) { Grid(data: data) },
  )
  |> schema.schema()
}

pub fn nested_list_decodes_test() {
  let s = grid_schema()

  let json_data =
    json.object([
      #(
        "data",
        json.array(
          [
            json.array([1, 2], json.int),
            json.array([3, 4], json.int),
          ],
          fn(x) { x },
        ),
      ),
    ])

  let json_string = json.to_string(json_data)
  let assert Ok(parsed) = json.parse(json_string, decode.dynamic)

  let assert Ok(decoded) = schema.decode(s, parsed)
  let grid: Grid = decoded

  grid.data |> should.equal([[1, 2], [3, 4]])
}
