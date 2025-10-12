//// Slide 10: With Type-Safe Integration (Compiled TypeScript)
////
//// Shows the compiled TypeScript output from Gleam types

import slides/content.{type Slide, CodeBlock, Heading, Spacer, Subheading}

pub fn slide() -> Slide {
  content.Slide(
    number: 10,
    title: "With Type-Safe Integration",
    content: [
      Heading("With Type-Safe Integration"),
      Spacer,
      Subheading("Compile to TypeScript:"),
      CodeBlock(
        "export class UserName extends _.CustomType {\n  constructor(name: string);\n  name: string;\n}\nexport class UserEmail extends _.CustomType {\n  constructor(email: string);\n  email: string;\n}\nexport class UserRole extends _.CustomType {\n  constructor(role: string);\n  role: string;\n}\nexport type DashboardPageProp$ =\n  | UserName\n  | UserEmail\n  | UserRole",
        "typescript",
        [],
      ),
    ],
    notes: "Gleam types automatically compile to TypeScript, creating type-safe interfaces for the frontend.",
  )
}
