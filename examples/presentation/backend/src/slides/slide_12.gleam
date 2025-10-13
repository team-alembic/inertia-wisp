//// Slide 11: With Type-Safe Integration (Property-Based Tests)
////
//// Shows property-based tests ensuring encoder/schema compatibility

import shared/content.{type Slide, CodeBlock, Heading, Slide, Spacer, Subheading}

pub fn slide(step: Int) -> Slide {
  // Determine which lines to highlight based on step
  let highlight_lines = case step {
    1 -> [2, 3, 4, 5, 6]
    // Arbitrary definition
    2 -> [10]
    // fc.property line
    3 -> [12, 13, 14]
    // Gleam encoding
    4 -> [17, 18]
    // Zod validation
    _ -> []
  }

  Slide(
    number: 12,
    title: "With Type-Safe Integration",
    content: [
      Heading("With Type-Safe Integration"),
      Spacer,
      Subheading("Property-Based Tests Ensure Compatibility:"),
      CodeBlock(
        "// Arbitrary generates Gleam types directly\nconst userArbitrary = fc\n  .record({ name: fc.string(), email: fc.string() })\n  .map(({ name, email }) => \n    Shared.User$User(name, email)\n  );\n\nit(\"User: Gleam encoder produces valid Zod JSON\", () => {\n  fc.assert(\n    fc.property(userArbitrary, (gleamUser) => {\n      // 1. Encode with Gleam\n      const json = Shared.user_to_json(gleamUser);\n      const jsonString = GleamJson.to_string(json);\n      const parsed = JSON.parse(jsonString);\n      \n      // 2. Validate with Zod (strict!)\n      const result = UserSchema.safeParse(parsed);\n      expect(result.success).toBe(true);\n    }),\n    { numRuns: 1000 }\n  );\n});",
        "typescript",
        highlight_lines,
      ),
    ],
    notes: "Property-based tests generate 1000s of random Gleam values, encode them to JSON, and verify Zod validation passes. Catches mismatches immediately!",
    max_steps: 4,
  )
}
