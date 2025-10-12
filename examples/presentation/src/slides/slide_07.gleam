//// Slide 7: The Backend You'll Love
////
//// Showcasing Gleam and Wisp with their benefits

import slides/content.{
  type Slide, BulletList, Heading, ImageData, ImageRow, Spacer,
}

pub fn slide() -> Slide {
  content.Slide(
    number: 7,
    title: "The Backend You'll Love",
    content: [
      Heading("The Backend You'll Love"),
      Spacer,
      ImageRow([
        ImageData("/static/images/lucy.svg", "Lucy - Gleam mascot", 200),
        ImageData("/static/images/wisp.png", "Wisp web framework logo", 200),
      ]),
      Spacer,
      BulletList([
        "Simplicity - code that's easy to understand and maintain",
        "Type safety - compile-time guarantees",
        "Fast builds - instant feedback",
        "Clear errors - that tell you exactly what's wrong",
        "Excellent Tooling - build tool + language server",
        "BEAM power - fault tolerance, concurrency, scalability",
      ]),
    ],
    notes: "Gleam and Wisp provide an excellent backend development experience with simplicity, type safety, fast builds, clear errors, and the power of the BEAM.",
  )
}
