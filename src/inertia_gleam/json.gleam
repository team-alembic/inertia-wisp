import gleam/dict
import gleam/json
import inertia_gleam/types.{type Page}

/// Encode a Page object to JSON
pub fn encode_page(page: Page) -> json.Json {
  json.object([
    #("component", json.string(page.component)),
    #("props", json.object(dict.to_list(page.props))),
    #("url", json.string(page.url)),
    #("version", json.string(page.version)),
  ])
}
