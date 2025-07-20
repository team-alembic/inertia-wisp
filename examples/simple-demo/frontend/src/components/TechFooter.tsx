import React from "react";

export const TechFooter: React.FC = () => {
  return (
    <div className="mt-12 bg-gray-900 rounded-xl p-8 text-white">
      <div className="text-center mb-6">
        <h3 className="text-xl font-bold mb-2">
          Progressive Loading Technology
        </h3>
        <p className="text-gray-300 max-w-2xl mx-auto">
          This dashboard showcases modern web performance patterns using
          DeferredProp technology. The page loads instantly, then enhances
          progressively as data becomes available.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8 text-sm">
        <div>
          <h4 className="text-sm font-semibold text-gray-200 mb-3">
            Backend Technology
          </h4>
          <ul className="text-sm text-gray-300 space-y-1">
            <li>• Gleam functional programming</li>
            <li>• Wisp web framework</li>
            <li>• SQLite database</li>
            <li>• Efficient query patterns</li>
          </ul>
        </div>
        <div>
          <h4 className="text-sm font-semibold text-gray-200 mb-3">
            Frontend Innovation
          </h4>
          <ul className="text-sm text-gray-300 space-y-1">
            <li>• Inertia.js DeferredProp</li>
            <li>• React Deferred component</li>
            <li>• Background data fetching</li>
            <li>• Seamless UI updates</li>
          </ul>
        </div>
        <div>
          <h4 className="text-sm font-semibold text-gray-200 mb-3">
            User Experience
          </h4>
          <ul className="text-sm text-gray-300 space-y-1">
            <li>• No loading interruptions</li>
            <li>• Smooth progressive loading</li>
            <li>• Contextual loading states</li>
            <li>• Professional appearance</li>
          </ul>
        </div>
      </div>
    </div>
  );
};
