//// Slide 2: Acknowledgments
////
//// Acknowledging Alembic for supporting this work

import schemas/content_block.{BulletList, CodeBlock, Columns, Heading, Image, ImageRow, LinkButton, NumberedList, Paragraph, Quote, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide() -> Slide {
  Slide(
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
    max_steps: 1,
  )
}
