import React from "react";
import { Activity } from "../types";
import { Icons } from "./Icons";

interface ActivityItemProps {
  activity: Activity;
}

export const ActivityItem: React.FC<ActivityItemProps> = ({ activity }) => {
  return (
    <div className="bg-gray-50 rounded-lg p-4 border-l-4 border-indigo-500">
      <div className="flex items-start space-x-3">
        <div className="w-8 h-8 bg-indigo-100 rounded-full flex items-center justify-center">
          <Icons.UserCircle />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between">
            <p className="text-sm font-medium text-gray-900 truncate">
              {activity?.user_name || "System"}
            </p>
            <p className="text-xs text-gray-500">
              {activity?.timestamp
                ? new Date(activity.timestamp).toLocaleTimeString()
                : "Unknown time"}
            </p>
          </div>
          <p className="text-sm text-gray-600 mt-1">
            {activity?.action || "No description"}
          </p>
          <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800 mt-2">
            Activity
          </span>
        </div>
      </div>
    </div>
  );
};
