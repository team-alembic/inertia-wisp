import gleam/dict.{type Dict}
import gleam/json

/// Represents an Inertia.js page object
/// Page data to be sent to the client
pub type Page {
  Page(
    component: String,
    props: Dict(String, json.Json),
    url: String,
    version: String,
  )
}

/// Prop value that can be either eager or lazy
pub type PropValue {
  EagerProp(value: json.Json)
  LazyProp(evaluate: fn() -> json.Json)
}

/// Configuration for the Inertia adapter
pub type Config {
  Config(version: String, ssr: Bool, always_props: Dict(String, PropValue))
}

/// Internal request state for Inertia processing
/// State to track Inertia request information
pub type InertiaState {
  InertiaState(
    is_inertia: Bool,
    partial_data: List(String),
    props: Dict(String, PropValue),
  )
}

/// Default configuration
pub fn default_config() -> Config {
  Config(version: "1", ssr: False, always_props: dict.new())
}

/// Create a new page object
pub fn new_page(
  component: String,
  props: Dict(String, json.Json),
  url: String,
  version: String,
) -> Page {
  Page(component: component, props: props, url: url, version: version)
}

/// Create initial Inertia state
/// Create initial state for Inertia processing
pub fn initial_state() -> InertiaState {
  InertiaState(is_inertia: False, partial_data: [], props: dict.new())
}
