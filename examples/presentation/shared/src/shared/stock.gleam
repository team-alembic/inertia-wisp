//// Stock data types and schema
////
//// This module is compiled to JavaScript and used directly by TypeScript.
//// Demonstrates Approach #1: Compile Gleam → JavaScript

import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{None, Some}

/// Price point for history tracking
pub type PricePoint {
  PricePoint(symbol: String, timestamp: Int, price: Float)
}

/// Stock market data (current state only)
pub type Stock {
  Stock(
    symbol: String,
    name: String,
    price: Float,
    change: Float,
    percent_change: Float,
    last_update: Int,
  )
}

/// Stock combined with its price history
pub type StockWithHistory {
  StockWithHistory(stock: Stock, price_history: List(PricePoint))
}

/// Decode a PricePoint from dynamic data
pub fn decode_price_point() -> decode.Decoder(PricePoint) {
  use symbol <- decode.field("symbol", decode.string)
  use timestamp <- decode.field("timestamp", decode.int)
  use price <- decode.field("price", decode.float)
  decode.success(PricePoint(symbol:, timestamp:, price:))
}

/// Decode a Stock from dynamic data (for use in TypeScript)
pub fn decode_stock() -> decode.Decoder(Stock) {
  use symbol <- decode.field("symbol", decode.string)
  use name <- decode.field("name", decode.string)
  use price <- decode.field("price", decode.float)
  use change <- decode.field("change", decode.float)
  use percent_change <- decode.field("percent_change", decode.float)
  use last_update <- decode.field("last_update", decode.int)
  decode.success(Stock(
    symbol:,
    name:,
    price:,
    change:,
    percent_change:,
    last_update:,
  ))
}

/// Encode a PricePoint to JSON
pub fn encode_price_point(point: PricePoint) -> json.Json {
  json.object([
    #("symbol", json.string(point.symbol)),
    #("timestamp", json.int(point.timestamp)),
    #("price", json.float(point.price)),
  ])
}

/// Encode a Stock to JSON
pub fn encode_stock(stock: Stock) -> json.Json {
  json.object([
    #("symbol", json.string(stock.symbol)),
    #("name", json.string(stock.name)),
    #("price", json.float(stock.price)),
    #("change", json.float(stock.change)),
    #("percent_change", json.float(stock.percent_change)),
    #("last_update", json.int(stock.last_update)),
  ])
}

/// Props for the stock ticker page
pub type StockTickerProps {
  StockTickerProps(
    stocks: List(Stock),
    price_points: List(PricePoint),
    info_message: String,
  )
}

/// Decode StockTickerProps from dynamic data (for use in TypeScript)
pub fn decode_stock_ticker_props() -> decode.Decoder(StockTickerProps) {
  use stocks <- decode.field("stocks", decode.list(decode_stock()))
  use price_points <- decode.field(
    "price_points",
    decode.list(decode_price_point()),
  )
  use info_message <- decode.field("info_message", decode.string)
  decode.success(StockTickerProps(stocks:, price_points:, info_message:))
}

/// Encode StockTickerProps to JSON
pub fn encode_stock_ticker_props(props: StockTickerProps) -> json.Json {
  json.object([
    #("stocks", json.array(props.stocks, encode_stock)),
    #("price_points", json.array(props.price_points, encode_price_point)),
    #("info_message", json.string(props.info_message)),
  ])
}

import gleam/float
import gleam/time/timestamp

/// Get current timestamp in seconds since Unix epoch
pub fn current_timestamp() -> Int {
  timestamp.system_time()
  |> timestamp.to_unix_seconds
  |> float.round
}

/// Create a stock with random price movement
pub fn generate_stock(
  symbol: String,
  name: String,
  base_price: Float,
  timestamp: Int,
) -> Stock {
  // Simulate random price movement (-2% to +2%)
  // Generate random number between -50 and 50
  let random_value = int.random(101) - 50
  let change_percent = int.to_float(random_value) /. 2500.0
  let change_amount = base_price *. change_percent
  let new_price = base_price +. change_amount

  Stock(
    symbol: symbol,
    name: name,
    price: new_price,
    change: change_amount,
    percent_change: change_percent *. 100.0,
    last_update: timestamp,
  )
}

/// Group price points by symbol
/// Returns a dictionary mapping symbol -> list of price points
/// Sorts by timestamp (chronological) and keeps only the last 30 points
pub fn group_price_points_by_symbol(
  price_points: List(PricePoint),
) -> Dict(String, List(PricePoint)) {
  list.fold(price_points, dict.new(), fn(acc, point) {
    dict.upsert(acc, point.symbol, fn(existing) {
      case existing {
        Some(points) -> {
          // Add new point, sort by timestamp, keep last 30
          [point, ..points]
          |> list.sort(fn(a, b) { int.compare(a.timestamp, b.timestamp) })
          |> list.reverse
          |> list.take(30)
          |> list.reverse
        }
        None -> [point]
      }
    })
  })
}

/// Combine stocks with their price history
/// Groups price_points by symbol and attaches to each stock
pub fn combine_stocks_with_history(
  stocks: List(Stock),
  price_points: List(PricePoint),
) -> List(StockWithHistory) {
  let history_by_symbol = group_price_points_by_symbol(price_points)

  list.map(stocks, fn(stock) {
    let price_history = case dict.get(history_by_symbol, stock.symbol) {
      Ok(points) -> points
      Error(_) -> []
    }
    StockWithHistory(stock: stock, price_history: price_history)
  })
}
