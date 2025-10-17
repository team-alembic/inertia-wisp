//// Slide 15: Forms & Validation
////
//// Introduction to forms and validation with Inertia.js

import schemas/content_block.{BulletList, CodeBlock, Columns, Heading, Image, ImageRow, LinkButton, NumberedList, Paragraph, Quote, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide() -> Slide {
  Slide(
    number: 15,
    title: "Forms & Validation",
    content: [
      Heading("Forms & Validation"),
      Subheading("Using the useForm Hook"),
      Spacer,
      BulletList([
        "Form state management with useForm hook",
        "Backend validation with detailed error messages",
        "Inline error display for better UX",
        "Full type safety from frontend to backend",
        "Standard Inertia error handling patterns",
      ]),
      Spacer,
      Paragraph(
        "Click the button below to try the interactive demo, then return to continue the presentation.",
      ),
      Spacer,
      LinkButton("Try the Contact Form Demo →", "/forms/contact"),
    ],
    notes: "This slide introduces form handling in Inertia-Wisp. The demo shows a contact form with name, email, and message fields. Validation happens on the backend and errors are displayed inline. Use arrow keys or click the link in the footer to navigate to the demo form.",
    max_steps: 1,
  )
}
