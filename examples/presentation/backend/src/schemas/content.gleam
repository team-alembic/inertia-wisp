//// Content schemas for presentation slides
////
//// This module defines schemas for slide content types.
//// Note: ContentBlock (variant type) not yet migrated - waiting for variant support.

import gleam/int

import inertia_wisp/schema

/// Image data for ImageRow
pub type ImageData {
  ImageData(url: String, alt: String, width: Int)
}

/// Schema for ImageData type
pub fn image_data_schema() -> schema.RecordSchema {
  schema.record_schema("ImageData", ImageData(url: "", alt: "", width: 0))
  |> schema.field(
    "url",
    schema.StringType,
    fn(img: ImageData) { img.url },
    fn(img, url) { ImageData(..img, url: url) },
  )
  |> schema.field(
    "alt",
    schema.StringType,
    fn(img: ImageData) { img.alt },
    fn(img, alt) { ImageData(..img, alt: alt) },
  )
  |> schema.field(
    "width",
    schema.IntType,
    fn(img: ImageData) { img.width },
    fn(img, width) { ImageData(..img, width: width) },
  )
  |> schema.schema()
}

/// ManualNavigation information for a slide
pub type SlideNavigation {
  SlideNavigation(
    current: Int,
    total: Int,
    has_previous: Bool,
    has_next: Bool,
    previous_url: String,
    next_url: String,
  )
}

/// Schema for SlideNavigation type
pub fn slide_navigation_schema() -> schema.RecordSchema {
  schema.record_schema(
    "SlideNavigation",
    SlideNavigation(
      current: 0,
      total: 0,
      has_previous: False,
      has_next: False,
      previous_url: "",
      next_url: "",
    ),
  )
  |> schema.field(
    "current",
    schema.IntType,
    fn(nav: SlideNavigation) { nav.current },
    fn(nav, current) { SlideNavigation(..nav, current: current) },
  )
  |> schema.field(
    "total",
    schema.IntType,
    fn(nav: SlideNavigation) { nav.total },
    fn(nav, total) { SlideNavigation(..nav, total: total) },
  )
  |> schema.field(
    "has_previous",
    schema.BoolType,
    fn(nav: SlideNavigation) { nav.has_previous },
    fn(nav, has_previous) { SlideNavigation(..nav, has_previous: has_previous) },
  )
  |> schema.field(
    "has_next",
    schema.BoolType,
    fn(nav: SlideNavigation) { nav.has_next },
    fn(nav, has_next) { SlideNavigation(..nav, has_next: has_next) },
  )
  |> schema.field(
    "previous_url",
    schema.StringType,
    fn(nav: SlideNavigation) { nav.previous_url },
    fn(nav, previous_url) { SlideNavigation(..nav, previous_url: previous_url) },
  )
  |> schema.field(
    "next_url",
    schema.StringType,
    fn(nav: SlideNavigation) { nav.next_url },
    fn(nav, next_url) { SlideNavigation(..nav, next_url: next_url) },
  )
  |> schema.schema()
}

/// Helper to create navigation info
pub fn navigation(current: Int, total: Int) -> SlideNavigation {
  let has_previous = current > 1
  let has_next = current < total
  let previous_url = case has_previous {
    True -> "/slides/" <> int.to_string(current - 1)
    False -> "#"
  }
  let next_url = case has_next {
    True -> "/slides/" <> int.to_string(current + 1)
    False -> "#"
  }

  SlideNavigation(
    current: current,
    total: total,
    has_previous: has_previous,
    has_next: has_next,
    previous_url: previous_url,
    next_url: next_url,
  )
}

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
  |> schema.field(
    "text",
    schema.StringType,
    fn(block) {
      let assert Heading(text) = block
      text
    },
    fn(_block, text) { Heading(text: text) },
  )
  |> schema.schema()
}

fn subheading_record_schema() -> schema.RecordSchema {
  schema.record_schema("Subheading", Subheading(text: ""))
  |> schema.field(
    "text",
    schema.StringType,
    fn(block) {
      let assert Subheading(text) = block
      text
    },
    fn(_block, text) { Subheading(text: text) },
  )
  |> schema.schema()
}

fn paragraph_record_schema() -> schema.RecordSchema {
  schema.record_schema("Paragraph", Paragraph(text: ""))
  |> schema.field(
    "text",
    schema.StringType,
    fn(block) {
      let assert Paragraph(text) = block
      text
    },
    fn(_block, text) { Paragraph(text: text) },
  )
  |> schema.schema()
}

fn code_block_record_schema() -> schema.RecordSchema {
  schema.record_schema(
    "CodeBlock",
    CodeBlock(code: "", language: "", highlight_lines: []),
  )
  |> schema.field(
    "code",
    schema.StringType,
    fn(block) {
      let assert CodeBlock(code, _, _) = block
      code
    },
    fn(block, code) {
      let assert CodeBlock(_, language, highlight_lines) = block
      CodeBlock(
        code: code,
        language: language,
        highlight_lines: highlight_lines,
      )
    },
  )
  |> schema.field(
    "language",
    schema.StringType,
    fn(block) {
      let assert CodeBlock(_, language, _) = block
      language
    },
    fn(block, language) {
      let assert CodeBlock(code, _, highlight_lines) = block
      CodeBlock(
        code: code,
        language: language,
        highlight_lines: highlight_lines,
      )
    },
  )
  |> schema.field(
    "highlight_lines",
    schema.ListType(schema.IntType),
    fn(block) {
      let assert CodeBlock(_, _, highlight_lines) = block
      highlight_lines
    },
    fn(block, highlight_lines) {
      let assert CodeBlock(code, language, _) = block
      CodeBlock(
        code: code,
        language: language,
        highlight_lines: highlight_lines,
      )
    },
  )
  |> schema.schema()
}

fn bullet_list_record_schema() -> schema.RecordSchema {
  schema.record_schema("BulletList", BulletList(items: []))
  |> schema.field(
    "items",
    schema.ListType(schema.StringType),
    fn(block) {
      let assert BulletList(items) = block
      items
    },
    fn(_block, items) { BulletList(items: items) },
  )
  |> schema.schema()
}

fn numbered_list_record_schema() -> schema.RecordSchema {
  schema.record_schema("NumberedList", NumberedList(items: []))
  |> schema.field(
    "items",
    schema.ListType(schema.StringType),
    fn(block) {
      let assert NumberedList(items) = block
      items
    },
    fn(_block, items) { NumberedList(items: items) },
  )
  |> schema.schema()
}

fn quote_record_schema() -> schema.RecordSchema {
  schema.record_schema("Quote", Quote(text: "", author: ""))
  |> schema.field(
    "text",
    schema.StringType,
    fn(block) {
      let assert Quote(text, _) = block
      text
    },
    fn(block, text) {
      let assert Quote(_, author) = block
      Quote(text: text, author: author)
    },
  )
  |> schema.field(
    "author",
    schema.StringType,
    fn(block) {
      let assert Quote(_, author) = block
      author
    },
    fn(block, author) {
      let assert Quote(text, _) = block
      Quote(text: text, author: author)
    },
  )
  |> schema.schema()
}

fn image_record_schema() -> schema.RecordSchema {
  schema.record_schema("Image", Image(url: "", alt: "", width: 0))
  |> schema.field(
    "url",
    schema.StringType,
    fn(block) {
      let assert Image(url, _, _) = block
      url
    },
    fn(block, url) {
      let assert Image(_, alt, width) = block
      Image(url: url, alt: alt, width: width)
    },
  )
  |> schema.field(
    "alt",
    schema.StringType,
    fn(block) {
      let assert Image(_, alt, _) = block
      alt
    },
    fn(block, alt) {
      let assert Image(url, _, width) = block
      Image(url: url, alt: alt, width: width)
    },
  )
  |> schema.field(
    "width",
    schema.IntType,
    fn(block) {
      let assert Image(_, _, width) = block
      width
    },
    fn(block, width) {
      let assert Image(url, alt, _) = block
      Image(url: url, alt: alt, width: width)
    },
  )
  |> schema.schema()
}

fn image_row_record_schema() -> schema.RecordSchema {
  schema.record_schema("ImageRow", ImageRow(images: []))
  |> schema.field(
    "images",
    schema.ListType(schema.RecordType(image_data_schema)),
    fn(block) {
      let assert ImageRow(images) = block
      images
    },
    fn(_block, images) { ImageRow(images: images) },
  )
  |> schema.schema()
}

fn columns_record_schema() -> schema.RecordSchema {
  schema.record_schema("Columns", Columns(left: [], right: []))
  |> schema.field(
    "left",
    schema.ListType(schema.VariantType(content_block_schema)),
    fn(block) {
      let assert Columns(left, _) = block
      left
    },
    fn(block, left) {
      let assert Columns(_, right) = block
      Columns(left: left, right: right)
    },
  )
  |> schema.field(
    "right",
    schema.ListType(schema.VariantType(content_block_schema)),
    fn(block) {
      let assert Columns(_, right) = block
      right
    },
    fn(block, right) {
      let assert Columns(left, _) = block
      Columns(left: left, right: right)
    },
  )
  |> schema.schema()
}

fn link_button_record_schema() -> schema.RecordSchema {
  schema.record_schema("LinkButton", LinkButton(text: "", href: ""))
  |> schema.field(
    "text",
    schema.StringType,
    fn(block) {
      let assert LinkButton(text, _) = block
      text
    },
    fn(block, text) {
      let assert LinkButton(_, href) = block
      LinkButton(text: text, href: href)
    },
  )
  |> schema.field(
    "href",
    schema.StringType,
    fn(block) {
      let assert LinkButton(_, href) = block
      href
    },
    fn(block, href) {
      let assert LinkButton(text, _) = block
      LinkButton(text: text, href: href)
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
  |> schema.field(
    "number",
    schema.IntType,
    fn(slide) { slide.number },
    fn(slide, number) { Slide(..slide, number: number) },
  )
  |> schema.field(
    "title",
    schema.StringType,
    fn(slide) { slide.title },
    fn(slide, title) { Slide(..slide, title: title) },
  )
  |> schema.field(
    "content",
    schema.ListType(schema.VariantType(content_block_schema)),
    fn(slide) { slide.content },
    fn(slide, content) { Slide(..slide, content: content) },
  )
  |> schema.field(
    "notes",
    schema.StringType,
    fn(slide) { slide.notes },
    fn(slide, notes) { Slide(..slide, notes: notes) },
  )
  |> schema.field(
    "max_steps",
    schema.IntType,
    fn(slide) { slide.max_steps },
    fn(slide, max_steps) { Slide(..slide, max_steps: max_steps) },
  )
  |> schema.schema()
}
