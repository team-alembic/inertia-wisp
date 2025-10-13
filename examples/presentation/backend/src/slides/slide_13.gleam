//// Slide 12: With Type-Safe Integration (React Component)
////
//// Shows React component using validated props

import shared/content.{type Slide, CodeBlock, Heading, Slide, Spacer, Subheading}

pub fn slide(step: Int) -> Slide {
  // Determine which lines to highlight based on step
  let highlight_lines = case step {
    1 -> [1]
    // Function signature
    2 -> [11, 12, 13, 14]
    // validateProps wrapper
    _ -> []
  }

  Slide(
    number: 13,
    title: "With Type-Safe Integration",
    content: [
      Heading("With Type-Safe Integration"),
      Spacer,
      Subheading("React: Use Validated Props"),
      CodeBlock(
        "function UserProfile({ user }: { user: User }) {\n  return (\n    <div>\n      <h1>{user.name}</h1>\n      <p>{user.email}</p>\n    </div>\n  );\n}\n\n// Wrap with validation\nexport default validateProps(\n  UserProfile,\n  UserSchema\n);",
        "typescript",
        highlight_lines,
      ),
    ],
    notes: "React components receive type-safe props validated at runtime with Zod. Any mismatch between backend and frontend is caught immediately.",
  )
}
