import React from "react";
import { MetricCard } from "./MetricCard";
import { Icons } from "./Icons";

interface KeyMetricsProps {
  user_count: number;
}

export const KeyMetrics: React.FC<KeyMetricsProps> = ({ user_count }) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <MetricCard
        title="Total Users"
        value={user_count.toLocaleString()}
        status="Live"
        statusColor="emerald"
        icon={<Icons.Users />}
        iconColor="blue"
      />

      <MetricCard
        title="Page Performance"
        value="Optimal"
        status="Fast Load"
        statusColor="emerald"
        icon={<Icons.Lightning />}
        iconColor="emerald"
      />

      <MetricCard
        title="Load Strategy"
        value="Progressive"
        status="DeferredProp"
        statusColor="indigo"
        icon={<Icons.Refresh />}
        iconColor="indigo"
      />

      <MetricCard
        title="System Status"
        value="Healthy"
        status="99.9% Uptime"
        statusColor="emerald"
        icon={<Icons.CheckCircle />}
        iconColor="emerald"
      />
    </div>
  );
};
