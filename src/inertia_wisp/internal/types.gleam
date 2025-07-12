import gleam/json
import gleam/list
import gleam/option

/// Represents an Inertia.js page object that will be sent to the client.
///
/// This is the core data structure that contains all the information needed
/// to render a component on the frontend, including the component name,
/// props, URL, version info, and history management flags.
pub type Page(prop) {
  Page(
    component: String,
    props: List(prop),
    deferred_props: List(String),
    encode_prop: fn(prop) -> #(String, json.Json),
    url: String,
    version: String,
    encrypt_history: Bool,
    clear_history: Bool,
  )
}

/// Encode a Page object to JSON
pub fn encode_page(page: Page(prop)) -> json.Json {
  json.object([
    #("component", json.string(page.component)),
    #("props", page.props |> list.map(page.encode_prop) |> json.object),
    #("deferredProps", page.deferred_props |> json.array(json.string)),
    #("url", json.string(page.url)),
    #("version", json.string(page.version)),
    #("encryptHistory", json.bool(page.encrypt_history)),
    #("clearHistory", json.bool(page.clear_history)),
  ])
}

/// Inertia Prop types for Resolvers
pub type Prop(p) {
  /// ALWAYS included on standard visits
  /// OPTIONALLY included on partial reloads
  /// ALWAYS evaluated
  DefaultProp(name: String, value: p)

  /// ALWAYS included on standard visits
  /// OPTIONALLY included on partial reloads
  /// ONLY evaluated when needed
  LazyProp(name: String, resolver: fn() -> p)

  /// NEVER included on standard visits
  /// OPTIONALLY included on partial reloads
  /// ONLY evaluated when needed
  OptionalProp(name: String, resolver: fn() -> p)

  /// ALWAYS included on standard visits
  /// ALWAYS included on partial reloads
  /// ALWAYS evaluated
  AlwaysProp(name: String, value: p)

  /// A LazyProp fetched in a separate request sent from the client
  /// A group name can be optionally supplied to fetch deferred props in multiple separate requests.
  DeferProp(name: String, group: option.Option(String), resolver: fn() -> p)

  /// Indicates that a Prop should be merged client-side
  /// During the merging process, if the value is an array, the incoming items will be appended to the existing array, not merged by index.
  /// However, you may provide a list of attribute names in `match_on` to determine how existing items should be matched and updated.
  MergeProp(prop: Prop(p), match_on: option.Option(List(String)))
}

/// Configuration for the Inertia adapter
pub type ConfigOpt {
  Version(String)
  SSR(Bool)
  EncryptHistory(Bool)
}

pub type Config =
  List(ConfigOpt)
