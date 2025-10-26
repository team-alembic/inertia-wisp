//// Slide 19: Many Languages Claim "Simple"
////
//// Showing how different languages approach simplicity

import schemas/content_block.{
  BulletList, CodeBlock, Columns, Heading, Paragraph, Spacer,
}
import schemas/slide.{type Slide, Slide}

pub fn slide() -> Slide {
  Slide(
    number: 0,
    title: "Gleam's Simplicity",
    content: [
      Heading("Gleam's Simplicity"),
      Spacer,
      Columns(
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
          CodeBlock(
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
          Paragraph("Wisp router is a case expression"),
        ],
      ),
    ],
    notes: "",
    max_steps: 1,
  )
}
