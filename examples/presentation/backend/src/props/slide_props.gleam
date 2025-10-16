//// Props for slide pages
////
//// This module defines props for rendering presentation slides and provides
//// JSON serialization for all slide content.

import gleam/json.{type Json}
import inertia_wisp/prop
import inertia_wisp/schema
import schemas/content as content_schemas

/// Prop types for slide pages
pub type SlideProp {
  SlideContent(content_schemas.Slide)
  Navigation(content_schemas.SlideNavigation)
  PresentationTitle(String)
}

/// The complete props structure for a slide page
pub type SlidePageProps {
  SlidePageProps(
    slide: content_schemas.Slide,
    navigation: content_schemas.SlideNavigation,
    presentation_title: String,
  )
}

/// Schema for SlidePageProps
pub fn slide_page_props_schema() -> schema.RecordSchema {
  schema.record_schema(
    "SlidePageProps",
    SlidePageProps(
      slide: content_schemas.Slide(
        number: 0,
        title: "",
        content: [],
        notes: "",
        max_steps: 1,
      ),
      navigation: content_schemas.SlideNavigation(
        current: 0,
        total: 0,
        has_previous: False,
        has_next: False,
        previous_url: "",
        next_url: "",
      ),
      presentation_title: "",
    ),
  )
  |> schema.record_field(
    "slide",
    content_schemas.slide_schema,
    fn(props) { props.slide },
    fn(props, slide) { SlidePageProps(..props, slide:) },
  )
  |> schema.record_field(
    "navigation",
    content_schemas.slide_navigation_schema,
    fn(props) { props.navigation },
    fn(props, navigation) { SlidePageProps(..props, navigation:) },
  )
  |> schema.string_field(
    "presentation_title",
    fn(props) { props.presentation_title },
    fn(props, presentation_title) {
      SlidePageProps(..props, presentation_title:)
    },
  )
  |> schema.schema()
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
