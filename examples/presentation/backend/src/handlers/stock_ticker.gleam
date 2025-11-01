//// Stock ticker handler
////
//// Demonstrates Inertia's polling feature with merge props for smooth updates
//// Uses shared Gleam module compiled to JavaScript for type safety

import gleam/dict
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import inertia_wisp/inertia
import shared/stock
import wisp.{type Request, type Response}

/// Encode stock ticker props to JSON dict
pub fn encode_props(
  props: stock.StockTickerProps,
) -> dict.Dict(String, json.Json) {
  dict.from_list(
    list.flatten([
      case props.stocks {
        Some(stocks) -> [#("stocks", json.array(stocks, stock.encode_stock))]
        _ -> []
      },
      [#("info_message", json.string(props.info_message))],
    ]),
  )
}

/// Stock definitions with base prices
const stock_definitions = [
  #("AAPL", "Apple Inc.", 175.0),
  #("GOOGL", "Alphabet Inc.", 140.0),
  #("MSFT", "Microsoft Corp.", 380.0),
  #("AMZN", "Amazon.com Inc.", 145.0),
  #("TSLA", "Tesla Inc.", 245.0),
  #("META", "Meta Platforms", 485.0),
]

/// Display the stock ticker page with live updating stock prices
pub fn show_stock_ticker(req: Request) -> Response {
  // Get current timestamp
  let timestamp = stock.current_timestamp()

  // Generate stock data with simulated price changes
  // Frontend accumulates history from these snapshots!
  let stocks =
    list.map(stock_definitions, fn(def) {
      let #(symbol, name, base_price) = def
      stock.generate_stock(symbol, name, base_price, timestamp)
    })
    |> Some

  let props =
    stock.StockTickerProps(
      stocks: stocks,
      info_message: "📊 React accumulates price history from polling updates! Watch the sparklines grow.",
    )

  req
  |> inertia.response_builder("StockTicker")
  |> inertia.props(props, encode_props)
  |> inertia.response(200)
}
