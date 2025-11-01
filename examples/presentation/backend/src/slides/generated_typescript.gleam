//// Slide 11: With Type-Safe Integration (Shared Validation)
////
//// Shows how Gleam code compiles to JavaScript for shared validation

import schemas/content_block.{CodeBlock, Heading, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide(step: Int) -> Slide {
  // Determine which lines to highlight based on step
  let highlight_lines = case step {
    1 -> [1, 2, 3, 4]
    // Validation logic
    2 -> [5, 6, 7, 8, 9]
    // TypeScript usage
    _ -> []
  }

  Slide(
    number: 0,
    title: "Type Safety Approach #1",
    content: [
      Heading("Type Safety Approach #1"),
      Spacer,
      Subheading("Compile Gleam → JavaScript for Shared Validation:"),
      CodeBlock(
        "// Gleam validation function\npub fn validate_name(name: String) -> Result(String, String) {\n  case string.trim(name) {\n    \"\" -> Error(\"Name is required\")\n    trimmed -> {\n      case string.length(trimmed) < 2 {\n        True -> Error(\"Name must be at least 2 characters\")\n        False -> Ok(trimmed)\n      }\n    }\n  }\n}\n\n// Use directly from TypeScript!\nimport { validate_name } from \"@shared/forms.mjs\";\nconst result = validate_name(\"Alice\");",
        "gleam",
        highlight_lines,
      ),
    ],
    notes: "Compile Gleam code to JavaScript for shared validation logic. The same validation runs on both backend and frontend, eliminating duplication.",
    max_steps: 2,
  )
}
