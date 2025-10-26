//// Slide 10: With Type-Safe Integration (TypeScript Zod Schema)
////
//// Shows the Zod schema that validates backend JSON

import schemas/content_block.{CodeBlock, Heading, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide(step: Int) -> Slide {
  // Determine which lines to highlight based on step
  let highlight_lines = case step {
    1 -> [1, 2, 3, 4, 5, 6]
    // Zod schema
    2 -> [8]
    // Inferred type
    _ -> []
  }

  Slide(
    number: 0,
    title: "With Type-Safe Integration",
    content: [
      Heading("With Type-Safe Integration"),
      Spacer,
      Subheading("TypeScript: Define Zod Schemas"),
      CodeBlock(
        "export const UserSchema = z\n  .object({\n    name: z.string(),\n    email: z.string().email(),\n  })\n  .strict();\n\nexport type User = z.infer<typeof UserSchema>;",
        "typescript",
        highlight_lines,
      ),
    ],
    notes: "Define Zod schemas in TypeScript that mirror the Gleam JSON encoders. The .strict() ensures any mismatch is caught.",
    max_steps: 2,
  )
}
