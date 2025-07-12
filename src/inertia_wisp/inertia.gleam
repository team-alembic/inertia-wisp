//// Inertia.js adapter for the Gleam Wisp web framework.

import gleam/dict
import gleam/json
import gleam/list
import gleam/option
import gleam/string
import gleam/string_tree
import inertia_wisp/internal/html
import inertia_wisp/internal/middleware
import inertia_wisp/internal/types.{type Page}
import wisp.{type Request, type Response}

pub fn render(req: Request, page: Page(prop)) -> Response {
  case middleware.is_inertia_request(req) {
    True -> render_json_response(page)
    False -> render_html_response(page)
  }
}

fn render_json_response(page: Page(prop)) -> Response {
  let json_body = types.encode_page(page) |> json.to_string()

  json_body
  |> string_tree.from_string()
  |> wisp.json_response(200)
  |> middleware.add_inertia_headers()
}

fn render_html_response(page: Page(prop)) -> Response {
  let html_body = html.root_template(page, page.component)
  wisp.html_response(string_tree.from_string(html_body), 200)
}

pub fn external_redirect(url: String) -> Response {
  wisp.response(409)
  |> wisp.set_header("x-inertia-location", url)
}

/// Evaluates a list of props for an Inertia request and returns a Page.
///
/// This function processes the provided props and creates a Page instance
/// that can be rendered as either JSON (for Inertia requests) or HTML
/// (for initial page loads).
///
/// ## Parameters
///
/// - `req`: The incoming HTTP request
/// - `component`: The name of the component to render
/// - `props`: A list of properties to be evaluated and included in the page
/// - `encode_prop`: Function to encode a prop to a name/JSON pair
///
/// ## Returns
///
/// Returns a `Page(p)` where `p` is the type of the props being evaluated.
///
/// ## Example
///
/// ```gleam
/// let props = [
///   DefaultProp("user", user_data ),
///   OptionalProp("settings", fn() { user_settings }),
/// ]
/// let page = eval(req, "HomePage", props, encode_prop_fn)
/// ```
pub fn eval(
  req: Request,
  component: String,
  props: List(types.Prop(p)),
  encode_prop: fn(p) -> #(String, json.Json),
) -> Page(p) {
  let partial_data = middleware.get_partial_data(req)
  let partial_component = middleware.get_partial_component(req)

  // For partial reloads, only proceed if component matches.
  // This is a safety requirement from the Inertia.js protocol: partial reloads only work
  // when the client is still on the same page component. If the user has navigated away
  // (e.g., was logged out and redirected to login), the component won't match and we
  // must fall back to a full reload to ensure data consistency and prevent stale UI state.
  let should_partial =
    partial_data != [] && option.Some(component) == partial_component

  let #(evaluated_props, deferred_props) =
    props
    |> filter_props_for_request(should_partial, partial_data)
    |> evaluate_and_separate_props(should_partial)

  let url = build_url_from_request(req)

  types.Page(
    component: component,
    props: evaluated_props,
    errors: option.None,
    deferred_props: deferred_props,
    merge_props: option.None,
    deep_merge_props: option.None,
    match_props_on: option.None,
    encode_prop: encode_prop,
    url: url,
    version: "1",
    encrypt_history: False,
    clear_history: False,
  )
}

/// Filter props based on request type and partial reload settings
fn filter_props_for_request(
  props: List(types.Prop(p)),
  is_partial: Bool,
  partial_data: List(String),
) -> List(types.Prop(p)) {
  let predicate = case is_partial {
    False -> is_non_partial_prop
    True -> is_partial_prop(_, partial_data)
  }
  props |> list.filter(predicate)
}

/// Predicate for non-partial requests (initial page load and standard Inertia)
/// Include all non-optional props
/// OptionalProp: Excluded because they're only meant for partial reloads when explicitly requested
/// DeferProp: Retained here so evaluate_and_separate_props can move them to the deferred_props list
fn is_non_partial_prop(prop: types.Prop(p)) -> Bool {
  case prop {
    types.OptionalProp(_, _) -> False
    types.MergeProp(inner_prop, _) -> is_non_partial_prop(inner_prop)
    _ -> True
  }
}

/// Predicate for partial reload requests
/// Include only requested props plus always props and deferred
fn is_partial_prop(prop: types.Prop(p), partial_data: List(String)) -> Bool {
  case prop {
    types.AlwaysProp(_, _) -> True
    types.MergeProp(inner_prop, _) -> is_partial_prop(inner_prop, partial_data)
    _ -> list.contains(partial_data, prop_name(prop))
  }
}

type PropEval(p) {
  Value(value: p)
  Defer(name: String, group: option.Option(String))
}

/// Evaluate props and separate into evaluated props and deferred prop names
fn evaluate_and_separate_props(
  props: List(types.Prop(p)),
  is_partial: Bool,
) -> #(List(p), option.Option(dict.Dict(String, List(String)))) {
  let #(evaluated, deferred_groups) =
    props
    |> list.fold(#([], dict.new()), fn(acc, prop) {
      let #(eval_acc, defer_acc) = acc
      case evaluate_prop(prop, is_partial) {
        Value(value) -> #([value, ..eval_acc], defer_acc)
        Defer(name, group) -> {
          let group_name = option.unwrap(group, "default")
          let current_props =
            dict.get(defer_acc, group_name)
            |> option.from_result()
            |> option.unwrap([])
          let updated_props = [name, ..current_props]
          #(eval_acc, dict.insert(defer_acc, group_name, updated_props))
        }
      }
    })

  let final_deferred = case dict.is_empty(deferred_groups) {
    True -> option.None
    False ->
      option.Some(
        deferred_groups |> dict.map_values(fn(_, v) { list.reverse(v) }),
      )
  }

  #(list.reverse(evaluated), final_deferred)
}

/// Evaluate a single prop and return its evaluation result
fn evaluate_prop(prop: types.Prop(p), is_partial: Bool) -> PropEval(p) {
  case prop {
    types.DefaultProp(_, value) -> Value(value)
    types.LazyProp(_, resolver) -> Value(resolver())
    types.OptionalProp(_, resolver) -> Value(resolver())
    types.AlwaysProp(_, value) -> Value(value)
    types.DeferProp(name, group, resolver) ->
      case is_partial {
        True -> Value(resolver())
        False -> Defer(name, group)
      }
    types.MergeProp(inner_prop, _) -> evaluate_prop(inner_prop, is_partial)
  }
}

/// Extract the name from a prop
fn prop_name(prop: types.Prop(p)) -> String {
  case prop {
    types.DefaultProp(name, _) -> name
    types.LazyProp(name, _) -> name
    types.OptionalProp(name, _) -> name
    types.AlwaysProp(name, _) -> name
    types.DeferProp(name, _, _) -> name
    types.MergeProp(inner_prop, _) -> prop_name(inner_prop)
  }
}

/// Build URL from request path segments
fn build_url_from_request(req: Request) -> String {
  let path = wisp.path_segments(req) |> string.join("/")
  "/" <> path
}
// type Product {
//   Product(
//     id: String,
//     title: String,
//     description: String,
//     price: Int,
//     currency: String,
//   )
// }

// fn product_to_json(product: Product) -> json.Json {
//   let Product(id:, title:, description:, price:, currency:) = product
//   json.object([
//     #("id", json.string(id)),
//     #("title", json.string(title)),
//     #("description", json.string(description)),
//     #("price", json.int(price)),
//     #("currency", json.string(currency)),
//   ])
// }

// type ProductPageProp {
//   ProductProp(product: Product)
//   InStockProp(in_stock: Bool)
//   DiscountProp(discount: Int)
// }

// const product = "product"

// const in_stock = "in_stock"

// const discount = "discount"

// fn product_page_prop_to_json(
//   product_page_prop: ProductPageProp,
// ) -> #(String, json.Json) {
//   case product_page_prop {
//     ProductProp(p) -> #(product, product_to_json(p))
//     InStockProp(x) -> #(in_stock, json.bool(x))
//     DiscountProp(x) -> #(in_stock, json.int(x))
//   }
// }

// pub fn scratch(req: Request) {
//   let default_component = "Home"
//   let default_props = [product, in_stock]
//   let deferred_props = [discount]

//   let #(component, props) =
//     req
//     |> inertia.component_and_props(req, default_component, default_props)
//   let props = [
//     Default(product, fn() {
//       ProductProp(product: Product(
//         id: "1",
//         title: "Product Title",
//         description: "Product Description",
//         price: 100,
//         currency: "USD",
//       ))
//     }),
//     Optional(in_stock, fn() { InStockProp(in_stock: True) }),
//     Always(discount, fn() { DiscountProp(discount: 10) }),
//     Defer(onSale, fn() { DiscountProp(discount: 10) }))
//   ]

//   req
//   |> inertia.page(
//     resolvers,
//     product_page_prop_to_json,
//     default_props,
//     always_props,
//     optional_props,
//     deferred_props,
//   )

//   let page =
//     types.Page(
//       component: component,
//       props: list.map(props, fn(p) {
//         dict.get(resolver, p) |> result.lazy_unwrap(fn() { todo })
//       }),
//       encode_prop: product_page_prop_to_json,
//       deferred_props: [discount],
//       url: "/" <> wisp.path_segments(req) |> string.join("/"),
//       version: "asdf",
//       encrypt_history: False,
//       clear_history: False,
//     )
// }
