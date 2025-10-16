//// Slide 4: The Pitch for Inertia-Wisp
////
//// Main value proposition of the framework

import schemas/content.{type Slide, Heading, Paragraph, Slide, Spacer}

pub fn slide() -> Slide {
  Slide(
    number: 4,
    title: "The Pitch for Inertia-Wisp",
    content: [
      Heading("The Pitch for Inertia-Wisp"),
      Spacer,
      Paragraph("The Frontend You Know"),
      Paragraph("The Backend You'll Love"),
      Paragraph("With Type-Safe Integration"),
    ],
    notes: "The core value proposition - combining familiar frontend tech with powerful backend capabilities through type-safe integration",
    max_steps: 1,
  )
}
