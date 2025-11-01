import { useEffect, useState } from "react";
import { usePoll } from "@inertiajs/react";
import {
  decode_stock_ticker_props,
  type StockTickerProps$,
  Stock$Stock$symbol as getSymbol,
  Stock$Stock$name as getName,
  Stock$Stock$price as getPrice,
  Stock$Stock$change as getChange,
  Stock$Stock$percent_change as getPercentChange,
  Stock$Stock$last_update as getLastUpdate,
  StockTickerProps$StockTickerProps$stocks as getStocks,
  StockTickerProps$StockTickerProps$info_message as getInfoMessage,
  Stock$,
} from "@shared/stock.mjs";
import {
  Option$isSome,
  Option$Some$0,
} from "@gleam/gleam_stdlib/gleam/option.mjs";
import { PageHeader, BackToPresentation } from "../components";
import { decodeProps } from "../lib/decodeProps";

type PricePoint = {
  price: number;
  timestamp: number;
};

type StockWithHistory = {
  stock: Stock$;
  price_history: PricePoint[];
};

function StockTicker(props: StockTickerProps$) {
  // Use Inertia's polling hook - polls every 2 seconds
  // Only fetch stocks, not the info_message which doesn't change
  usePoll(1000, { only: ["stocks"] });

  // Extract props using accessor functions
  const stocks = getStocks(props);
  const info_message = getInfoMessage(props);

  // Extract the List from Some and convert to JavaScript array using spread operator
  const stocksList = Option$Some$0(stocks);
  const stocksArray = [...stocksList];

  // Accumulate price history in state
  const [stocksWithHistory, setStocksWithHistory] = useState<
    Map<string, StockWithHistory>
  >(new Map());

  // Detect updates by watching the timestamp of the first stock
  const currentTimestamp = stocksArray[0] ? getLastUpdate(stocksArray[0]) : 0;

  useEffect(() => {
    // When we get new data (detected by timestamp change), add to history
    setStocksWithHistory((prev) => {
      const updated = new Map(prev);

      stocksArray.forEach((stock) => {
        const symbol = getSymbol(stock);
        const existing = updated.get(symbol);
        const newPoint: PricePoint = {
          price: getPrice(stock),
          timestamp: getLastUpdate(stock),
        };

        if (existing) {
          // Add new point to history, keep last 20
          const newHistory = [newPoint, ...existing.price_history].slice(0, 20);
          updated.set(symbol, {
            stock: existing.stock,
            price_history: newHistory,
          });
        } else {
          // First time seeing this stock
          updated.set(symbol, {
            stock: stock,
            price_history: [newPoint],
          });
        }
      });

      return updated;
    });
  }, [currentTimestamp]); // Key on timestamp to detect when new data arrives

  // Convert map to array for rendering
  const displayStocks = Array.from(stocksWithHistory.values());

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-900 via-teal-800 to-blue-900 p-8">
      <div className="max-w-5xl mx-auto">
        <PageHeader />

        <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 mb-6">
          <h2 className="text-3xl font-bold text-white mb-2">
            Live Stock Ticker
          </h2>
          <p className="text-white/80">{info_message}</p>
          <p className="text-sm text-white/60 mt-2">
            ✨ Demonstrating: Inertia usePoll + client-side history + Gleam
            decoder validation
          </p>
        </div>

        <div className="grid gap-4">
          {displayStocks.map((entry) => (
            <StockCard key={getSymbol(entry.stock)} entry={entry} />
          ))}
        </div>

        <div className="mt-8 bg-white/10 backdrop-blur-md rounded-lg p-4">
          <h3 className="text-white font-semibold mb-2">
            🔬 What This Demo Shows:
          </h3>
          <ul className="text-white/80 text-sm space-y-1">
            <li>
              • <strong>Type Safety Approach #1:</strong> Props decoded using{" "}
              <code className="bg-black/30 px-1 rounded">
                decode_stock_ticker_props()
              </code>{" "}
              from compiled Gleam
            </li>
            <li>• Same decoder validates data on backend AND frontend</li>
            <li>
              • <strong>Client-side History:</strong> React{" "}
              <code className="bg-black/30 px-1 rounded">useState</code>{" "}
              accumulates price history from polling updates
            </li>
            <li>
              • <strong>usePoll Hook:</strong> Auto-refreshes every 2s,
              sparklines grow as history builds
            </li>
            <li>• No Zod needed - Gleam compiles directly to JavaScript!</li>
          </ul>
        </div>

        <BackToPresentation />
      </div>
    </div>
  );
}

function Sparkline({ history }: { history: PricePoint[] }) {
  if (history.length < 2) {
    return (
      <div className="h-12 flex items-center justify-center text-white/40 text-xs">
        Building history...
      </div>
    );
  }

  // Find min/max for scaling
  const prices = history.map((p) => p.price);
  const min = Math.min(...prices);
  const max = Math.max(...prices);
  const range = max - min || 1; // Avoid division by zero

  // Create SVG path
  const width = 200;
  const height = 48;
  const padding = 4;
  const step = (width - padding * 2) / (history.length - 1);

  const points = history.map((point, i) => {
    const x = padding + i * step;
    const normalized = (point.price - min) / range;
    const y = height - padding - normalized * (height - padding * 2);
    return `${x},${y}`;
  });

  const pathData = `M ${points.join(" L ")}`;

  // Determine trend color
  const isUpTrend = history[0].price < history[history.length - 1].price;
  const strokeColor = isUpTrend ? "#4ade80" : "#f87171";

  return (
    <svg width={width} height={height} className="mx-auto">
      <path
        d={pathData}
        fill="none"
        stroke={strokeColor}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        className="transition-all duration-300"
      />
    </svg>
  );
}

function StockCard({ entry }: { entry: StockWithHistory }) {
  const isPositive = getChange(entry.stock) >= 0;
  const changeColor = isPositive ? "text-green-400" : "text-red-400";
  const bgColor = isPositive ? "bg-green-500/20" : "bg-red-500/20";
  const arrow = isPositive ? "↑" : "↓";

  return (
    <div
      className={`${bgColor} backdrop-blur-md rounded-lg p-4 transition-all duration-300`}
    >
      <div className="flex items-center justify-between gap-4">
        <div className="flex-1">
          <div className="flex items-baseline gap-2 mb-1">
            <span className="text-2xl font-bold text-white">
              {getSymbol(entry.stock)}
            </span>
            <span className="text-white/60 text-sm">
              {getName(entry.stock)}
            </span>
          </div>
          <div className="text-xs text-white/40">
            History: {entry.price_history.length} points
          </div>
        </div>

        {/* Sparkline */}
        <div className="flex-shrink-0">
          <Sparkline history={entry.price_history} />
        </div>

        <div className="text-right flex-shrink-0">
          <div className="text-3xl font-bold text-white">
            ${getPrice(entry.stock).toFixed(2)}
          </div>
          <div
            className={`flex items-center justify-end gap-1 text-sm font-semibold ${changeColor}`}
          >
            <span>{arrow}</span>
            <span>${Math.abs(getChange(entry.stock)).toFixed(2)}</span>
            <span>({getPercentChange(entry.stock).toFixed(2)}%)</span>
          </div>
        </div>
      </div>

      <div className="mt-2 text-xs text-white/40">
        Last update:{" "}
        {new Date(getLastUpdate(entry.stock) * 1000).toLocaleTimeString()}
      </div>
    </div>
  );
}

// Use the Gleam decoder directly instead of Zod!
export default decodeProps(StockTicker, decode_stock_ticker_props());
