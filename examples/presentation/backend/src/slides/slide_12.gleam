//// Slide 12: Many Languages Claim "Simple"
////
//// Showing how different languages approach simplicity

import slides/content.{type Slide, Slide, BulletList, Heading, Spacer}

pub fn slide() -> Slide {
  Slide(
    number: 12,
    title: "Gleam's Simplicity",
    content: [
      Heading("Gleam's Simplicity"),
      Spacer,
      content.Columns(
        left: [
          BulletList([
            "Gleam programs are simple due to Gleam's constraints",
            "Paradigm: Types and Functions in Modules",
            "Limited syntax sugar",
            "No macros or meta programming",
            "Limited reflection",
            "No traits, type classes, higher-kinded types",
            "Explicit imports and exports",
            "Modules map to file system",
          ]),
        ],
        right: [
          content.CodeBlock(
            code: "
case req.method, wisp.path_segments(req) {
  Get, [] -> home.home_page(req)
  Get, [\"dashboard\"] -> dashboard.dashboard_page(req, db)
  Post, [\"users\"] -> users.users_create(req, db)
  Get, [\"users\", id] -> users.users_show(req, id, db)
  Get, [\"users\", id, \"edit\"] -> users.users_edit_form(req, id, db)
  Put, [\"users\", id] -> users.users_update(req, id, db)
  Delete, [\"users\", id] -> users.users_delete(req, id, db)
  _, _ -> wisp.not_found()
}
",
            language: "gleam",
            highlight_lines: [],
          ),
          content.Paragraph("Wisp router is a case expression"),
        ],
      ),
    ],
    notes: "",
  )
}
