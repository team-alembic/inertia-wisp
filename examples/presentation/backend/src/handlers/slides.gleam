//// Slides handler for the presentation
////
//// Routes slide requests to the appropriate slide content and provides
//// navigation information.

import gleam/int
import gleam/list
import inertia_wisp/inertia
import inertia_wisp/prop.{AlwaysProp, DefaultProp}
import props/slide_props
import shared/content
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
import slides/slide_16
import slides/slide_17
import slides/slide_18
import slides/slide_19
import slides/slide_20
import wisp.{type Request, type Response}

/// Total number of slides in the presentation
const total_slides = 20

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

/// Parse slide number and step from request parameters
/// Step defaults to 1 if not provided or invalid
/// Returns 404 if slide number is invalid
fn parse_slide_params(
  slide_num_str: String,
  req: Request,
  next: fn(Int, Int) -> Response,
) -> Response {
  case int.parse(slide_num_str) {
    Ok(slide_num) if slide_num >= 1 && slide_num <= total_slides -> {
      let step = case wisp.get_query(req) |> list.key_find("step") {
        Ok(step_str) ->
          case int.parse(step_str) {
            Ok(s) if s >= 1 -> s
            _ -> 1
          }
        Error(_) -> 1
      }
      next(slide_num, step)
    }
    _ -> wisp.not_found()
  }
}

/// Handle requests to view a specific slide
pub fn view_slide(req: Request, slide_num_str: String) -> Response {
  use slide_num, step <- parse_slide_params(slide_num_str, req)
  let slide = get_slide(slide_num, step)
  let nav =
    navigation_with_steps(slide_num, step, total_slides, slide.max_steps)

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

/// Handle requests to the presentation home (redirect to first slide)
pub fn index(_req: Request) -> Response {
  wisp.redirect("/slides/1")
}

/// Get slide content by number and step
fn get_slide(number: Int, step: Int) -> content.Slide {
  case number {
    1 -> slide_01.slide()
    2 -> slide_02.slide()
    3 -> slide_03.slide()
    4 -> slide_04.slide()
    5 -> slide_05.slide()
    6 -> slide_06.slide()
    7 -> slide_07.slide()
    8 -> slide_08.slide(step)
    9 -> slide_09.slide(step)
    10 -> slide_10.slide(step)
    11 -> slide_11.slide(step)
    12 -> slide_12.slide(step)
    13 -> slide_13.slide(step)
    14 -> slide_14.slide()
    15 -> slide_15.slide()
    16 -> slide_16.slide()
    17 -> slide_17.slide()
    18 -> slide_18.slide()
    19 -> slide_19.slide()
    20 -> slide_20.slide()
    _ -> panic as "Invalid slide number - should be caught by validation"
  }
}

/// Create navigation with step support
fn navigation_with_steps(
  current: Int,
  step: Int,
  total: Int,
  max_steps: Int,
) -> content.SlideNavigation {
  let has_previous = current > 1 || step > 1
  let has_next = current < total || step < max_steps

  let previous_url = case step > 1 {
    True ->
      "/slides/"
      <> int.to_string(current)
      <> "?step="
      <> int.to_string(step - 1)
    False ->
      case current > 1 {
        True -> "/slides/" <> int.to_string(current - 1)
        False -> "#"
      }
  }

  let next_url = case step < max_steps {
    True ->
      "/slides/"
      <> int.to_string(current)
      <> "?step="
      <> int.to_string(step + 1)
    False ->
      case current < total {
        True -> "/slides/" <> int.to_string(current + 1)
        False -> "#"
      }
  }

  content.SlideNavigation(
    current: current,
    total: total,
    has_previous: has_previous,
    has_next: has_next,
    previous_url: previous_url,
    next_url: next_url,
  )
}
