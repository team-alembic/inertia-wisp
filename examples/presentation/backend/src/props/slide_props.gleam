//// Props for slide pages
////
//// This module defines props for rendering presentation slides and provides
//// JSON serialization for all slide content.

import gleam/json
import inertia_wisp/page_schema
import inertia_wisp/prop
import inertia_wisp/schema
import schemas/slide.{type Slide}
import schemas/slide_navigation.{type SlideNavigation}

/// Prop types for slide pages
pub type SlideProp {
  SlideContent(Slide)
  Navigation(SlideNavigation)
  PresentationTitle(String)
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

/// Helper to create slide content prop
pub fn slide_content(slide: Slide) -> prop.Prop(SlideProp) {
  prop.DefaultProp("slide", SlideContent(slide))
}

/// Helper to create navigation prop
pub fn navigation(nav: SlideNavigation) -> prop.Prop(SlideProp) {
  prop.DefaultProp("navigation", Navigation(nav))
}

/// Helper to create presentation title prop
pub fn presentation_title(title: String) -> prop.Prop(SlideProp) {
  prop.AlwaysProp("presentation_title", PresentationTitle(title))
}

/// JSON encoder for slide props
pub fn slide_prop_to_json(prop: SlideProp) -> json.Json {
  case prop {
    Navigation(nav) -> slide_navigation.to_json(nav)
    PresentationTitle(title) -> json.string(title)
    SlideContent(content) -> slide.to_json(content)
  }
}
