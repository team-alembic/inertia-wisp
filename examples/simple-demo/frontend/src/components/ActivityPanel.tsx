import React from "react";
import { Deferred } from "@inertiajs/react";
import { ActivityFeed } from "../types";
import { PanelHeader } from "./PanelHeader";
import { ActivitySummary } from "./ActivitySummary";
import { ActivityItem } from "./ActivityItem";

const ActivityFeedLoadingState = () => (
  <div className="animate-pulse space-y-4">
    <div className="flex items-center justify-between text-sm text-gray-300 mb-4">
      <div className="h-4 bg-gray-200 rounded w-24"></div>
      <div className="h-3 bg-gray-200 rounded w-16"></div>
    </div>

    {[1, 2, 3, 4, 5].map((i) => (
      <div key={i} className="bg-gray-50 rounded-lg p-4">
        <div className="flex items-start space-x-3">
          <div className="w-8 h-8 bg-gray-200 rounded-full"></div>
          <div className="flex-1">
            <div className="flex items-center justify-between mb-2">
              <div className="h-4 bg-gray-200 rounded w-32"></div>
              <div className="h-3 bg-gray-200 rounded w-12"></div>
            </div>
            <div className="h-3 bg-gray-200 rounded w-48 mb-1"></div>
            <div className="h-3 bg-gray-200 rounded w-36"></div>
          </div>
        </div>
      </div>
    ))}
  </div>
);

interface ActivityPanelProps {
  activity_feed?: ActivityFeed;
}

export const ActivityPanel: React.FC<ActivityPanelProps> = ({
  activity_feed,
}) => {
  return (
    <div className="lg:col-span-1">
      <div className="bg-white rounded-xl shadow-sm border border-gray-200">
        <PanelHeader
          title="Activity Feed"
          subtitle="Recent user activities and system events"
          badges={[
            { text: "DeferredProp", color: "purple" },
            { text: "Activity Group", color: "gray" },
          ]}
        />
        <div className="p-6">
          <Deferred
            data="activity_feed"
            fallback={<ActivityFeedLoadingState />}
          >
            <div className="space-y-4">
              <ActivitySummary
                totalActivities={activity_feed?.total_activities || 0}
                lastUpdated={activity_feed?.last_updated}
              />

              {(activity_feed?.recent_activities || []).map(
                (activity, index) => (
                  <ActivityItem key={index} activity={activity} />
                ),
              )}
            </div>
          </Deferred>
        </div>
      </div>
    </div>
  );
};
