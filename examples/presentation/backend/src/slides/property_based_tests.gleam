//// Slide 13: Two Type Safety Approaches Summary
////
//// Summarizes the two complementary approaches to type safety

import schemas/content_block.{BulletList, Heading, Spacer, Subheading}
import schemas/slide.{type Slide, Slide}

pub fn slide(_step: Int) -> Slide {
  Slide(
    number: 0,
    title: "Two Type Safety Approaches",
    content: [
      Heading("Two Type Safety Approaches"),
      Spacer,
      Subheading("Approach #1: Compile Gleam → JavaScript"),
      BulletList([
        "✅ Share validation logic between backend and frontend",
        "✅ Same code runs in both environments",
        "✅ Perfect for business logic like form validation",
        "✅ Example: validate_name() used by both Gleam handlers and React forms",
      ]),
      Spacer,
      Subheading("Approach #2: Generate Zod from Schemas"),
      BulletList([
        "✅ Define schemas once in Gleam, generate TypeScript/Zod automatically",
        "✅ Bidirectional: encoding AND decoding from same schema",
        "✅ Runtime type safety with Zod's .strict() validation",
        "✅ Backend/frontend types stay in sync automatically",
      ]),
    ],
    notes: "Both approaches work together! Use compiled Gleam for shared logic, and generated Zod schemas for data validation. No manual synchronization needed!",
    max_steps: 1,
  )
}
