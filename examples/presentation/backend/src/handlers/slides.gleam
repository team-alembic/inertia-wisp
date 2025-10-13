//// Slides handler for the presentation
////
//// Routes slide requests to the appropriate slide content and provides
//// navigation information.

import gleam/int
import inertia_wisp/inertia
import inertia_wisp/prop.{AlwaysProp, DefaultProp}
import props/slide_props
import slides/content
import slides/slide_01
import slides/slide_02
import slides/slide_03
import slides/slide_04
import slides/slide_05
import slides/slide_06
import slides/slide_07
import slides/slide_08
import slides/slide_09
import slides/slide_10
import slides/slide_11
import slides/slide_12
import slides/slide_13
import slides/slide_14
import slides/slide_15
import wisp.{type Request, type Response}

/// Total number of slides in the presentation
const total_slides = 15

// Factory functions for creating Prop(SlideProp) instances

/// Create a slide content prop (DefaultProp)
fn slide_content(slide: content.Slide) -> prop.Prop(slide_props.SlideProp) {
  DefaultProp("slide", slide_props.SlideContent(slide))
}

/// Create a navigation prop (AlwaysProp)
fn navigation(nav: content.SlideNavigation) -> prop.Prop(slide_props.SlideProp) {
  AlwaysProp("navigation", slide_props.Navigation(nav))
}

/// Create a presentation title prop (AlwaysProp)
fn presentation_title(title: String) -> prop.Prop(slide_props.SlideProp) {
  AlwaysProp("presentation_title", slide_props.PresentationTitle(title))
}

/// Handle requests to view a specific slide
pub fn view_slide(req: Request, slide_num_str: String) -> Response {
  case int.parse(slide_num_str) {
    Ok(slide_num) if slide_num >= 1 && slide_num <= total_slides -> {
      let slide = get_slide(slide_num)
      let nav = content.navigation(slide_num, total_slides)

      let props = [
        slide_content(slide),
        navigation(nav),
        presentation_title("Gleam + TypeScript"),
      ]

      req
      |> inertia.response_builder("Slide")
      |> inertia.props(props, slide_props.slide_prop_to_json)
      |> inertia.response(200)
    }
    _ -> wisp.not_found()
  }
}

/// Handle requests to the presentation home (redirect to first slide)
pub fn index(_req: Request) -> Response {
  wisp.redirect("/slides/1")
}

/// Get slide content by number
fn get_slide(number: Int) -> content.Slide {
  case number {
    1 -> slide_01.slide()
    2 -> slide_02.slide()
    3 -> slide_03.slide()
    4 -> slide_04.slide()
    5 -> slide_05.slide()
    6 -> slide_06.slide()
    7 -> slide_07.slide()
    8 -> slide_08.slide()
    9 -> slide_09.slide()
    10 -> slide_10.slide()
    11 -> slide_11.slide()
    12 -> slide_12.slide()
    13 -> slide_13.slide()
    14 -> slide_14.slide()
    15 -> slide_15.slide()
    _ -> panic as "Invalid slide number - should be caught by validation"
  }
}
