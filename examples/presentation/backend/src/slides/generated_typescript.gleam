//// Slide 11: With Type-Safe Integration (Generated TypeScript)
////
//// Shows the TypeScript types automatically generated from Gleam

import schemas/content_block.{CodeBlock, Heading, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide(step: Int) -> Slide {
  // Determine which lines to highlight based on step
  let highlight_lines = case step {
    1 -> [1, 2, 3, 4, 5]
    // Class definition
    2 -> [6, 7, 8, 9]
    // Factory function
    _ -> []
  }

  Slide(
    number: 0,
    title: "With Type-Safe Integration",
    content: [
      Heading("With Type-Safe Integration"),
      Spacer,
      Subheading("Gleam Compiles to TypeScript Definitions:"),
      CodeBlock(
        "export class User$ extends _.CustomType {\n  constructor(name: string, email: string);\n  name: string;\n  email: string;\n}\nexport function User$User(\n  name: string,\n  email: string,\n): User$;",
        "typescript",
        highlight_lines,
      ),
    ],
    notes: "Gleam automatically generates TypeScript type definitions when compiling to JavaScript. These provide type information for the frontend.",
    max_steps: 2,
  )
}
