//// Slide 13: Why This Matters Now
////
//// Highlighting AI tools adoption and Gleam's fit for AI-assisted development

import slides/content.{
  type Slide, Slide, BulletList, Columns, Heading, Image, Spacer, Subheading,
}

pub fn slide() -> Slide {
  Slide(
    number: 13,
    title: "Why This Matters Now",
    content: [
      Heading("Why This Matters Now"),
      Spacer,
      Subheading("AI-Assisted Development"),
      Columns(
        left: [
          Image(
            "/static/images/stackoverflow-dev-survey-2025-ai-sentiment-and-usage-ai-sel-prof-social.png",
            "Stack Overflow Survey 2025 - AI Usage",
            400,
          ),
        ],
        right: [
          BulletList([
            "> 50% of developers using AI tools daily",
            "Consistent syntax = detects patterns reliably ",
            "No metaprogramming = no additional context required",
            "Single definitions = Agent directly reads implementation code",
            "Clear error messages help AI fix mistakes",
            "Feel productive while learning with AI assistance",
          ]),
        ],
      ),
    ],
    notes: "The widespread adoption of AI tools (84% of developers) makes Gleam's simplicity particularly valuable. AI can understand and work with Gleam effectively due to its clear syntax, explicit structure, and helpful error messages, enabling rapid productivity.",
  )
}
