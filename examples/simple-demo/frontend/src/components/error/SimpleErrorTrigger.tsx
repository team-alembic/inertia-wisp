import React, { useState } from "react";

const SimpleErrorTrigger: React.FC = () => {
  const [shouldThrow, setShouldThrow] = useState(false);

  if (shouldThrow) {
    throw new Error("Simple error trigger - should be caught by Layout ErrorBoundary");
  }

  return (
    <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
      <h3 className="text-sm font-medium text-yellow-800 mb-3">
        🧪 Simple Error Trigger
      </h3>
      <button
        onClick={() => setShouldThrow(true)}
        className="inline-flex items-center px-3 py-2 border border-red-300 text-sm leading-4 font-medium rounded-md text-red-700 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
      >
        🚨 Throw Error (Layout Level)
      </button>
      <div className="mt-3 text-xs text-yellow-700">
        <p>This error should be caught by the Layout's ErrorBoundary component.</p>
      </div>
    </div>
  );
};

export default SimpleErrorTrigger;
