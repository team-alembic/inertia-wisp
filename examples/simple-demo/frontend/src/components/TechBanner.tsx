import React from "react";
import { Icons } from "./Icons";

export const TechBanner: React.FC = () => {
  return (
    <div className="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-xl p-6 mb-8">
      <div className="flex items-start">
        <div className="flex-shrink-0">
          <div className="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center">
            <Icons.Info />
          </div>
        </div>
        <div className="ml-4">
          <h3 className="text-lg font-semibold text-blue-900">
            DeferredProp Technology Demo
          </h3>
          <p className="mt-1 text-blue-700">
            This dashboard demonstrates advanced performance optimization
            using Inertia.js DeferredProp components. Analytics and
            activity data load automatically in the background after the
            initial page render.
          </p>
          <div className="mt-3 flex items-center space-x-4 text-sm text-blue-600">
            <span className="flex items-center">
              <Icons.Check />
              Instant page load
            </span>
            <span className="flex items-center">
              <Icons.Check />
              Progressive enhancement
            </span>
            <span className="flex items-center">
              <Icons.Check />
              Background calculations
            </span>
          </div>
          <p className="mt-3 text-sm text-blue-700">
            <strong>Demo Controls:</strong> Add{" "}
            <code className="bg-blue-100 px-2 py-1 rounded">
              ?delay=2000
            </code>{" "}
            to the URL to control loading delay (0-10000ms). Default is
            0ms (instant) for optimal performance.
          </p>
        </div>
      </div>
    </div>
  );
};
