import gleam/int
import inertia_wisp/schema

/// ManualNavigation information for a slide
pub type SlideNavigation {
  SlideNavigation(
    current: Int,
    total: Int,
    has_previous: Bool,
    has_next: Bool,
    previous_url: String,
    next_url: String,
  )
}

/// Helper to create navigation info
pub fn navigation(current: Int, total: Int) -> SlideNavigation {
  let has_previous = current > 1
  let has_next = current < total
  let previous_url = case has_previous {
    True -> "/slides/" <> int.to_string(current - 1)
    False -> "#"
  }
  let next_url = case has_next {
    True -> "/slides/" <> int.to_string(current + 1)
    False -> "#"
  }

  SlideNavigation(
    current: current,
    total: total,
    has_previous: has_previous,
    has_next: has_next,
    previous_url: previous_url,
    next_url: next_url,
  )
}

/// Schema for SlideNavigation type
pub fn slide_navigation_schema() -> schema.RecordSchema(_) {
  schema.record_schema("SlideNavigation")
  |> schema.int_field("current")
  |> schema.int_field("total")
  |> schema.bool_field("has_previous")
  |> schema.bool_field("has_next")
  |> schema.string_field("previous_url")
  |> schema.string_field("next_url")
  |> schema.schema()
}

pub fn to_json(nav: SlideNavigation) {
  schema.to_json(slide_navigation_schema(), nav)
}
