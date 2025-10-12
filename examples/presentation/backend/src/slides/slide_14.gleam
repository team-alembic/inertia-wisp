//// Slide 14: The Trade-offs - Embedded DSLs
////
//// First trade-off: Embedded DSLs aren't really possible

import presentation_shared/slides/content.{
  type Slide, Slide, CodeBlock, Columns, Heading, Paragraph, Spacer, Subheading,
}

pub fn slide() -> Slide {
  Slide(
    number: 14,
    title: "The Trade-offs",
    content: [
      Heading("The Trade-offs"),
      Spacer,
      Subheading("Embedded DSLs aren't really possible"),
      Columns(
        left: [
          Paragraph("Elixir's Ecto Query DSL"),
          CodeBlock(
            "query = \n  from u in User,\n    where: u.email like \"%gmail%\",\n    select: {u.id, u.email}",
            "elixir",
            [],
          ),
        ],
        right: [
          Paragraph("Gleam's Parrot library generates bindings to SQL"),
          CodeBlock(
            "-- name: FindGmailUsers :many\nSELECT id, email FROM user WHERE email like '%gmail%';",
            "SQL",
            [],
          ),
          CodeBlock("gleam run -m parrot", "bash", []),
          CodeBlock(
            "
pub type FindGmailUsers {
  FindGmailUsers(id: Int, email: String)
}

pub fn find_gmail_users() {
  let sql = \"SELECT id, email FROM users WHERE email like '%gmail%'\"
  #(sql, [], find_gmail_users_decoder())
}

pub fn find_gmail_users_decoder() -> decode.Decoder(FindGmailUsers) {
  use id <- decode.field(0, decode.int)
  use email <- decode.field(1, decode.string)
  decode.success(FindGmailUsers(id:, email:))
}
",
            "gleam",
            [],
          ),
        ],
      ),
    ],
    notes: "Gleam's simplicity comes with a trade-off: embedded DSLs like Ecto queries aren't possible. Instead, use external SQL files with codegen tools like Parrot.",
  )
}
