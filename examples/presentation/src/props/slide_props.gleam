//// Props for slide pages
////
//// This module defines props for rendering presentation slides and provides
//// JSON serialization for all slide content.

import gleam/json.{type Json}
import inertia_wisp/prop.{type Prop, AlwaysProp, DefaultProp}
import slides/content

/// Prop types for slide pages
pub type SlideProp {
  SlideContent(content.Slide)
  Navigation(content.SlideNavigation)
  PresentationTitle(String)
}

/// Convert a SlideProp to JSON
pub fn slide_prop_to_json(slide_prop: SlideProp) -> Json {
  case slide_prop {
    SlideContent(slide) -> encode_slide(slide)
    Navigation(nav) -> encode_navigation(nav)
    PresentationTitle(title) -> json.string(title)
  }
}

// Factory functions for creating Prop(SlideProp) instances

/// Create a slide content prop (DefaultProp)
pub fn slide_content(slide: content.Slide) -> Prop(SlideProp) {
  DefaultProp("slide", SlideContent(slide))
}

/// Create a navigation prop (AlwaysProp)
pub fn navigation(nav: content.SlideNavigation) -> Prop(SlideProp) {
  AlwaysProp("navigation", Navigation(nav))
}

/// Create a presentation title prop (AlwaysProp)
pub fn presentation_title(title: String) -> Prop(SlideProp) {
  AlwaysProp("presentation_title", PresentationTitle(title))
}

/// Encode a complete slide to JSON
fn encode_slide(slide: content.Slide) -> Json {
  json.object([
    #("number", json.int(slide.number)),
    #("title", json.string(slide.title)),
    #("content", json.array(slide.content, encode_content_block)),
    #("notes", json.string(slide.notes)),
  ])
}

/// Encode navigation information to JSON
fn encode_navigation(nav: content.SlideNavigation) -> Json {
  json.object([
    #("current", json.int(nav.current)),
    #("total", json.int(nav.total)),
    #("has_previous", json.bool(nav.has_previous)),
    #("has_next", json.bool(nav.has_next)),
    #("previous_url", json.string(nav.previous_url)),
    #("next_url", json.string(nav.next_url)),
  ])
}

/// Encode a content block to JSON
fn encode_content_block(block: content.ContentBlock) -> Json {
  case block {
    content.Heading(text) ->
      json.object([
        #("type", json.string("heading")),
        #("text", json.string(text)),
      ])

    content.Subheading(text) ->
      json.object([
        #("type", json.string("subheading")),
        #("text", json.string(text)),
      ])

    content.Paragraph(text) ->
      json.object([
        #("type", json.string("paragraph")),
        #("text", json.string(text)),
      ])

    content.CodeBlock(code, language, highlight_lines) ->
      json.object([
        #("type", json.string("code")),
        #("code", json.string(code)),
        #("language", json.string(language)),
        #("highlight_lines", json.array(highlight_lines, json.int)),
      ])

    content.BulletList(items) ->
      json.object([
        #("type", json.string("bullet_list")),
        #("items", json.array(items, json.string)),
      ])

    content.NumberedList(items) ->
      json.object([
        #("type", json.string("numbered_list")),
        #("items", json.array(items, json.string)),
      ])

    content.Quote(text, author) ->
      json.object([
        #("type", json.string("quote")),
        #("text", json.string(text)),
        #("author", json.string(author)),
      ])

    content.Image(url, alt, width) ->
      json.object([
        #("type", json.string("image")),
        #("url", json.string(url)),
        #("alt", json.string(alt)),
        #("width", json.int(width)),
      ])

    content.ImageRow(images) ->
      json.object([
        #("type", json.string("image_row")),
        #("images", json.array(images, encode_image_data)),
      ])

    content.Columns(left, right) ->
      json.object([
        #("type", json.string("columns")),
        #("left", json.array(left, encode_content_block)),
        #("right", json.array(right, encode_content_block)),
      ])

    content.Spacer -> json.object([#("type", json.string("spacer"))])
  }
}

/// Encode image data to JSON
fn encode_image_data(image: content.ImageData) -> json.Json {
  json.object([
    #("url", json.string(image.url)),
    #("alt", json.string(image.alt)),
    #("width", json.int(image.width)),
  ])
}
