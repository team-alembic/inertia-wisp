/**
 * Clean re-exports for Stock ticker types and accessors
 * Provides readable names for Gleam-compiled types
 */

import {
  decode_stock_ticker_props,
  type StockTickerProps$,
  StockTickerProps$StockTickerProps$stocks,
  StockTickerProps$StockTickerProps$price_points,
  StockTickerProps$StockTickerProps$info_message,
  type Stock$,
  Stock$Stock$symbol,
  Stock$Stock$name,
  Stock$Stock$price,
  Stock$Stock$change,
  Stock$Stock$percent_change,
  Stock$Stock$last_update,
  type PricePoint$,
  PricePoint$PricePoint$symbol,
  PricePoint$PricePoint$timestamp,
  PricePoint$PricePoint$price,
  type StockWithHistory$,
  StockWithHistory$StockWithHistory$stock,
  StockWithHistory$StockWithHistory$price_history,
  group_price_points_by_symbol,
  combine_stocks_with_history,
} from "@shared/stock.mjs";

// Type exports
export type StockTickerProps = StockTickerProps$;
export type Stock = Stock$;
export type PricePoint = PricePoint$;
export type StockWithHistory = StockWithHistory$;

// Decoder
export const decodeStockTickerProps = decode_stock_ticker_props;

// StockTickerProps accessors
export const getStocks = StockTickerProps$StockTickerProps$stocks;
export const getPricePoints = StockTickerProps$StockTickerProps$price_points;
export const getInfoMessage = StockTickerProps$StockTickerProps$info_message;

// Stock accessors
export const getSymbol = Stock$Stock$symbol;
export const getName = Stock$Stock$name;
export const getPrice = Stock$Stock$price;
export const getChange = Stock$Stock$change;
export const getPercentChange = Stock$Stock$percent_change;
export const getLastUpdate = Stock$Stock$last_update;

// PricePoint accessors
export const getPricePointSymbol = PricePoint$PricePoint$symbol;
export const getPricePointTimestamp = PricePoint$PricePoint$timestamp;
export const getPricePointPrice = PricePoint$PricePoint$price;

// StockWithHistory accessors
export const getStockFromHistory = StockWithHistory$StockWithHistory$stock;
export const getPriceHistory = StockWithHistory$StockWithHistory$price_history;

// Utility functions
export const groupPricePointsBySymbol = group_price_points_by_symbol;
export const combineStocksWithHistory = combine_stocks_with_history;
