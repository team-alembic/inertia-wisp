interface SparklineProps {
  history: { price: number; timestamp: number }[];
}

export function Sparkline({ history }: SparklineProps) {
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
