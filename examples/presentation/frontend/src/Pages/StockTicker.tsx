import { usePoll } from "@inertiajs/react";
import * as Stock from "../lib/stock";
import { BackToPresentation, Sparkline } from "../components";
import { decodeProps } from "../lib/decodeProps";

function StockTicker(props: Stock.StockTickerProps) {
  // Use Inertia's polling hook - only poll for price_points (they accumulate)
  // Stocks data stays static after initial load
  usePoll(1000, { only: ["price_points"] });

  // Extract props using accessor functions
  const stocks = Stock.getStocks(props);
  const price_points = Stock.getPricePoints(props);
  const info_message = Stock.getInfoMessage(props);

  // Combine stocks with their accumulated price history using Gleam function!
  const stocksWithHistory = Stock.combineStocksWithHistory(
    stocks,
    price_points,
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-900 via-teal-800 to-blue-900 p-8">
      <div className="max-w-5xl mx-auto">
        <PageHeader infoMessage={info_message} />

        <div className="grid gap-4">
          {Array.from(stocksWithHistory).map((entry) => (
            <StockCard
              key={Stock.getSymbol(Stock.getStockFromHistory(entry))}
              entry={entry}
            />
          ))}
        </div>

        <DemoExplanation />

        <div className="mt-8">
          <BackToPresentation slideNumber={15} />
        </div>
      </div>
    </div>
  );
}

function PageHeader({ infoMessage }: { infoMessage: string }) {
  return (
    <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 mb-6">
      <h2 className="text-3xl font-bold text-white mb-2">Live Stock Ticker</h2>
      <p className="text-white/80">{infoMessage}</p>
      <p className="text-sm text-white/60 mt-2">
        ✨ Demonstrating: Inertia usePoll + client-side history + Gleam decoder
        validation
      </p>
    </div>
  );
}

function DemoExplanation() {
  return (
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
          <code className="bg-black/30 px-1 rounded">useState</code> accumulates
          price history from polling updates
        </li>
        <li>
          • <strong>usePoll Hook:</strong> Auto-refreshes every 2s, sparklines
          grow as history builds
        </li>
        <li>• No Zod needed - Gleam compiles directly to JavaScript!</li>
      </ul>
    </div>
  );
}

function StockCard({ entry }: { entry: Stock.StockWithHistory }) {
  const stock = Stock.getStockFromHistory(entry);
  const priceHistory = Stock.getPriceHistory(entry);

  // Convert Gleam List to JS array and map to simple objects for Sparkline
  const historyArray = Array.from(priceHistory).map((point) => ({
    price: Stock.getPricePointPrice(point),
    timestamp: Stock.getPricePointTimestamp(point),
  }));

  const isPositive = Stock.getChange(stock) >= 0;
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
              {Stock.getSymbol(stock)}
            </span>
            <span className="text-white/60 text-sm">
              {Stock.getName(stock)}
            </span>
          </div>
          <div className="text-xs text-white/40">
            History: {historyArray.length} points
          </div>
        </div>

        {/* Sparkline */}
        <div className="flex-shrink-0">
          <Sparkline history={historyArray} />
        </div>

        <div className="text-right flex-shrink-0">
          <div className="text-3xl font-bold text-white">
            ${Stock.getPrice(stock).toFixed(2)}
          </div>
          <div
            className={`flex items-center justify-end gap-1 text-sm font-semibold ${changeColor}`}
          >
            <span>{arrow}</span>
            <span>${Math.abs(Stock.getChange(stock)).toFixed(2)}</span>
            <span>({Stock.getPercentChange(stock).toFixed(2)}%)</span>
          </div>
        </div>
      </div>

      <div className="mt-2 text-xs text-white/40">
        Last update:{" "}
        {new Date(Stock.getLastUpdate(stock) * 1000).toLocaleTimeString()}
      </div>
    </div>
  );
}

// Use the Gleam decoder directly instead of Zod!
export default decodeProps(StockTicker, Stock.decodeStockTickerProps());
