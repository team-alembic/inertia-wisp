import React from "react";
import { Card, FlexBetween } from "./ui/Layout";

interface MetricCardProps {
  title: string;
  value: string;
  status: string;
  statusColor: "emerald" | "blue" | "indigo";
  icon: React.ReactNode;
  iconColor: "emerald" | "blue" | "indigo";
}

interface StatusBadgeProps {
  status: string;
  color: "emerald" | "blue" | "indigo";
}

interface IconContainerProps {
  icon: React.ReactNode;
  color: "emerald" | "blue" | "indigo";
}

const StatusBadge: React.FC<StatusBadgeProps> = ({ status, color }) => {
  const colorClasses = {
    emerald: "bg-emerald-100 text-emerald-800",
    blue: "bg-blue-100 text-blue-800",
    indigo: "bg-indigo-100 text-indigo-800",
  };

  return (
    <span
      className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${colorClasses[color]}`}
    >
      {status}
    </span>
  );
};

const IconContainer: React.FC<IconContainerProps> = ({ icon, color }) => {
  const colorClasses = {
    emerald: "bg-emerald-500",
    blue: "bg-blue-500",
    indigo: "bg-indigo-500",
  };

  return (
    <div
      className={`w-12 h-12 ${colorClasses[color]} rounded-lg flex items-center justify-center`}
    >
      {icon}
    </div>
  );
};

export const MetricCard: React.FC<MetricCardProps> = ({
  title,
  value,
  status,
  statusColor,
  icon,
  iconColor,
}) => {
  const valueColorClasses = {
    emerald: "text-emerald-600",
    blue: "text-gray-900",
    indigo: "text-indigo-600",
  };

  return (
    <Card>
      <FlexBetween>
        <div>
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p
            className={`text-3xl font-bold mt-1 ${valueColorClasses[statusColor]}`}
          >
            {value}
          </p>
          <div className="flex items-center mt-2">
            <StatusBadge status={status} color={statusColor} />
          </div>
        </div>
        <IconContainer icon={icon} color={iconColor} />
      </FlexBetween>
    </Card>
  );
};
