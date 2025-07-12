import gleam/dict
import gleam/json
import gleam/list
import gleam/option

import inertia_wisp/inertia
import inertia_wisp/internal/types
import inertia_wisp/testing
import wisp/testing as wisp_testing

// Test prop types
pub type TestProp {
  UserProp(name: String)
  CountProp(value: Int)
  MessageProp(text: String)
  SettingsProp(enabled: Bool)
  MetaProp(version: String)
}

// Encoder function for test props
fn encode_test_prop(prop: TestProp) -> #(String, json.Json) {
  case prop {
    UserProp(name) -> #("user", json.object([#("name", json.string(name))]))
    CountProp(value) -> #("count", json.int(value))
    MessageProp(text) -> #("message", json.string(text))
    SettingsProp(enabled) -> #(
      "settings",
      json.object([#("enabled", json.bool(enabled))]),
    )
    MetaProp(version) -> #(
      "meta",
      json.object([#("version", json.string(version))]),
    )
  }
}

pub fn eval_basic_functionality_test() {
  let req = wisp_testing.get("/home", [])
  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  assert page.component == "HomePage"
  assert page.url == "/home"
  assert page.version == "1"
  assert page.encrypt_history == False
  assert page.clear_history == False
  assert list.length(page.props) == 2
  assert page.deferred_props == option.None
}

pub fn eval_root_path_test() {
  let req = wisp_testing.get("/", [])
  let props = [types.DefaultProp("message", MessageProp("Welcome"))]

  let page = inertia.eval(req, "Home", props, encode_test_prop)

  assert page.url == "/"
}

pub fn eval_nested_path_test() {
  let req = wisp_testing.get("/users/123/edit", [])
  let props = [types.DefaultProp("user", UserProp("John"))]

  let page = inertia.eval(req, "EditUser", props, encode_test_prop)

  assert page.url == "/users/123/edit"
}

pub fn eval_standard_inertia_request_test() {
  let req = testing.inertia_request()

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.LazyProp("settings", fn() { SettingsProp(True) }),
    types.OptionalProp("meta", fn() { MetaProp("v1.0") }),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // Should include default, lazy, and always props, but not optional
  assert list.length(page.props) == 3
  assert page.deferred_props == option.None
}

pub fn eval_with_deferred_props_test() {
  let req = testing.inertia_request()

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.DeferProp("heavy_data", option.None, fn() { MessageProp("Heavy") }),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // Should include default and always props, deferred should be in deferred_props list
  assert list.length(page.props) == 2
  assert page.deferred_props
    == option.Some(dict.from_list([#("default", ["heavy_data"])]))
}

pub fn eval_partial_reload_only_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user", "settings"])

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.LazyProp("settings", fn() { SettingsProp(True) }),
    types.DefaultProp("message", MessageProp("Hello")),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // No component header means no partial reload - should include all non-optional props
  assert list.length(page.props) == 4
  // user, settings, message, count
}

pub fn eval_partial_reload_with_optional_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["meta"])

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.OptionalProp("meta", fn() { MetaProp("v1.0") }),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // No component header means no partial reload - should exclude optional props
  assert list.length(page.props) == 2
  // user, count (meta is optional so excluded without component match)
}

pub fn eval_partial_reload_component_mismatch_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user"])
    |> testing.partial_component("DifferentPage")

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.DefaultProp("message", MessageProp("Hello")),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // Component mismatch should result in full props (no partial reload)
  assert list.length(page.props) == 3
}

pub fn eval_partial_reload_component_match_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user"])
    |> testing.partial_component("HomePage")

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.DefaultProp("message", MessageProp("Hello")),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // Component match should respect partial reload
  assert list.length(page.props) == 2
  // user + count (always)
}

pub fn eval_merge_prop_default_test() {
  let req = testing.inertia_request()
  let props = [
    types.MergeProp(types.DefaultProp("users", UserProp("John")), option.None),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  assert list.length(page.props) == 1
}

pub fn eval_merge_prop_optional_excluded_test() {
  let req = testing.inertia_request()

  let props = [
    types.MergeProp(
      types.OptionalProp("users", fn() { UserProp("John") }),
      option.None,
    ),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // Optional prop inside merge should be excluded on standard visit
  assert page.props == []
}

pub fn eval_merge_prop_partial_reload_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["users"])

  let props = [
    types.MergeProp(
      types.OptionalProp("users", fn() { UserProp("John") }),
      option.Some(["id"]),
    ),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // No component header means no partial reload - optional prop inside merge excluded
  assert page.props == []
}

pub fn eval_non_inertia_request_test() {
  let req = wisp_testing.get("/home", [])
  // No Inertia headers

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.LazyProp("settings", fn() { SettingsProp(True) }),
    types.OptionalProp("meta", fn() { MetaProp("v1.0") }),
    types.AlwaysProp("count", CountProp(42)),
    types.DeferProp("heavy", option.None, fn() { MessageProp("Heavy") }),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // Non-Inertia request should exclude optional props but include deferred props in the list
  assert list.length(page.props) == 3
  // user, settings, count
  assert page.deferred_props
    == option.Some(dict.from_list([#("default", ["heavy"])]))
}

pub fn eval_lazy_evaluation_test() {
  let req = testing.inertia_request()

  // Create a prop that would panic if evaluated unnecessarily
  let expensive_prop =
    types.OptionalProp("expensive", fn() {
      // This should not be called for standard Inertia requests
      panic as "Expensive prop should not be evaluated"
    })

  let props = [types.DefaultProp("user", UserProp("John")), expensive_prop]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // Should succeed without evaluating the expensive prop
  assert list.length(page.props) == 1
}

pub fn eval_lazy_evaluation_partial_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["expensive"])

  // Create a lazy prop that should only be evaluated when requested
  let call_count = fn() { SettingsProp(True) }

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.LazyProp("expensive", call_count),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // No component header means no partial reload - should include all non-optional props
  assert list.length(page.props) == 3
  // user, expensive, count (all non-optional)
}

pub fn eval_empty_props_test() {
  let req = testing.inertia_request()

  let page = inertia.eval(req, "EmptyPage", [], encode_test_prop)

  assert page.component == "EmptyPage"
  assert page.props == []
  assert page.deferred_props == option.None
}

pub fn eval_empty_partial_data_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data([])

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // No component header means no partial reload - should include all non-optional props
  assert list.length(page.props) == 2
  // user, count (all non-optional)
}

pub fn eval_deferred_with_group_test() {
  let req = testing.inertia_request()

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.DeferProp("data1", option.Some("group1"), fn() {
      MessageProp("Data1")
    }),
    types.DeferProp("data2", option.Some("group1"), fn() {
      MessageProp("Data2")
    }),
    types.DeferProp("data3", option.Some("group2"), fn() {
      MessageProp("Data3")
    }),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  assert list.length(page.props) == 1
  // only user
  assert page.deferred_props
    == option.Some(
      dict.from_list([#("group1", ["data1", "data2"]), #("group2", ["data3"])]),
    )
}

pub fn eval_multiple_prop_types_test() {
  let req = testing.inertia_request()

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.LazyProp("settings", fn() { SettingsProp(True) }),
    types.AlwaysProp("count", CountProp(42)),
    types.MergeProp(
      types.DefaultProp("merged", MessageProp("Merged")),
      option.None,
    ),
  ]

  let page = inertia.eval(req, "ComplexPage", props, encode_test_prop)

  assert list.length(page.props) == 4
  assert page.component == "ComplexPage"
}

pub fn eval_partial_data_without_component_header_test() {
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user", "settings"])
  // No component header set

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.LazyProp("settings", fn() { SettingsProp(True) }),
    types.OptionalProp("meta", fn() { MetaProp("v1.0") }),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // Partial data present but no component header = no partial reload
  // Should behave like standard Inertia request (exclude optional props)
  assert list.length(page.props) == 3
  // user, settings, count (meta excluded because it's optional)
}

pub fn eval_deferred_prop_evaluated_on_partial_reload_test() {
  // First request - deferred prop is not evaluated, just listed in deferred_props
  let req = testing.inertia_request()

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.DeferProp("analytics", option.None, fn() {
      MessageProp("Analytics Data")
    }),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // Initial request: analytics not evaluated, just in deferred list
  assert list.length(page.props) == 2
  // user, count
  assert page.deferred_props
    == option.Some(dict.from_list([#("default", ["analytics"])]))

  // Second request - partial reload requesting the deferred prop
  let deferred_req =
    testing.inertia_request()
    |> testing.partial_data(["analytics"])
    |> testing.partial_component("HomePage")

  let deferred_page =
    inertia.eval(deferred_req, "HomePage", props, encode_test_prop)

  // Deferred request: analytics is now evaluated and included in props
  assert list.length(deferred_page.props) == 2
  // analytics, count (always)
  assert deferred_page.deferred_props == option.None
  // partial reloads don't return deferred_props

  // Verify the deferred prop was actually evaluated
  assert list.contains(deferred_page.props, MessageProp("Analytics Data"))
  assert list.contains(deferred_page.props, CountProp(42))
}

pub fn eval_deferred_prop_not_included_unless_requested_test() {
  // Partial reload requesting only "user" but not the deferred prop
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user"])
    |> testing.partial_component("HomePage")

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.DeferProp("analytics", option.None, fn() {
      MessageProp("Analytics Data")
    }),
    types.AlwaysProp("count", CountProp(42)),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // Should only include requested "user" plus always "count"
  // Should NOT include unrequested deferred "analytics"
  assert list.length(page.props) == 2
  // user, count
  assert page.deferred_props == option.None
  // no deferred props in partial reload

  // Verify the analytics prop was NOT evaluated
  assert list.contains(page.props, UserProp("John"))
  assert list.contains(page.props, CountProp(42))
  assert !list.contains(page.props, MessageProp("Analytics Data"))
}

pub fn eval_merge_prop_always_in_partial_reload_test() {
  // Partial reload requesting only "user" but not the merged always prop
  let req =
    testing.inertia_request()
    |> testing.partial_data(["user"])
    |> testing.partial_component("HomePage")

  let props = [
    types.DefaultProp("user", UserProp("John")),
    types.MergeProp(types.AlwaysProp("count", CountProp(42)), option.None),
  ]

  let page = inertia.eval(req, "HomePage", props, encode_test_prop)

  // MergeProp(AlwaysProp) should be included even if not requested
  assert list.length(page.props) == 2
  // user, count
  assert page.deferred_props == option.None

  // Verify both props are present
  assert list.contains(page.props, UserProp("John"))
  assert list.contains(page.props, CountProp(42))
}

pub fn eval_errors_field_test() {
  let req = testing.inertia_request()
  let props = [types.DefaultProp("user", UserProp("John"))]

  // Test page without errors
  let page_no_errors = inertia.eval(req, "HomePage", props, encode_test_prop)
  assert page_no_errors.errors == option.None

  // Test page with errors
  let errors =
    dict.from_list([
      #("email", "Email is required"),
      #("name", "Name too short"),
    ])
  let page_with_errors =
    types.Page(..page_no_errors, errors: option.Some(errors))
  assert page_with_errors.errors == option.Some(errors)

  // Test JSON encoding - errors should be in props when present
  let json_with_errors = types.encode_page(page_with_errors)
  let json_no_errors = types.encode_page(page_no_errors)

  // Both should have component, url, etc. but only one should have errors in props
  // This is a basic structural test - more detailed JSON testing would need JSON parsing
  assert json_with_errors != json_no_errors
}
