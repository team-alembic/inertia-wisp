//// Slide content types for the presentation
////
//// This module defines the content structure for presentation slides.
//// All content is provided by the backend, with the frontend acting as
//// a generic rendering engine.

import gleam/int

/// Image data for ImageRow
pub type ImageData {
  ImageData(url: String, alt: String, width: Int)
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

/// Complete slide definition with all content
pub type Slide {
  Slide(number: Int, title: String, content: List(ContentBlock), notes: String)
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
