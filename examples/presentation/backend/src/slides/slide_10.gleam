//// Slide 10: With Type-Safe Integration
////
//// How Inertia.js bridges Gleam and TypeScript type-safely

import schemas/content_block.{BulletList, CodeBlock, Columns, Heading, Image, ImageRow, LinkButton, NumberedList, Paragraph, Quote, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide(step: Int) -> Slide {
  // Determine which lines to highlight based on step
  let highlight_lines = case step {
    1 -> [1, 2, 3, 4]
    // Type definition
    2 -> [6, 7, 8, 9, 10, 11, 12, 13]
    // JSON encoder
    _ -> []
  }

  Slide(
    number: 10,
    title: "With Type-Safe Integration",
    content: [
      Heading("With Type-Safe Integration"),
      Spacer,
      Subheading("Gleam: Define Types & JSON Encoders"),
      CodeBlock(
        "// Define the type\npub type User {\n  User(name: String, email: String)\n}\n\n// JSON encoder\npub fn user_to_json(user: User) -> json.Json {\n  let User(name:, email:) = user\n  json.object([\n    #(\"name\", json.string(name)),\n    #(\"email\", json.string(email)),\n  ])\n}",
        "gleam",
        highlight_lines,
      ),
    ],
    notes: "Define types and encoders in Gleam - encoders are tested with property-based tests to ensure they match the frontend Zod schemas.",
    max_steps: 2,
  )
}
