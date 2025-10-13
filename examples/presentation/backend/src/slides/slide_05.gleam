//// Slide 5: The Frontend You Know
////
//// React and TypeScript as the frontend foundation

import shared/content.{
  type Slide, BulletList, CodeBlock, Columns, Heading, Image, Slide, Spacer,
}

pub fn slide() -> Slide {
  Slide(
    number: 5,
    title: "The Frontend You Know",
    content: [
      Heading("The Frontend You Know"),
      Spacer,
      Columns(
        left: [
          Image(
            "/static/images/stackoverflow-survey-react.png",
            "Stack Overflow Developer Survey - React is the most used frontend framework",
            400,
          ),
        ],
        right: [
          BulletList([
            "React: most used frontend framework",
            "Huge ecosystem",
            "Many talented developers",
          ]),
          Spacer,
          CodeBlock(
            "function UserList({ users }: { users: User[] }) {\n  return (\n    <ul>\n      {users.map(user => <li key={user.id}>{user.name}</li>)}\n    </ul>\n  );\n}",
            "tsx",
            [],
          ),
        ],
      ),
    ],
    notes: "React is the most popular frontend framework with a huge ecosystem and many talented developers. TypeScript provides type safety.",
    max_steps: 1,
  )
}
