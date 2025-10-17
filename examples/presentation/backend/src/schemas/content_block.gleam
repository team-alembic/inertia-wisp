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
fn heading_record_schema() -> schema.RecordSchema {
  schema.record_schema("Heading", Heading(text: ""))
  |> schema.string_field(
    "text",
    fn(block) {
      let assert Heading(text) = block
      text
    },
    fn(_block, text) { Heading(text:) },
  )
  |> schema.schema()
}

fn subheading_record_schema() -> schema.RecordSchema {
  schema.record_schema("Subheading", Subheading(text: ""))
  |> schema.string_field(
    "text",
    fn(block) {
      let assert Subheading(text) = block
      text
    },
    fn(_block, text) { Subheading(text:) },
  )
  |> schema.schema()
}

fn paragraph_record_schema() -> schema.RecordSchema {
  schema.record_schema("Paragraph", Paragraph(text: ""))
  |> schema.string_field(
    "text",
    fn(block) {
      let assert Paragraph(text) = block
      text
    },
    fn(_block, text) { Paragraph(text:) },
  )
  |> schema.schema()
}

fn code_block_record_schema() -> schema.RecordSchema {
  schema.record_schema(
    "CodeBlock",
    CodeBlock(code: "", language: "", highlight_lines: []),
  )
  |> schema.string_field(
    "code",
    fn(block) {
      let assert CodeBlock(code, _, _) = block
      code
    },
    fn(block, code) {
      let assert CodeBlock(_, language, highlight_lines) = block
      CodeBlock(code:, language:, highlight_lines:)
    },
  )
  |> schema.string_field(
    "language",
    fn(block) {
      let assert CodeBlock(_, language, _) = block
      language
    },
    fn(block, language) {
      let assert CodeBlock(code, _, highlight_lines) = block
      CodeBlock(code:, language:, highlight_lines:)
    },
  )
  |> schema.list_field(
    "highlight_lines",
    schema.IntType,
    fn(block) {
      let assert CodeBlock(_, _, highlight_lines) = block
      highlight_lines
    },
    fn(block, highlight_lines) {
      let assert CodeBlock(code, language, _) = block
      CodeBlock(code:, language:, highlight_lines:)
    },
  )
  |> schema.schema()
}

fn bullet_list_record_schema() -> schema.RecordSchema {
  schema.record_schema("BulletList", BulletList(items: []))
  |> schema.list_field(
    "items",
    schema.StringType,
    fn(block) {
      let assert BulletList(items) = block
      items
    },
    fn(_block, items) { BulletList(items:) },
  )
  |> schema.schema()
}

fn numbered_list_record_schema() -> schema.RecordSchema {
  schema.record_schema("NumberedList", NumberedList(items: []))
  |> schema.list_field(
    "items",
    schema.StringType,
    fn(block) {
      let assert NumberedList(items) = block
      items
    },
    fn(_block, items) { NumberedList(items:) },
  )
  |> schema.schema()
}

fn quote_record_schema() -> schema.RecordSchema {
  schema.record_schema("Quote", Quote(text: "", author: ""))
  |> schema.string_field(
    "text",
    fn(block) {
      let assert Quote(text, _) = block
      text
    },
    fn(block, text) {
      let assert Quote(_, author) = block
      Quote(text:, author:)
    },
  )
  |> schema.string_field(
    "author",
    fn(block) {
      let assert Quote(_, author) = block
      author
    },
    fn(block, author) {
      let assert Quote(text, _) = block
      Quote(text:, author:)
    },
  )
  |> schema.schema()
}

fn image_record_schema() -> schema.RecordSchema {
  schema.record_schema("Image", Image(url: "", alt: "", width: 0))
  |> schema.string_field(
    "url",
    fn(block) {
      let assert Image(url, _, _) = block
      url
    },
    fn(block, url) {
      let assert Image(_, alt, width) = block
      Image(url:, alt:, width:)
    },
  )
  |> schema.string_field(
    "alt",
    fn(block) {
      let assert Image(_, alt, _) = block
      alt
    },
    fn(block, alt) {
      let assert Image(url, _, width) = block
      Image(url:, alt:, width:)
    },
  )
  |> schema.int_field(
    "width",
    fn(block) {
      let assert Image(_, _, width) = block
      width
    },
    fn(block, width) {
      let assert Image(url, alt, _) = block
      Image(url:, alt:, width:)
    },
  )
  |> schema.schema()
}

fn image_row_record_schema() -> schema.RecordSchema {
  schema.record_schema("ImageRow", ImageRow(images: []))
  |> schema.list_field(
    "images",
    schema.RecordType(image_data.image_data_schema),
    fn(block) {
      let assert ImageRow(images) = block
      images
    },
    fn(_block, images) { ImageRow(images:) },
  )
  |> schema.schema()
}

fn columns_record_schema() -> schema.RecordSchema {
  schema.record_schema("Columns", Columns(left: [], right: []))
  |> schema.list_field(
    "left",
    schema.VariantType(content_block_schema),
    fn(block) {
      let assert Columns(left, _) = block
      left
    },
    fn(block, left) {
      let assert Columns(_, right) = block
      Columns(left:, right:)
    },
  )
  |> schema.list_field(
    "right",
    schema.VariantType(content_block_schema),
    fn(block) {
      let assert Columns(_, right) = block
      right
    },
    fn(block, right) {
      let assert Columns(left, _) = block
      Columns(left:, right:)
    },
  )
  |> schema.schema()
}

fn link_button_record_schema() -> schema.RecordSchema {
  schema.record_schema("LinkButton", LinkButton(text: "", href: ""))
  |> schema.string_field(
    "text",
    fn(block) {
      let assert LinkButton(text, _) = block
      text
    },
    fn(block, text) {
      let assert LinkButton(_, href) = block
      LinkButton(text:, href:)
    },
  )
  |> schema.string_field(
    "href",
    fn(block) {
      let assert LinkButton(_, href) = block
      href
    },
    fn(block, href) {
      let assert LinkButton(text, _) = block
      LinkButton(text:, href:)
    },
  )
  |> schema.schema()
}

fn spacer_record_schema() -> schema.RecordSchema {
  schema.record_schema("Spacer", Spacer)
  |> schema.schema()
}

/// Schema for ContentBlock variant type
pub fn content_block_schema() -> schema.VariantSchema {
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
    schema.VariantType(content_block_schema),
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
