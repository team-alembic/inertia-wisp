import React from "react";

interface Metric {
  label: string;
  value: string | number;
}

interface MetricsGridProps {
  metrics: Metric[];
}

export const MetricsGrid: React.FC<MetricsGridProps> = ({ metrics }) => {
  return (
    <div className="grid grid-cols-3 gap-4">
      {metrics.map((metric, index) => (
        <div key={index} className="bg-gray-50 rounded-lg p-4 text-center">
          <p className="text-xs font-medium text-gray-600 mb-1">
            {metric.label}
          </p>
          <p className="text-lg font-bold text-gray-900">
            {typeof metric.value === 'number' ? metric.value.toLocaleString() : metric.value}
          </p>
        </div>
      ))}
    </div>
  );
};
