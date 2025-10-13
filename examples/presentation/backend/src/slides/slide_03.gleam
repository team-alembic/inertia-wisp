//// Slide 3: About Me
////
//// Introduction to the presenter

import shared/content.{
  type Slide, BulletList, Heading, Paragraph, Slide, Spacer, Subheading,
}

pub fn slide() -> Slide {
  Slide(
    number: 3,
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
