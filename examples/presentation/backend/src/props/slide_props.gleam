//// Props for slide pages
////
//// This module defines props for rendering presentation slides and provides
//// JSON serialization for all slide content.

import gleam/dict
import gleam/json
import inertia_wisp/page_schema
import inertia_wisp/schema
import schemas/slide.{type Slide}
import schemas/slide_navigation.{type SlideNavigation}

/// Query parameter types for Slide pages
pub type SlideQueryParams {
  SlideQueryParams(step: Int)
}

/// Schema for Slide query parameters
pub fn slide_query_params_schema() -> schema.RecordSchema(_) {
  schema.record_schema("SlideQueryParams", SlideQueryParams(step: 1))
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

/// Page schema for Slide pages
pub fn slide_page_schema() -> page_schema.PageSchema {
  page_schema.page_schema("Slide")
  |> page_schema.prop("slide", schema.RecordType(slide.slide_schema))
  |> page_schema.prop(
    "navigation",
    schema.RecordType(slide_navigation.slide_navigation_schema),
  )
  |> page_schema.prop("presentation_title", schema.StringType)
  |> page_schema.build()
}

/// Encoder for SlideProps (v2 API)
pub fn encode(props: SlideProps) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("slide", slide.to_json(props.slide)),
    #("navigation", slide_navigation.to_json(props.navigation)),
    #("presentation_title", json.string(props.presentation_title)),
  ])
}
