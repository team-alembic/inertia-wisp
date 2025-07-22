import React, { useState } from "react";

interface ErrorTriggerProps {
  className?: string;
}

const ErrorTrigger: React.FC<ErrorTriggerProps> = ({ className = "" }) => {
  const [shouldThrow, setShouldThrow] = useState(false);

  if (shouldThrow) {
    throw new Error("Test error triggered by ErrorTrigger component");
  }

  const triggerError = () => {
    setShouldThrow(true);
  };

  const triggerAsyncError = () => {
    // This won't be caught by error boundary - demonstrates limitation
    setTimeout(() => {
      throw new Error("Async error - not caught by Error Boundary");
    }, 100);
  };

  const triggerNetworkError = async () => {
    try {
      // Simulate network error
      await fetch("/nonexistent-endpoint");
    } catch (error) {
      console.error("Network error (handled):", error);
      alert("Network error occurred (this is handled gracefully)");
    }
  };

  return (
    <div
      className={`bg-yellow-50 border border-yellow-200 rounded-lg p-4 ${className}`}
    >
      <h3 className="text-sm font-medium text-yellow-800 mb-3">
        🧪 Error Testing
      </h3>
      <div className="space-y-2">
        <button
          onClick={triggerError}
          className="inline-flex items-center px-3 py-2 border border-red-300 text-sm leading-4 font-medium rounded-md text-red-700 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
        >
          🚨 Trigger Render Error
        </button>
        <button
          onClick={triggerAsyncError}
          className="ml-2 inline-flex items-center px-3 py-2 border border-orange-300 text-sm leading-4 font-medium rounded-md text-orange-700 bg-orange-100 hover:bg-orange-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500"
        >
          ⚠️ Trigger Async Error (Not Caught)
        </button>
        <button
          onClick={triggerNetworkError}
          className="ml-2 inline-flex items-center px-3 py-2 border border-blue-300 text-sm leading-4 font-medium rounded-md text-blue-700 bg-blue-100 hover:bg-blue-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          🌐 Trigger Network Error (Handled)
        </button>
      </div>
      <div className="mt-3 text-xs text-yellow-700">
        <p>
          <strong>Render Error:</strong> Will be caught by Error Boundary
        </p>
        <p>
          <strong>Async Error:</strong> Won't be caught - shows Error Boundary
          limitations
        </p>
        <p>
          <strong>Network Error:</strong> Handled gracefully with try/catch
        </p>
      </div>
    </div>
  );
};

export default ErrorTrigger;
