//// Props for slide pages
////
//// This module defines props for rendering presentation slides and provides
//// JSON serialization for all slide content.

import gleam/dict
import gleam/json
import inertia_wisp/schema
import schemas/slide.{type Slide}
import schemas/slide_navigation.{type SlideNavigation}

/// Query parameter types for Slide pages
pub type SlideQueryParams {
  SlideQueryParams(step: Int)
}

/// Schema for Slide query parameters
pub fn slide_query_params_schema() -> schema.RecordSchema(_) {
  schema.record_schema("SlideQueryParams")
  |> schema.decode_into(SlideQueryParams(step: 1))
  |> schema.int_field("step")
  |> schema.schema()
}

/// Props for Slide page (v2 API - record-based)
pub type SlideProps {
  SlideProps(
    slide: Slide,
    navigation: SlideNavigation,
    presentation_title: String,
  )
}

/// Record schema for Slide props
pub fn slide_props_schema() -> schema.RecordSchema(SlideProps) {
  schema.record_schema("SlidePageProps")
  |> schema.record_field("slide", slide.slide_schema)
  |> schema.record_field("navigation", slide_navigation.slide_navigation_schema)
  |> schema.string_field("presentation_title")
  |> schema.schema()
}

/// Encoder for SlideProps (v2 API)
pub fn encode(props: SlideProps) -> dict.Dict(String, json.Json) {
  schema.to_json_dict(slide_props_schema(), props)
}
