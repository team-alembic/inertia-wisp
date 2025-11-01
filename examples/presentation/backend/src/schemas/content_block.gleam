//// Content schemas for presentation slides
////
//// This module defines schemas for slide content types.
//// Note: ContentBlock (variant type) not yet migrated - waiting for variant support.

import inertia_wisp/schema
import schemas/image_data.{type ImageData}

/// Content block types for slides
pub type ContentBlock {
  Heading(text: String)
  Subheading(text: String)
  Paragraph(text: String)
  CodeBlock(code: String, language: String, highlight_lines: List(Int))
  BulletList(items: List(String))
  NumberedList(items: List(String))
  Quote(text: String, author: String)
  Image(url: String, alt: String, width: Int)
  ImageRow(images: List(ImageData))
  Columns(left: List(ContentBlock), right: List(ContentBlock))
  LinkButton(text: String, href: String)
  Spacer
}

/// Tagger function for ContentBlock variants
fn content_block_tagger(block: ContentBlock) -> String {
  case block {
    Heading(_) -> "heading"
    Subheading(_) -> "subheading"
    Paragraph(_) -> "paragraph"
    CodeBlock(_, _, _) -> "code_block"
    BulletList(_) -> "bullet_list"
    NumberedList(_) -> "numbered_list"
    Quote(_, _) -> "quote"
    Image(_, _, _) -> "image"
    ImageRow(_) -> "image_row"
    Columns(_, _) -> "columns"
    LinkButton(_, _) -> "link_button"
    Spacer -> "spacer"
  }
}

/// Helper schemas for each ContentBlock variant case
fn heading_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Heading")
  |> schema.string_field("text")
  |> schema.schema()
}

fn subheading_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Subheading")
  |> schema.string_field("text")
  |> schema.schema()
}

fn paragraph_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Paragraph")
  |> schema.string_field("text")
  |> schema.schema()
}

fn code_block_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("CodeBlock")
  |> schema.string_field("code")
  |> schema.string_field("language")
  |> schema.list_field("highlight_lines", schema.IntType)
  |> schema.schema()
}

fn bullet_list_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("BulletList")
  |> schema.list_field("items", schema.StringType)
  |> schema.schema()
}

fn numbered_list_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("NumberedList")
  |> schema.list_field("items", schema.StringType)
  |> schema.schema()
}

fn quote_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Quote")
  |> schema.string_field("text")
  |> schema.string_field("author")
  |> schema.schema()
}

fn image_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Image")
  |> schema.string_field("url")
  |> schema.string_field("alt")
  |> schema.int_field("width")
  |> schema.schema()
}

fn image_row_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("ImageRow")
  |> schema.list_field(
    "images",
    schema.RecordType(image_data.image_data_schema),
  )
  |> schema.schema()
}

fn columns_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Columns")
  |> schema.list_field("left", schema.VariantType(content_block_schema))
  |> schema.list_field("right", schema.VariantType(content_block_schema))
  |> schema.schema()
}

fn link_button_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("LinkButton")
  |> schema.string_field("text")
  |> schema.string_field("href")
  |> schema.schema()
}

fn spacer_record_schema() -> schema.RecordSchema(_) {
  schema.record_schema("Spacer")
  |> schema.schema()
}

/// Schema for ContentBlock variant type
pub fn content_block_schema() -> schema.VariantSchema(_) {
  schema.variant_schema("ContentBlock", content_block_tagger)
  |> schema.variant_case("heading", heading_record_schema())
  |> schema.variant_case("subheading", subheading_record_schema())
  |> schema.variant_case("paragraph", paragraph_record_schema())
  |> schema.variant_case("code_block", code_block_record_schema())
  |> schema.variant_case("bullet_list", bullet_list_record_schema())
  |> schema.variant_case("numbered_list", numbered_list_record_schema())
  |> schema.variant_case("quote", quote_record_schema())
  |> schema.variant_case("image", image_record_schema())
  |> schema.variant_case("image_row", image_row_record_schema())
  |> schema.variant_case("columns", columns_record_schema())
  |> schema.variant_case("link_button", link_button_record_schema())
  |> schema.variant_case("spacer", spacer_record_schema())
  |> schema.variant_schema_done()
}
