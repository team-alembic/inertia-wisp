//// Slides handler for the presentation
////
//// Routes slide requests to the appropriate slide content and provides
//// navigation information.

import gleam/int
import gleam/result
import inertia_wisp/inertia
import inertia_wisp/query_params
import props/slide_props.{SlideQueryParams}
import schemas/slide
import schemas/slide_navigation
import slides/about_me
import slides/acknowledgments
import slides/backend_code_example
import slides/backend_overview
import slides/form_success
import slides/forms_validation
import slides/frontend_languages
import slides/frontend_overview
import slides/generated_typescript
import slides/gleam_simplicity
import slides/inertia_pages
import slides/one_handler_four_cases
import slides/pagination
import slides/pitch
import slides/property_based_tests
import slides/react_component
import slides/title
import slides/tradeoffs_abstractions
import slides/tradeoffs_dsls
import slides/type_safe_integration
import slides/typescript_zod_schema
import slides/why_now
import wisp.{type Request, type Response}

/// Total number of slides in the presentation
const total_slides = 22

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
      // Decode step from query parameters using schema
      let SlideQueryParams(step:) =
        query_params.decode_from_request(
          slide_props.slide_query_params_schema(),
          req,
        )
        |> result.unwrap(SlideQueryParams(step: 1))

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
    slide_props.slide_content(slide),
    slide_props.navigation(nav),
    slide_props.presentation_title("Gleam + TypeScript"),
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

/// Get slide content by number and step, setting the correct slide number
///
/// To reorder slides in the presentation, simply reorder the case branches below.
/// Each slide module is referenced by its logical name, making it easy to
/// understand the presentation flow.
fn get_slide(number: Int, step: Int) -> slide.Slide {
  let content = case number {
    1 -> title.slide()
    2 -> acknowledgments.slide()
    3 -> about_me.slide()
    4 -> pitch.slide()
    5 -> frontend_overview.slide()
    6 -> frontend_languages.slide()
    7 -> inertia_pages.slide()
    8 -> backend_overview.slide()
    9 -> backend_code_example.slide(step)
    10 -> type_safe_integration.slide(step)
    11 -> generated_typescript.slide(step)
    12 -> typescript_zod_schema.slide(step)
    13 -> property_based_tests.slide(step)
    14 -> react_component.slide(step)
    15 -> forms_validation.slide()
    16 -> form_success.slide()
    17 -> pagination.slide()
    18 -> one_handler_four_cases.slide()
    19 -> gleam_simplicity.slide()
    20 -> why_now.slide()
    21 -> tradeoffs_dsls.slide()
    22 -> tradeoffs_abstractions.slide()
    _ -> panic as "Invalid slide number - should be caught by validation"
  }

  slide.set_number(content, number)
}

/// Create navigation with step support
fn navigation_with_steps(
  current: Int,
  step: Int,
  total: Int,
  max_steps: Int,
) -> slide_navigation.SlideNavigation {
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

  slide_navigation.SlideNavigation(
    current: current,
    total: total,
    has_previous: has_previous,
    has_next: has_next,
    previous_url: previous_url,
    next_url: next_url,
  )
}
