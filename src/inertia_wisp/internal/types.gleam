import gleam/dict
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
    errors: option.Option(dict.Dict(String, String)),
    deferred_props: option.Option(dict.Dict(String, List(String))),
    merge_props: option.Option(List(String)),
    deep_merge_props: option.Option(List(String)),
    match_props_on: option.Option(List(String)),
    encode_prop: fn(prop) -> #(String, json.Json),
    url: String,
    version: String,
    encrypt_history: Bool,
    clear_history: Bool,
  )
}

/// Reduce an Option value with an accumulator
fn option_reduce(opt: option.Option(a), acc: b, reducer: fn(a, b) -> b) -> b {
  case opt {
    option.Some(value) -> reducer(value, acc)
    option.None -> acc
  }
}

fn maybe_prepend(
  opt: option.Option(a),
  acc: List(b),
  mapper: fn(a) -> b,
) -> List(b) {
  option_reduce(opt, acc, fn(v, acc) { list.prepend(acc, mapper(v)) })
}

/// Encode a Page object to JSON
pub fn encode_page(page: Page(prop)) -> json.Json {
  let props_object =
    page.props
    |> list.map(page.encode_prop)
    |> maybe_prepend(page.errors, _, fn(errors_dict) {
      #(
        "errors",
        errors_dict
          |> dict.to_list()
          |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })
          |> json.object(),
      )
    })
    |> json.object

  [
    #("component", json.string(page.component)),
    #("props", props_object),
    #("url", json.string(page.url)),
    #("version", json.string(page.version)),
    #("encryptHistory", json.bool(page.encrypt_history)),
    #("clearHistory", json.bool(page.clear_history)),
  ]
  |> maybe_prepend(page.deferred_props, _, fn(deferred_dict) {
    #(
      "deferredProps",
      deferred_dict
        |> dict.to_list()
        |> list.map(fn(pair) { #(pair.0, json.array(pair.1, json.string)) })
        |> json.object(),
    )
  })
  |> maybe_prepend(page.merge_props, _, fn(merge_list) {
    #("mergeProps", json.array(merge_list, json.string))
  })
  |> maybe_prepend(page.deep_merge_props, _, fn(deep_merge_list) {
    #("deepMergeProps", json.array(deep_merge_list, json.string))
  })
  |> maybe_prepend(page.match_props_on, _, fn(match_list) {
    #("matchPropsOn", json.array(match_list, json.string))
  })
  |> json.object
}

/// Configuration for the Inertia adapter
pub type ConfigOpt {
  Version(String)
  SSR(Bool)
  EncryptHistory(Bool)
}

pub type Config =
  List(ConfigOpt)
