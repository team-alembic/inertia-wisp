import inertia_wisp/schema
import schemas/content_block.{type ContentBlock}

/// Complete slide definition with all content
pub type Slide {
  Slide(
    number: Int,
    title: String,
    content: List(ContentBlock),
    notes: String,
    max_steps: Int,
  )
}

/// Schema for Slide type
pub fn slide_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Slide")
  |> schema.int_field("number")
  |> schema.string_field("title")
  |> schema.list_field(
    "content",
    schema.VariantType(content_block.content_block_schema),
  )
  |> schema.string_field("notes")
  |> schema.int_field("max_steps")
  |> schema.schema()
}

pub fn to_json(slide: Slide) {
  schema.to_json(slide_schema(), slide)
}

/// Set the slide number (used when retrieving slides in order)
pub fn set_number(slide: Slide, number: Int) -> Slide {
  Slide(..slide, number: number)
}
