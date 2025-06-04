import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option
import gleeunit
import inertia_wisp/internal/controller
import inertia_wisp/internal/types
import inertia_wisp/testing
import wisp
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Test data setup - using individual prop types
fn encode_string_prop(value: String) -> json.Json {
  json.string(value)
}

fn create_test_context(req: wisp.Request) -> types.InertiaContext(String) {
  let config =
    types.Config(version: "1.0.0", ssr: False, encrypt_history: False)

  let props =
    dict.new()
    |> dict.insert(
      "title",
      types.Prop(prop_fn: fn() { "Test Title" }, include: types.IncludeDefault),
    )
    |> dict.insert(
      "count",
      types.Prop(prop_fn: fn() { "100" }, include: types.IncludeDefault),
    )
    |> dict.insert(
      "optional_data",
      types.Prop(
        prop_fn: fn() { "Secret Data" },
        include: types.IncludeOptionally,
      ),
    )

  types.InertiaContext(
    config: config,
    request: req,
    props: props,
    prop_encoder: encode_string_prop,
    errors: dict.new(),
    clear_history: False,
    encrypt_history: False,
    ssr_supervisor: option.None,
  )
}

// Test 1: Partial reload with matching component (should include only requested props)
pub fn partial_reload_matching_component_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["title", "optional_data"])
    |> testing.partial_component("HomePage")

  let ctx = create_test_context(req)
  let response = controller.render_typed(ctx, "HomePage")

  // Should be JSON response for Inertia request
  assert testing.component(response)
    == Ok("HomePage")
    as "Should render HomePage component for partial reload"

  // Should include requested default prop
  assert testing.prop(response, "title", decode.string)
    == Ok("Test Title")
    as "Should include requested default prop in partial reload"

  // Should include requested optional prop (since it's a valid partial reload)
  assert testing.prop(response, "optional_data", decode.string)
    == Ok("Secret Data")
    as "Should include requested optional prop for matching component"

  // Should NOT include non-requested default prop
  case testing.prop(response, "count", decode.string) {
    Error(_) -> Nil
    Ok(_) -> panic as "Should not include non-requested prop in partial reload"
  }
}

// Test 2: Partial reload with non-matching component (should include all default props)
pub fn partial_reload_non_matching_component_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["title", "optional_data"])
    |> testing.partial_component("AboutPage")
  // Different component

  let ctx = create_test_context(req)
  let response = controller.render_typed(ctx, "HomePage")
  // Rendering HomePage

  // Should be JSON response for Inertia request
  assert testing.component(response)
    == Ok("HomePage")
    as "Should render HomePage component for non-matching partial reload"

  // Should include ALL default props (treat as regular page load)
  assert testing.prop(response, "title", decode.string)
    == Ok("Test Title")
    as "Should include all default props when component doesn't match"

  assert testing.prop(response, "count", decode.string)
    == Ok("100")
    as "Should include all default props when component doesn't match"

  // Should NOT include optional prop (not a valid partial reload)
  case testing.prop(response, "optional_data", decode.string) {
    Error(_) -> Nil
    Ok(_) ->
      panic as "Should not include optional prop for non-matching component"
  }
}

// Test 3: Regular Inertia request (should include all default props)
pub fn regular_inertia_request_test() {
  let req = testing.inertia_request()
  // No partial data or component headers

  let ctx = create_test_context(req)
  let response = controller.render_typed(ctx, "HomePage")

  // Should be JSON response for Inertia request
  assert testing.component(response)
    == Ok("HomePage")
    as "Should render HomePage component for regular Inertia request"

  // Should include all default props
  assert testing.prop(response, "title", decode.string)
    == Ok("Test Title")
    as "Should include default props in regular Inertia request"

  assert testing.prop(response, "count", decode.string)
    == Ok("100")
    as "Should include default props in regular Inertia request"

  // Should NOT include optional prop
  case testing.prop(response, "optional_data", decode.string) {
    Error(_) -> Nil
    Ok(_) -> panic as "Should not include optional prop in regular request"
  }
}

// Test 4: Non-Inertia request (should include all default props)
pub fn non_inertia_request_test() {
  let req = wisp_testing.get("/", [])
  // Regular request without Inertia headers

  let ctx = create_test_context(req)
  let response = controller.render_typed(ctx, "HomePage")

  // Should be HTML response for non-Inertia request
  // We can still extract the embedded JSON data
  assert testing.component(response)
    == Ok("HomePage")
    as "Should render HomePage component for non-Inertia request"

  // Should include all default props
  assert testing.prop(response, "title", decode.string)
    == Ok("Test Title")
    as "Should include default props in non-Inertia request"

  assert testing.prop(response, "count", decode.string)
    == Ok("100")
    as "Should include default props in non-Inertia request"

  // Should NOT include optional prop
  case testing.prop(response, "optional_data", decode.string) {
    Error(_) -> Nil
    Ok(_) -> panic as "Should not include optional prop in non-Inertia request"
  }
}

// Test 5: Partial reload with partial data but no component header (should treat as regular)
pub fn partial_data_without_component_header_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["title"])
  // No partial component header

  let ctx = create_test_context(req)
  let response = controller.render_typed(ctx, "HomePage")

  // Should be JSON response for Inertia request
  assert testing.component(response)
    == Ok("HomePage")
    as "Should render HomePage component when partial data without component header"

  // Should include ALL default props (treat as regular page load)
  assert testing.prop(response, "title", decode.string)
    == Ok("Test Title")
    as "Should treat as regular page load when partial data without component"

  assert testing.prop(response, "count", decode.string)
    == Ok("100")
    as "Should treat as regular page load when partial data without component"

  // Should NOT include optional prop (not a valid partial reload)
  case testing.prop(response, "optional_data", decode.string) {
    Error(_) -> Nil
    Ok(_) ->
      panic as "Should not include optional prop without valid partial reload"
  }
}

// Test 6: Component header without partial data (should treat as regular)
pub fn component_header_without_partial_data_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_component("HomePage")
  // No partial data header

  let ctx = create_test_context(req)
  let response = controller.render_typed(ctx, "HomePage")

  // Should be JSON response for Inertia request
  assert testing.component(response)
    == Ok("HomePage")
    as "Should render HomePage component when component header without partial data"

  // Should include ALL default props (treat as regular page load)
  assert testing.prop(response, "title", decode.string)
    == Ok("Test Title")
    as "Should treat as regular page load when component header without partial data"

  assert testing.prop(response, "count", decode.string)
    == Ok("100")
    as "Should treat as regular page load when component header without partial data"

  // Should NOT include optional prop (not a valid partial reload)
  case testing.prop(response, "optional_data", decode.string) {
    Error(_) -> Nil
    Ok(_) ->
      panic as "Should not include optional prop without valid partial reload"
  }
}
