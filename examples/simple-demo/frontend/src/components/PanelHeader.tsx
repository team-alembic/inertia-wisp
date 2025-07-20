import React from "react";

interface Badge {
  text: string;
  color: "blue" | "purple" | "gray";
}

interface PanelHeaderProps {
  title: string;
  subtitle: string;
  badges: Badge[];
}

const badgeColors = {
  blue: "bg-blue-100 text-blue-800",
  purple: "bg-purple-100 text-purple-800",
  gray: "bg-gray-100 text-gray-600",
};

export const PanelHeader: React.FC<PanelHeaderProps> = ({
  title,
  subtitle,
  badges,
}) => {
  return (
    <div className="px-6 py-4 border-b border-gray-200 bg-gray-50 rounded-t-xl">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
          <p className="text-sm text-gray-600 mt-1">{subtitle}</p>
        </div>
        <div className="flex items-center space-x-2">
          {badges.map((badge, index) => (
            <span
              key={index}
              className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${badgeColors[badge.color]}`}
            >
              {badge.text}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
};
