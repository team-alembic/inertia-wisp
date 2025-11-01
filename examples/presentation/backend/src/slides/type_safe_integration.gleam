//// Slide 10: With Type-Safe Integration
////
//// How Inertia.js bridges Gleam and TypeScript with Schemas

import schemas/content_block.{CodeBlock, Heading, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide(step: Int) -> Slide {
  // Determine which lines to highlight based on step
  let highlight_lines = case step {
    1 -> [1, 2, 3, 4]
    // Type definition
    2 -> [6, 7, 8, 9, 10, 11, 12]
    // Schema definition
    _ -> []
  }

  Slide(
    number: 0,
    title: "With Type-Safe Integration",
    content: [
      Heading("With Type-Safe Integration"),
      Spacer,
      Subheading("Gleam: Define Types & Schemas"),
      CodeBlock(
        "// Define the type\npub type User {\n  User(id: Int, name: String, email: String)\n}\n\n// Define the schema\npub fn user_schema() -> schema.RecordSchema(_) {\n  schema.record_schema(\"User\")\n  |> schema.int_field(\"id\")\n  |> schema.string_field(\"name\")\n  |> schema.string_field(\"email\")\n  |> schema.schema()\n}",
        "gleam",
        highlight_lines,
      ),
    ],
    notes: "Define types and schemas in Gleam. Schemas provide bidirectional encoding/decoding and generate TypeScript/Zod schemas automatically.",
    max_steps: 2,
  )
}
