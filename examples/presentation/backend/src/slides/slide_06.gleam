//// Slide 6: The Frontend You Know (Languages)
////
//// JavaScript and TypeScript as the dominant languages

import slides/content.{
  type Slide, Slide, BulletList, CodeBlock, Columns, Heading, Image, Spacer,
}

pub fn slide() -> Slide {
  Slide(
    number: 6,
    title: "The Frontend You Know",
    content: [
      Heading("The Frontend You Know"),
      Spacer,
      Columns(
        left: [
          Image(
            "/static/images/stackoverflow-survey-languages.png",
            "Stack Overflow Developer Survey - JavaScript and TypeScript are the most used languages",
            400,
          ),
        ],
        right: [
          BulletList([
            "Javascript: Most used language",
            "TypeScript: Trailing only Python, JS for general purpose languages",
          ]),
          Spacer,
          CodeBlock(
            "interface User {\n  id: number\n  name: string\n  email: string\n}",
            "typescript",
            [],
          ),
        ],
      ),
    ],
    notes: "JavaScript is the most used programming language, and TypeScript provides type safety on top of it, making it extremely popular.",
  )
}
