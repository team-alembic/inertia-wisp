//// Slides handler for the presentation
////
//// Routes slide requests to the appropriate slide content and provides
//// navigation information.

import gleam/int
import inertia_wisp/inertia
import props/slide_props
import slides/content
import slides/slide_01
import slides/slide_02
import slides/slide_03
import slides/slide_04
import slides/slide_05
import slides/slide_06
import slides/slide_07
import wisp.{type Request, type Response}

/// Total number of slides in the presentation
const total_slides = 7

/// Handle requests to view a specific slide
pub fn view_slide(req: Request, slide_num_str: String) -> Response {
  case int.parse(slide_num_str) {
    Ok(slide_num) if slide_num >= 1 && slide_num <= total_slides -> {
      let slide = get_slide(slide_num)
      let nav = content.navigation(slide_num, total_slides)

      let props = [
        slide_props.slide_content(slide),
        slide_props.navigation(nav),
        slide_props.presentation_title("Gleam + TypeScript"),
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
    _ -> panic as "Invalid slide number - should be caught by validation"
  }
}
