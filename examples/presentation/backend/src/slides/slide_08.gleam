//// Slide 8: The Backend You'll Love (Code Example)
////
//// Gleam code example showing clean routing

import slides/content.{type Slide, Slide, CodeBlock, Heading, Spacer}

pub fn slide() -> Slide {
  Slide(
    number: 8,
    title: "The Backend You'll Love",
    content: [
      Heading("The Backend You'll Love"),
      Spacer,
      CodeBlock(
        "pub fn show_user_handler(req: Request, id: String, db: Connection) -> Response {\n  use user_id <- try_parse_user_id(req, id)\n  use user <- try_get_user(req, user_id, db)\n\n  let props = [user_props.user_data(user)]\n\n  req\n  |> inertia.response_builder(\"Users/Show\")\n  |> inertia.props(props, user_props.user_prop_to_json)\n  |> inertia.response(200)\n}",
        "gleam",
        [],
      ),
    ],
    notes: "Clean, readable Gleam code showing pattern matching for routing - simple and type-safe",
  )
}
