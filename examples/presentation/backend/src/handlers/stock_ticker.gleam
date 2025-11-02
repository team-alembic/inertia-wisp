//// Stock ticker handler
////
//// Demonstrates Inertia's polling feature with merge props for smooth updates
//// Uses shared Gleam module compiled to JavaScript for type safety

import gleam/dict
import gleam/json
import gleam/list
import gleam/option
import inertia_wisp/inertia
import shared/stock
import wisp.{type Request, type Response}

/// Encode stock ticker props to JSON dict
pub fn encode_props(
  props: stock.StockTickerProps,
) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("stocks", json.array(props.stocks, stock.encode_stock)),
    #("price_points", json.array(props.price_points, stock.encode_price_point)),
    #("info_message", json.string(props.info_message)),
  ])
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
  let stocks =
    list.map(stock_definitions, fn(def) {
      let #(symbol, name, base_price) = def
      stock.generate_stock(symbol, name, base_price, timestamp)
    })

  // Generate price points (one per stock) - these will accumulate via merge
  let price_points =
    list.map(stocks, fn(s) {
      stock.PricePoint(
        symbol: s.symbol,
        timestamp: s.last_update,
        price: s.price,
      )
    })

  let props =
    stock.StockTickerProps(
      stocks: stocks,
      price_points: price_points,
      info_message: "📊 Inertia.js accumulates price_points via mergeProps! Watch the sparklines grow.",
    )

  req
  |> inertia.response_builder("StockTicker")
  |> inertia.props(props, encode_props)
  |> inertia.merge("price_points", option.None, False)
  |> inertia.response(200)
}
