import React from "react";

interface ActivitySummaryProps {
  totalActivities: number;
  lastUpdated?: string;
}

export const ActivitySummary: React.FC<ActivitySummaryProps> = ({
  totalActivities,
  lastUpdated,
}) => {
  return (
    <div className="flex items-center justify-between text-sm text-gray-600 mb-4">
      <span>Total Activities: {totalActivities}</span>
      <span className="text-xs">
        {lastUpdated
          ? new Date(lastUpdated).toLocaleTimeString()
          : "Loading..."}
      </span>
    </div>
  );
};
