//// Props for slide pages
////
//// This module defines props for rendering presentation slides and provides
//// JSON serialization for all slide content.

import gleam/json.{type Json}

import shared/content

/// Prop types for slide pages
pub type SlideProp {
  SlideContent(content.Slide)
  Navigation(content.SlideNavigation)
  PresentationTitle(String)
}

/// Convert a SlideProp to JSON
pub fn slide_prop_to_json(slide_prop: SlideProp) -> Json {
  case slide_prop {
    SlideContent(slide) -> content.slide_to_json(slide)
    Navigation(nav) -> content.slide_navigation_to_json(nav)
    PresentationTitle(title) -> json.string(title)
  }
}
