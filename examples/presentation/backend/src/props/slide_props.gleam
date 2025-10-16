//// Props for slide pages
////
//// This module defines props for rendering presentation slides and provides
//// JSON serialization for all slide content.

import gleam/json.{type Json}
import inertia_wisp/page_schema
import inertia_wisp/prop
import inertia_wisp/schema
import schemas/content as content_schemas

/// Prop types for slide pages
pub type SlideProp {
  SlideContent(content_schemas.Slide)
  Navigation(content_schemas.SlideNavigation)
  PresentationTitle(String)
}

/// Page schema for Slide page (for TypeScript generation)
pub fn slide_page_schema() -> page_schema.PageSchema {
  page_schema.page_schema("Slide")
  |> page_schema.prop("slide", schema.RecordType(content_schemas.slide_schema))
  |> page_schema.prop(
    "navigation",
    schema.RecordType(content_schemas.slide_navigation_schema),
  )
  |> page_schema.prop("presentation_title", schema.StringType)
  |> page_schema.build()
}

// Factory functions for creating Prop(SlideProp) instances

/// Create a slide content prop (DefaultProp)
pub fn slide_content(slide: content_schemas.Slide) -> prop.Prop(SlideProp) {
  prop.DefaultProp("slide", SlideContent(slide))
}

/// Create a navigation prop (AlwaysProp)
pub fn navigation(nav: content_schemas.SlideNavigation) -> prop.Prop(SlideProp) {
  prop.AlwaysProp("navigation", Navigation(nav))
}

/// Create a presentation title prop (AlwaysProp)
pub fn presentation_title(title: String) -> prop.Prop(SlideProp) {
  prop.AlwaysProp("presentation_title", PresentationTitle(title))
}

/// Convert a SlideProp to JSON
pub fn slide_prop_to_json(slide_prop: SlideProp) -> Json {
  case slide_prop {
    SlideContent(slide) -> schema.to_json(content_schemas.slide_schema(), slide)
    Navigation(nav) ->
      schema.to_json(content_schemas.slide_navigation_schema(), nav)
    PresentationTitle(title) -> json.string(title)
  }
}
