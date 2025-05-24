import gleam/json
import gleam/dict.{type Dict}

/// Represents an Inertia.js page object
pub type Page {
  Page(
    component: String,
    props: Dict(String, json.Json),
    url: String,
    version: String,
  )
}

/// Configuration for the Inertia adapter
pub type Config {
  Config(
    version: String,
    ssr: Bool,
  )
}

/// Internal request state for Inertia processing
pub type InertiaState {
  InertiaState(
    is_inertia: Bool,
    partial_data: List(String),
    props: Dict(String, json.Json),
    config: Config,
  )
}

/// Default configuration
pub fn default_config() -> Config {
  Config(version: "1", ssr: False)
}

/// Create a new page object
pub fn new_page(component: String, props: Dict(String, json.Json), url: String, version: String) -> Page {
  Page(component: component, props: props, url: url, version: version)
}

/// Create initial Inertia state
pub fn initial_state(config: Config) -> InertiaState {
  InertiaState(
    is_inertia: False,
    partial_data: [],
    props: dict.new(),
    config: config,
  )
}