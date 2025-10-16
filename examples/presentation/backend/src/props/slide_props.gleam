//// Props for slide pages
////
//// This module defines props for rendering presentation slides and provides
//// JSON serialization for all slide content.

import gleam/json.{type Json}
import inertia_wisp/schema
import schemas/content as content_schemas

/// Prop types for slide pages
pub type SlideProp {
  SlideContent(content_schemas.Slide)
  Navigation(content_schemas.SlideNavigation)
  PresentationTitle(String)
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
