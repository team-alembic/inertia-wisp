/**
 * Clean re-exports for Stock ticker types and accessors
 * Provides readable names for Gleam-compiled types
 */

import {
  decode_stock_ticker_props,
  type StockTickerProps$,
  StockTickerProps$StockTickerProps$stocks,
  StockTickerProps$StockTickerProps$info_message,
  type Stock$,
  Stock$Stock$symbol,
  Stock$Stock$name,
  Stock$Stock$price,
  Stock$Stock$change,
  Stock$Stock$percent_change,
  Stock$Stock$last_update,
} from "@shared/stock.mjs";

// Type exports
export type StockTickerProps = StockTickerProps$;
export type Stock = Stock$;

// Decoder
export const decodeStockTickerProps = decode_stock_ticker_props;

// StockTickerProps accessors
export const getStocks = StockTickerProps$StockTickerProps$stocks;
export const getInfoMessage = StockTickerProps$StockTickerProps$info_message;

// Stock accessors
export const getSymbol = Stock$Stock$symbol;
export const getName = Stock$Stock$name;
export const getPrice = Stock$Stock$price;
export const getChange = Stock$Stock$change;
export const getPercentChange = Stock$Stock$percent_change;
export const getLastUpdate = Stock$Stock$last_update;
