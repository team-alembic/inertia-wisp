//// Slide content types for the presentation
////
//// This module defines the content structure for presentation slides.
//// All content is provided by the backend, with the frontend acting as
//// a generic rendering engine.

import gleam/dynamic/decode
import gleam/int
import gleam/json

/// Image data for ImageRow
pub type ImageData {
  ImageData(url: String, alt: String, width: Int)
}

pub fn image_data_to_json(image_data: ImageData) -> json.Json {
  let ImageData(url:, alt:, width:) = image_data
  json.object([
    #("url", json.string(url)),
    #("alt", json.string(alt)),
    #("width", json.int(width)),
  ])
}

pub fn image_data_decoder() -> decode.Decoder(ImageData) {
  use url <- decode.field("url", decode.string)
  use alt <- decode.field("alt", decode.string)
  use width <- decode.field("width", decode.int)
  decode.success(ImageData(url:, alt:, width:))
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
  Spacer
}

pub fn content_block_to_json(content_block: ContentBlock) -> json.Json {
  case content_block {
    Heading(text:) ->
      json.object([
        #("type", json.string("heading")),
        #("text", json.string(text)),
      ])
    Subheading(text:) ->
      json.object([
        #("type", json.string("subheading")),
        #("text", json.string(text)),
      ])
    Paragraph(text:) ->
      json.object([
        #("type", json.string("paragraph")),
        #("text", json.string(text)),
      ])
    CodeBlock(code:, language:, highlight_lines:) ->
      json.object([
        #("type", json.string("code_block")),
        #("code", json.string(code)),
        #("language", json.string(language)),
        #("highlight_lines", json.array(highlight_lines, json.int)),
      ])
    BulletList(items:) ->
      json.object([
        #("type", json.string("bullet_list")),
        #("items", json.array(items, json.string)),
      ])
    NumberedList(items:) ->
      json.object([
        #("type", json.string("numbered_list")),
        #("items", json.array(items, json.string)),
      ])
    Quote(text:, author:) ->
      json.object([
        #("type", json.string("quote")),
        #("text", json.string(text)),
        #("author", json.string(author)),
      ])
    Image(url:, alt:, width:) ->
      json.object([
        #("type", json.string("image")),
        #("url", json.string(url)),
        #("alt", json.string(alt)),
        #("width", json.int(width)),
      ])
    ImageRow(images:) ->
      json.object([
        #("type", json.string("image_row")),
        #("images", json.array(images, image_data_to_json)),
      ])
    Columns(left:, right:) ->
      json.object([
        #("type", json.string("columns")),
        #("left", json.array(left, content_block_to_json)),
        #("right", json.array(right, content_block_to_json)),
      ])
    Spacer ->
      json.object([
        #("type", json.string("spacer")),
      ])
  }
}

pub fn content_block_decoder() -> decode.Decoder(ContentBlock) {
  use variant <- decode.field("type", decode.string)
  case variant {
    "heading" -> {
      use text <- decode.field("text", decode.string)
      decode.success(Heading(text:))
    }
    "subheading" -> {
      use text <- decode.field("text", decode.string)
      decode.success(Subheading(text:))
    }
    "paragraph" -> {
      use text <- decode.field("text", decode.string)
      decode.success(Paragraph(text:))
    }
    "code_block" -> {
      use code <- decode.field("code", decode.string)
      use language <- decode.field("language", decode.string)
      use highlight_lines <- decode.field(
        "highlight_lines",
        decode.list(decode.int),
      )
      decode.success(CodeBlock(code:, language:, highlight_lines:))
    }
    "bullet_list" -> {
      use items <- decode.field("items", decode.list(decode.string))
      decode.success(BulletList(items:))
    }
    "numbered_list" -> {
      use items <- decode.field("items", decode.list(decode.string))
      decode.success(NumberedList(items:))
    }
    "quote" -> {
      use text <- decode.field("text", decode.string)
      use author <- decode.field("author", decode.string)
      decode.success(Quote(text:, author:))
    }
    "image" -> {
      use url <- decode.field("url", decode.string)
      use alt <- decode.field("alt", decode.string)
      use width <- decode.field("width", decode.int)
      decode.success(Image(url:, alt:, width:))
    }
    "image_row" -> {
      use images <- decode.field("images", decode.list(image_data_decoder()))
      decode.success(ImageRow(images:))
    }
    "columns" -> {
      use left <- decode.field("left", decode.list(content_block_decoder()))
      use right <- decode.field("right", decode.list(content_block_decoder()))
      decode.success(Columns(left:, right:))
    }
    "spacer" -> decode.success(Spacer)
    _ -> decode.failure(Spacer, "ContentBlock")
  }
}

/// Complete slide definition with all content
pub type Slide {
  Slide(number: Int, title: String, content: List(ContentBlock), notes: String)
}

pub fn slide_to_json(slide: Slide) -> json.Json {
  let Slide(number:, title:, content:, notes:) = slide
  json.object([
    #("number", json.int(number)),
    #("title", json.string(title)),
    #("content", json.array(content, content_block_to_json)),
    #("notes", json.string(notes)),
  ])
}

pub fn slide_decoder() -> decode.Decoder(Slide) {
  use number <- decode.field("number", decode.int)
  use title <- decode.field("title", decode.string)
  use content <- decode.field("content", decode.list(content_block_decoder()))
  use notes <- decode.field("notes", decode.string)
  decode.success(Slide(number:, title:, content:, notes:))
}

/// Navigation information for a slide
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

pub fn slide_navigation_to_json(slide_navigation: SlideNavigation) -> json.Json {
  let SlideNavigation(
    current:,
    total:,
    has_previous:,
    has_next:,
    previous_url:,
    next_url:,
  ) = slide_navigation
  json.object([
    #("current", json.int(current)),
    #("total", json.int(total)),
    #("has_previous", json.bool(has_previous)),
    #("has_next", json.bool(has_next)),
    #("previous_url", json.string(previous_url)),
    #("next_url", json.string(next_url)),
  ])
}

pub fn slide_navigation_decoder() -> decode.Decoder(SlideNavigation) {
  use current <- decode.field("current", decode.int)
  use total <- decode.field("total", decode.int)
  use has_previous <- decode.field("has_previous", decode.bool)
  use has_next <- decode.field("has_next", decode.bool)
  use previous_url <- decode.field("previous_url", decode.string)
  use next_url <- decode.field("next_url", decode.string)
  decode.success(SlideNavigation(
    current:,
    total:,
    has_previous:,
    has_next:,
    previous_url:,
    next_url:,
  ))
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
