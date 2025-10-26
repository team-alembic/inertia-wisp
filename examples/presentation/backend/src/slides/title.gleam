//// Slide 1: Title Slide
////
//// Introduction to the presentation

import schemas/content_block.{Heading, Paragraph, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide() -> Slide {
  Slide(
    number: 0,
    title: "Gleam + TypeScript",
    content: [
      Heading("Gleam + TypeScript"),
      Subheading("Full-Stack Type Safety With Inertia-Wisp"),
      Spacer,
      Paragraph("Michael Buhot"),
    ],
    notes: "Title slide - introducing the presentation on building full-stack type-safe applications with Gleam and TypeScript using Inertia-Wisp",
    max_steps: 1,
  )
}
