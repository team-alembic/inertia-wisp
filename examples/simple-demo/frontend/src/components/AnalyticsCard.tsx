import React from "react";

interface AnalyticsCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  gradientFrom: string;
  gradientTo: string;
  textColor: string;
  valueColor: string;
  iconBgColor: string;
}

export const AnalyticsCard: React.FC<AnalyticsCardProps> = ({
  title,
  value,
  icon,
  gradientFrom,
  gradientTo,
  textColor,
  valueColor,
  iconBgColor,
}) => {
  return (
    <div className={`bg-gradient-to-br ${gradientFrom} ${gradientTo} rounded-lg p-4`}>
      <div className="flex items-center justify-between">
        <div>
          <p className={`text-sm font-medium ${textColor}`}>
            {title}
          </p>
          <p className={`text-2xl font-bold ${valueColor} mt-1`}>
            {typeof value === 'number' ? value.toLocaleString() : value}
          </p>
        </div>
        <div className={`w-12 h-12 ${iconBgColor} rounded-lg flex items-center justify-center`}>
          {icon}
        </div>
      </div>
    </div>
  );
};
