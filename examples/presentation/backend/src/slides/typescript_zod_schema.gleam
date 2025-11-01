//// Slide 12: With Type-Safe Integration (Generated Zod Schema)
////
//// Shows the auto-generated Zod schemas from Gleam schemas

import schemas/content_block.{CodeBlock, Heading, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide(step: Int) -> Slide {
  // Determine which lines to highlight based on step
  let highlight_lines = case step {
    1 -> [1]
    // Comment
    2 -> [3, 4, 5, 6, 7, 8]
    // Zod schema
    3 -> [10]
    // Inferred type
    _ -> []
  }

  Slide(
    number: 0,
    title: "Type Safety Approach #2",
    content: [
      Heading("Type Safety Approach #2"),
      Spacer,
      Subheading("Generate Zod Schemas from Gleam Schemas:"),
      CodeBlock(
        "// Auto-generated from Gleam schemas - DO NOT EDIT\n\nexport const UserSchema = z.object({\n  email: z.string(),\n  id: z.number(),\n  name: z.string(),\n}).strict();\n\nexport type User = z.infer<typeof UserSchema>;",
        "typescript",
        highlight_lines,
      ),
    ],
    notes: "Schemas defined in Gleam automatically generate Zod schemas for TypeScript. The .strict() ensures runtime type safety - any mismatch between backend and frontend is caught immediately!",
    max_steps: 3,
  )
}
