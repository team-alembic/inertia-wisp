//// Tests for stock ticker handler
////
//// Tests JSON encoding/decoding round-trip for StockTickerProps

import gleam/dict
import gleam/json
import gleam/list
import gleeunit
import handlers/stock_ticker
import shared/stock

pub fn main() {
  gleeunit.main()
}

// StockTickerProps round-trip tests

pub fn stock_ticker_props_round_trip_test() {
  let stocks = [
    stock.Stock(
      symbol: "AAPL",
      name: "Apple Inc.",
      price: 150.25,
      change: 2.5,
      percent_change: 1.69,
      last_update: 1_730_491_200,
    ),
    stock.Stock(
      symbol: "GOOGL",
      name: "Alphabet Inc.",
      price: 2800.75,
      change: -15.25,
      percent_change: -0.54,
      last_update: 1_730_491_200,
    ),
  ]

  let original =
    stock.StockTickerProps(stocks: stocks, info_message: "Test message")

  // Encode to JSON dict, then to string
  let json_dict = stock_ticker.encode_props(original)
  let json_obj = json.object(dict.to_list(json_dict))
  let json_string = json.to_string(json_obj)

  // Parse JSON string back and decode
  let assert Ok(decoded) =
    json.parse(json_string, stock.decode_stock_ticker_props())

  // Verify info_message
  assert decoded.info_message == original.info_message

  // Verify stocks list
  assert list.length(decoded.stocks) == 2

  // Verify first stock
  let assert [first, second] = decoded.stocks
  assert first.symbol == "AAPL"
  assert first.name == "Apple Inc."
  assert first.price == 150.25

  // Verify second stock
  assert second.symbol == "GOOGL"
  assert second.name == "Alphabet Inc."
  assert second.price == 2800.75
}
