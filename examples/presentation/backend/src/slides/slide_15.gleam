//// Slide 15: The Trade-offs - Generic Abstractions
////
//// Second trade-off: Generic abstractions need explicit dictionaries

import presentation_shared/slides/content.{
  type Slide, Slide, CodeBlock, Columns, Heading, Paragraph, Spacer, Subheading,
}

pub fn slide() -> Slide {
  Slide(
    number: 15,
    title: "The Trade-offs",
    content: [
      Heading("The Trade-offs"),
      Spacer,
      Subheading("Generic abstractions need explicit dictionaries"),
      Columns(
        left: [
          Paragraph("Haskell sort requires Ord type class"),
          CodeBlock("sort :: Ord a => [a] -> [a]", "haskell", []),
        ],
        right: [
          Paragraph("Gleam sort requires comparison function"),
          CodeBlock(
            "pub fn sort(
  list: List(a),
  by compare: fn(a, a) -> order.Order) -> List(a)",
            "gleam",
            [],
          ),
        ],
      ),
    ],
    notes: "Generic abstractions in Gleam require explicit dictionary passing rather than implicit type classes. This is more verbose but always explicit - you always pass the comparison function directly.",
  )
}
