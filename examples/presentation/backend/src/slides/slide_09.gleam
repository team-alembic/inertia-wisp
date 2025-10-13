//// Slide 9: With Type-Safe Integration
////
//// How Inertia.js bridges Gleam and TypeScript type-safely

import slides/content.{type Slide, Slide, CodeBlock, Heading, Spacer, Subheading}

pub fn slide() -> Slide {
  Slide(
    number: 9,
    title: "With Type-Safe Integration",
    content: [
      Heading("With Type-Safe Integration"),
      Spacer,
      Subheading("Gleam Types:"),
      CodeBlock(
        "pub type DashboardPageProp {\n  UserName(name: String)\n  UserEmail(email: String)\n  UserRole(role: String)\n}",
        "gleam",
        [],
      ),
    ],
    notes: "Define types in Gleam - this is the single source of truth for the entire application.",
  )
}
