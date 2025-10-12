//// Slide 2: Acknowledgments
////
//// Acknowledging Alembic for supporting this work

import slides/content.{type Slide, Heading, Image, Paragraph, Spacer}

pub fn slide() -> Slide {
  content.Slide(
    number: 2,
    title: "Acknowledgments",
    content: [
      Heading("Acknowledgments"),
      Spacer,
      Image("/static/images/alembic-logo.png", "Alembic Logo", 300),
      Paragraph("Thank you to Alembic for supporting this work!"),
      Spacer,
      Paragraph("alembic.com.au"),
    ],
    notes: "Acknowledgments slide - thanking Alembic for their support",
  )
}
