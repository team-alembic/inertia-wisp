import React from "react";
import { PageHeader, FlexBetween, FlexCenter } from "./ui/Layout";

export const DashboardHeader: React.FC = () => {
  return (
    <PageHeader>
      <FlexBetween>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Executive Dashboard
          </h1>
          <p className="mt-1 text-sm text-gray-600">
            Real-time analytics and performance insights
          </p>
        </div>
        <FlexCenter>
          <div className="flex items-center px-3 py-1 bg-emerald-100 text-emerald-800 text-xs font-medium rounded-full">
            <div className="w-2 h-2 bg-emerald-500 rounded-full mr-2"></div>
            Live Data
          </div>
          <div className="text-xs text-gray-500">
            Updated: {new Date().toLocaleTimeString()}
          </div>
        </FlexCenter>
      </FlexBetween>
    </PageHeader>
  );
};
