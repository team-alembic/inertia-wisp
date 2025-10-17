//// Props for slide pages
////
//// This module defines props for rendering presentation slides and provides
//// JSON serialization for all slide content.

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

// Prop name constants
const slide_prop_name = "slide"

const navigation_prop_name = "navigation"

const presentation_title_prop_name = "presentation_title"

/// Page schema for Slide page (for TypeScript generation)
pub fn slide_page_schema() -> page_schema.PageSchema {
  page_schema.page_schema("Slide")
  |> page_schema.prop(
    slide_prop_name,
    schema.RecordType(content_schemas.slide_schema),
    fn(p: SlideProp) {
      let assert SlideContent(slide) = p
      slide
    },
  )
  |> page_schema.always_prop(
    navigation_prop_name,
    schema.RecordType(content_schemas.slide_navigation_schema),
    fn(p: SlideProp) {
      let assert Navigation(nav) = p
      nav
    },
  )
  |> page_schema.always_prop(
    presentation_title_prop_name,
    schema.StringType,
    fn(p: SlideProp) {
      let assert PresentationTitle(title) = p
      title
    },
  )
  |> page_schema.tagger(fn(p: SlideProp) {
    case p {
      SlideContent(_) -> slide_prop_name
      Navigation(_) -> navigation_prop_name
      PresentationTitle(_) -> presentation_title_prop_name
    }
  })
  |> page_schema.build()
}

/// Create a slide content prop (DefaultProp)
pub fn slide_content(slide: content_schemas.Slide) -> prop.Prop(SlideProp) {
  prop.DefaultProp(slide_prop_name, SlideContent(slide))
}

/// Create a navigation prop (AlwaysProp)
pub fn navigation(nav: content_schemas.SlideNavigation) -> prop.Prop(SlideProp) {
  prop.AlwaysProp(navigation_prop_name, Navigation(nav))
}

/// Create a presentation title prop (AlwaysProp)
pub fn presentation_title(title: String) -> prop.Prop(SlideProp) {
  prop.AlwaysProp(presentation_title_prop_name, PresentationTitle(title))
}
