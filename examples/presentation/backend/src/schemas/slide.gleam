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
pub fn slide_schema() -> schema.RecordSchema {
  schema.record_schema(
    "Slide",
    Slide(number: 0, title: "", content: [], notes: "", max_steps: 1),
  )
  |> schema.int_field("number", fn(slide) { slide.number }, fn(slide, number) {
    Slide(..slide, number:)
  })
  |> schema.string_field("title", fn(slide) { slide.title }, fn(slide, title) {
    Slide(..slide, title:)
  })
  |> schema.list_field(
    "content",
    schema.VariantType(content_block.content_block_schema),
    fn(slide) { slide.content },
    fn(slide, content) { Slide(..slide, content:) },
  )
  |> schema.string_field("notes", fn(slide) { slide.notes }, fn(slide, notes) {
    Slide(..slide, notes:)
  })
  |> schema.int_field(
    "max_steps",
    fn(slide) { slide.max_steps },
    fn(slide, max_steps) { Slide(..slide, max_steps:) },
  )
  |> schema.schema()
}

pub fn to_json(slide: Slide) {
  schema.to_json(slide_schema(), slide)
}
