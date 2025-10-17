//// Code generation for frontend TypeScript/Zod schemas
////
//// Run with: gleam run -m codegen

import gleam/io
import gleam/string
import inertia_wisp/page_schema
import inertia_wisp/schema
import props/slide_props
import schemas/contact_form
import schemas/content_block
import schemas/image_data
import schemas/slide
import schemas/slide_navigation
import schemas/user
import simplifile

pub fn main() {
  io.println("Generating TypeScript/Zod schemas...")

  let output =
    "// Auto-generated from Gleam schemas - DO NOT EDIT\n\n"
    <> "import { z } from \"zod\";\n\n"
    <> schema.to_zod_schema(user.user_schema())
    <> "\n\n"
    <> schema.to_zod_schema(contact_form.contact_form_data_schema())
    <> "\n\n"
    <> schema.to_zod_schema(image_data.image_data_schema())
    <> "\n\n"
    <> schema.to_zod_schema(slide_navigation.slide_navigation_schema())
    <> "\n\n"
    <> schema.variant_to_zod_schema(content_block.content_block_schema())
    <> "\n\n"
    <> schema.to_zod_schema(slide.slide_schema())
    <> "\n\n"
    <> page_schema.to_zod_schema(slide_props.slide_page_schema())
    <> "\n"

  let output_path = "../frontend/src/generated/schemas.ts"

  case simplifile.write(to: output_path, contents: output) {
    Ok(_) -> {
      io.println("✓ Generated " <> output_path)
      io.println("\nGenerated schemas:")
      io.println("  - User")
      io.println("  - ContactFormData")
      io.println("  - ImageData")
      io.println("  - SlideNavigation")
      io.println("  - ContentBlock (variant)")
      io.println("  - Slide")
      io.println("  - SlidePageProps")
    }
    Error(err) -> {
      io.println("✗ Failed to write file: " <> string.inspect(err))
    }
  }
}
