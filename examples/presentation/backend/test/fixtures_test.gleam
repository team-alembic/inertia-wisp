import gleam/json
import simplifile
import slides/content

/// Helper to read fixture file
fn read_fixture(filename: String) -> String {
  let path = "../shared/fixtures/" <> filename
  let assert Ok(content) = simplifile.read(path)
  content
}

pub fn image_data_encodes_to_fixture_test() {
  // Create ImageData matching fixture
  let image_data =
    content.ImageData(
      url: "/images/gleam-logo.png",
      alt: "Gleam Programming Language Logo",
      width: 400,
    )

  // Encode to JSON
  let encoded =
    content.image_data_to_json(image_data)
    |> json.to_string()

  // Load fixture, parse it, and re-encode to normalize format
  let fixture = read_fixture("image_data.json")
  let assert Ok(parsed) =
    json.parse(from: fixture, using: content.image_data_decoder())
  let normalized_fixture =
    content.image_data_to_json(parsed) |> json.to_string()

  // Compare
  assert encoded == normalized_fixture
}

pub fn heading_block_encodes_to_fixture_test() {
  // Create Heading block matching fixture
  let block = content.Heading(text: "Introduction to Gleam")

  // Encode to JSON
  let encoded = content.content_block_to_json(block) |> json.to_string()

  // Load fixture, parse it, and re-encode to normalize format
  let fixture = read_fixture("content_block_heading.json")
  let assert Ok(parsed) =
    json.parse(from: fixture, using: content.content_block_decoder())
  let normalized_fixture =
    content.content_block_to_json(parsed) |> json.to_string()

  // Compare
  assert encoded == normalized_fixture
}

pub fn code_block_encodes_to_fixture_test() {
  // Create CodeBlock matching fixture
  let block =
    content.CodeBlock(
      code: "pub fn main() {\n  io.println(\"Hello, Gleam!\")\n}",
      language: "gleam",
      highlight_lines: [2],
    )

  // Encode to JSON
  let encoded = content.content_block_to_json(block) |> json.to_string()

  // Load fixture, parse it, and re-encode to normalize format
  let fixture = read_fixture("content_block_code.json")
  let assert Ok(parsed) =
    json.parse(from: fixture, using: content.content_block_decoder())
  let normalized_fixture =
    content.content_block_to_json(parsed) |> json.to_string()

  // Compare
  assert encoded == normalized_fixture
}

pub fn columns_block_encodes_to_fixture_test() {
  // Create Columns block matching fixture
  let block =
    content.Columns(
      left: [
        content.Heading(text: "Left Column"),
        content.BulletList(items: ["Point 1", "Point 2", "Point 3"]),
      ],
      right: [
        content.Heading(text: "Right Column"),
        content.Paragraph(text: "This is a paragraph in the right column."),
      ],
    )

  // Encode to JSON
  let encoded = content.content_block_to_json(block) |> json.to_string()

  // Load fixture, parse it, and re-encode to normalize format
  let fixture = read_fixture("content_block_columns.json")
  let assert Ok(parsed) =
    json.parse(from: fixture, using: content.content_block_decoder())
  let normalized_fixture =
    content.content_block_to_json(parsed) |> json.to_string()

  // Compare
  assert encoded == normalized_fixture
}

pub fn slide_encodes_to_fixture_test() {
  // Create Slide matching fixture
  let slide =
    content.Slide(
      number: 1,
      title: "Welcome to Inertia-Wisp",
      content: [
        content.Heading(text: "Building Modern Web Apps"),
        content.Subheading(text: "With Gleam, TypeScript, and Inertia.js"),
        content.Paragraph(
          text: "This presentation demonstrates how to build type-safe full-stack applications.",
        ),
        content.BulletList(items: [
          "Type safety from backend to frontend",
          "Modern React components",
          "Gleam's elegant syntax",
        ]),
        content.CodeBlock(
          code: "pub fn main() {\n  io.println(\"Hello, Gleam!\")\n}",
          language: "gleam",
          highlight_lines: [2],
        ),
        content.Spacer,
        content.Quote(
          text: "Gleam is a friendly language for building type-safe systems that scale!",
          author: "Louis Pilfold",
        ),
      ],
      notes: "Welcome slide - introduce the main topics and technologies covered in this presentation.",
    )

  // Encode to JSON
  let encoded = content.slide_to_json(slide) |> json.to_string()

  // Load fixture, parse it, and re-encode to normalize format
  let fixture = read_fixture("slide.json")
  let assert Ok(parsed) =
    json.parse(from: fixture, using: content.slide_decoder())
  let normalized_fixture = content.slide_to_json(parsed) |> json.to_string()

  // Compare
  assert encoded == normalized_fixture
}

pub fn slide_navigation_encodes_to_fixture_test() {
  // Create SlideNavigation matching fixture
  let navigation =
    content.SlideNavigation(
      current: 5,
      total: 15,
      has_previous: True,
      has_next: True,
      previous_url: "/slides/4",
      next_url: "/slides/6",
    )

  // Encode to JSON
  let encoded = content.slide_navigation_to_json(navigation) |> json.to_string()

  // Load fixture, parse it, and re-encode to normalize format
  let fixture = read_fixture("slide_navigation.json")
  let assert Ok(parsed) =
    json.parse(from: fixture, using: content.slide_navigation_decoder())
  let normalized_fixture =
    content.slide_navigation_to_json(parsed) |> json.to_string()

  // Compare
  assert encoded == normalized_fixture
}
