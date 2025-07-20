import React from "react";
import { Icons } from "./Icons";

interface ChartPlaceholderProps {
  title: string;
  description: string;
  subtitle: string;
}

export const ChartPlaceholder: React.FC<ChartPlaceholderProps> = ({
  title,
  description,
  subtitle,
}) => {
  return (
    <div className="mb-6">
      <h4 className="text-sm font-medium text-gray-900 mb-4">
        {title}
      </h4>
      <div className="bg-gray-50 rounded-lg p-6 h-64 flex items-center justify-center">
        <div className="text-center text-gray-500">
          <Icons.BarChart />
          <p className="text-sm">
            {description}
          </p>
          <p className="text-xs text-gray-400 mt-1">
            {subtitle}
          </p>
        </div>
      </div>
    </div>
  );
};
