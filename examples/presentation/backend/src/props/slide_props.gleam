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

const slide_prop_name = "slide"

const navigation_prop_name = "navigation"

const presentation_title_prop_name = "presentation_title"

pub fn slide_content(slide: Slide) -> prop.Prop(SlideProp) {
  prop.DefaultProp(slide_prop_name, SlideContent(slide))
}

pub fn navigation(nav: SlideNavigation) -> prop.Prop(SlideProp) {
  prop.AlwaysProp(navigation_prop_name, Navigation(nav))
}

pub fn presentation_title(title: String) -> prop.Prop(SlideProp) {
  prop.AlwaysProp(presentation_title_prop_name, PresentationTitle(title))
}

/// Page schema for Slide page (for TypeScript generation)
pub fn slide_page_schema() -> page_schema.PageSchema {
  page_schema.page_schema("Slide")
  |> page_schema.prop(slide_prop_name, schema.RecordType(slide.slide_schema))
  |> page_schema.prop(
    navigation_prop_name,
    schema.RecordType(slide_navigation.slide_navigation_schema),
  )
  |> page_schema.prop(presentation_title_prop_name, schema.StringType)
  |> page_schema.build()
}

pub fn slide_prop_to_json(prop: SlideProp) {
  case prop {
    Navigation(nav) -> slide_navigation.to_json(nav)
    PresentationTitle(title) -> json.string(title)
    SlideContent(content) -> slide.to_json(content)
  }
}
