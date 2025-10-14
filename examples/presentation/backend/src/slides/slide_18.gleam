//// Slide 18: One Handler, Four Use Cases
////
//// How a single Inertia handler automatically handles multiple scenarios

import shared/content.{type Slide, BulletList, CodeBlock, Heading, Slide, Spacer}

pub fn slide() -> Slide {
  Slide(
    number: 18,
    title: "One Handler, Four Use Cases",
    content: [
      Heading("One Handler, Four Use Cases"),
      Spacer,
      BulletList([
        "📄 Initial HTML load - Props embedded as JSON in server-rendered HTML",
        "🔄 Page navigation - Load all props as JSON when linked from another page",
        "⏳ Deferred data - Separate request for DeferProp after initial render",
        "📊 Pagination - Partial reload with only necessary props",
      ]),
      Spacer,
      CodeBlock(
        "pub fn show_users_table(req: Request) -> Response {
  let page = parse_query_param(req, \"page\", int.parse, 1)
  let users = paginate(generate_users(100), page, 10)

  let props = [
    DefaultProp(\"users\", UsersProp(users)),
    DefaultProp(\"page\", PageProp(page)),
    DefaultProp(\"total_pages\", TotalPagesProp(10)),
    DeferProp(\"demo_info\", option.None, fn() {
      process.sleep(2000)  // Simulate expensive computation
      Ok(DemoInfoProp(\"Loaded separately!\"))
    }),
  ]

  req
  |> inertia.response_builder(\"UsersTable\")
  |> inertia.props(props, users_prop_to_json)
  |> inertia.response(200)
}",
        "gleam",
        [],
      ),
    ],
    notes: "This slide drives home the elegance of Inertia's design. The same handler code handles: (1) Initial page load where the HTML includes embedded JSON props, (2) Navigation from other pages where it returns just JSON, (3) Deferred prop loading where it evaluates only the deferred functions, and (4) Partial reloads during pagination where it returns only the requested props. This eliminates the need for separate REST API routes, reduces code duplication, and ensures the frontend and backend stay in sync. Open the network tab during the demo to see these different request types in action.",
    max_steps: 1,
  )
}
