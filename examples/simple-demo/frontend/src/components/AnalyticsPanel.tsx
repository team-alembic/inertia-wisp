import React from "react";
import { Deferred } from "@inertiajs/react";
import { UserAnalytics } from "../types";
import { PanelHeader } from "./PanelHeader";
import { AnalyticsCard } from "./AnalyticsCard";
import { ChartPlaceholder } from "./ChartPlaceholder";
import { MetricsGrid } from "./MetricsGrid";
import { Icons } from "./Icons";

const AnalyticsLoadingState = () => (
  <div className="animate-pulse">
    {/* Analytics Grid */}
    <div className="grid grid-cols-2 gap-6 mb-6">
      <div className="bg-gray-100 rounded-lg p-4">
        <div className="flex items-center justify-between">
          <div>
            <div className="h-4 bg-gray-200 rounded w-20 mb-2"></div>
            <div className="h-8 bg-gray-200 rounded w-16"></div>
          </div>
          <div className="w-12 h-12 bg-gray-200 rounded-lg"></div>
        </div>
      </div>
      <div className="bg-gray-100 rounded-lg p-4">
        <div className="flex items-center justify-between">
          <div>
            <div className="h-4 bg-gray-200 rounded w-24 mb-2"></div>
            <div className="h-8 bg-gray-200 rounded w-20"></div>
          </div>
          <div className="w-12 h-12 bg-gray-200 rounded-lg"></div>
        </div>
      </div>
    </div>

    {/* Chart Area */}
    <div className="mb-6">
      <div className="h-4 bg-gray-200 rounded w-32 mb-4"></div>
      <div className="h-64 bg-gray-100 rounded-lg"></div>
    </div>

    {/* Metrics Grid */}
    <div className="grid grid-cols-3 gap-4">
      {[1, 2, 3].map((i) => (
        <div key={i} className="bg-gray-50 rounded-lg p-4">
          <div className="h-3 bg-gray-200 rounded w-16 mb-2"></div>
          <div className="h-6 bg-gray-200 rounded w-12"></div>
        </div>
      ))}
    </div>
  </div>
);

interface AnalyticsPanelProps {
  analytics?: UserAnalytics;
}

export const AnalyticsPanel: React.FC<AnalyticsPanelProps> = ({
  analytics,
}) => {
  return (
    <div className="lg:col-span-2">
      <div className="bg-white rounded-xl shadow-sm border border-gray-200">
        <PanelHeader
          title="User Analytics"
          subtitle="Advanced performance metrics and insights"
          badges={[
            { text: "DeferredProp", color: "blue" },
            { text: "Default Group", color: "gray" },
          ]}
        />
        <div className="p-6">
          <Deferred data="analytics" fallback={<AnalyticsLoadingState />}>
            <div>
              {/* Analytics Grid */}
              <div className="grid grid-cols-2 gap-6 mb-6">
                <AnalyticsCard
                  title="Total Users"
                  value={analytics?.total_users || 0}
                  icon={<Icons.UsersGroup />}
                  gradientFrom="from-blue-50"
                  gradientTo="to-blue-100"
                  textColor="text-blue-700"
                  valueColor="text-blue-900"
                  iconBgColor="bg-blue-500"
                />
                <AnalyticsCard
                  title="Active Users"
                  value={analytics?.active_users || 0}
                  icon={<Icons.CheckCircleFilled />}
                  gradientFrom="from-emerald-50"
                  gradientTo="to-emerald-100"
                  textColor="text-emerald-700"
                  valueColor="text-emerald-900"
                  iconBgColor="bg-emerald-500"
                />
              </div>

              {/* Performance Chart */}
              <ChartPlaceholder
                title="User Activity Trend"
                description="User engagement metrics and trends"
                subtitle={`Growth rate: ${analytics?.growth_rate || 0}% | Avg session: ${analytics?.average_session_duration || 0}min`}
              />

              {/* Key Metrics */}
              <MetricsGrid
                metrics={[
                  {
                    label: "Growth Rate",
                    value: `${analytics?.growth_rate || 0}%`,
                  },
                  {
                    label: "New Users",
                    value: analytics?.new_users_this_month || 0,
                  },
                  {
                    label: "Avg Session",
                    value: `${analytics?.average_session_duration || 0}min`,
                  },
                ]}
              />
            </div>
          </Deferred>
        </div>
      </div>
    </div>
  );
};
