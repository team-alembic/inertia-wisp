//// Stock data types and schema
////
//// This module is compiled to JavaScript and used directly by TypeScript.
//// Demonstrates Approach #1: Compile Gleam → JavaScript

import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, Some}

/// Stock market data - only current price, frontend accumulates history
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
  StockTickerProps(stocks: Option(List(Stock)), info_message: String)
}

/// Decode StockTickerProps from dynamic data (for use in TypeScript)
pub fn decode_stock_ticker_props() -> decode.Decoder(StockTickerProps) {
  use stocks <- decode.optional_field(
    "stocks",
    option.None,
    decode.list(decode_stock()) |> decode.map(option.Some),
  )
  use info_message <- decode.field("info_message", decode.string)
  decode.success(StockTickerProps(stocks:, info_message:))
}

/// Encode StockTickerProps to JSON
pub fn encode_stock_ticker_props(props: StockTickerProps) -> json.Json {
  json.object(
    list.flatten([
      case props.stocks {
        Some(stocks) -> [#("stocks", json.array(stocks, encode_stock))]
        _ -> []
      },
      [#("info_message", json.string(props.info_message))],
    ]),
  )
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
