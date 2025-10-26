//// Slide 3: About Me
////
//// Introduction to the presenter

import schemas/content_block.{BulletList, Heading, Paragraph, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide() -> Slide {
  Slide(
    number: 0,
    title: "About Me",
    content: [
      Heading("About Me"),
      Spacer,
      Subheading("Michael Buhot"),
      Paragraph("Engineering Manager @ Alembic"),
      Spacer,
      BulletList([
        "Functional programming fan from Brisbane, Australia",
        "Default stack is Elixir, Ash, Phoenix LiveView",
        "Excited about Gleam, typed FP on the BEAM",
        "Exploring coding assistants",
      ]),
    ],
    notes: "Introduction to Michael Buhot - background in functional programming, Elixir, and interest in Gleam and AI assistants",
    max_steps: 1,
  )
}
