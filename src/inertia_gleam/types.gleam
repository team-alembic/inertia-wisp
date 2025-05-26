import gleam/dict.{type Dict}
import gleam/json
import wisp

/// Represents an Inertia.js page object
/// Page data to be sent to the client
pub type Page {
  Page(
    component: String,
    props: Dict(String, json.Json),
    url: String,
    version: String,
    encrypt_history: Bool,
    clear_history: Bool,
  )
}

/// Encode a Page object to JSON
pub fn encode_page(page: Page) -> json.Json {
  json.object([
    #("component", json.string(page.component)),
    #("props", json.object(dict.to_list(page.props))),
    #("url", json.string(page.url)),
    #("version", json.string(page.version)),
    #("encryptHistory", json.bool(page.encrypt_history)),
    #("clearHistory", json.bool(page.clear_history)),
  ])
}

/// Prop value that can be either eager or lazy
pub type PropValue {
  EagerProp(value: json.Json)
  LazyProp(evaluate: fn() -> json.Json)
}

/// Configuration for the Inertia adapter
pub type Config {
  Config(
    version: String,
    ssr: Bool,
    always_props: Dict(String, PropValue),
    encrypt_history: Bool,
  )
}

/// Default configuration
pub fn default_config() -> Config {
  Config(
    version: "1",
    ssr: False,
    always_props: dict.new(),
    encrypt_history: False,
  )
}

/// Context wrapper for building up props before rendering
pub type InertiaContext {
  InertiaContext(
    config: Config,
    request: wisp.Request,
    props: Dict(String, PropValue),
    always_props: Dict(String, PropValue),
    encrypt_history: Bool,
    clear_history: Bool,
  )
}

pub fn new_context(config, request) {
  InertiaContext(
    config: config,
    request: request,
    props: dict.new(),
    always_props: dict.new(),
    encrypt_history: config.encrypt_history,
    clear_history: False,
  )
}
