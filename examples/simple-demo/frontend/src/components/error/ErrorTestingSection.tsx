import React from "react";
import SimpleErrorTrigger from "./SimpleErrorTrigger";

const ErrorTestingSection: React.FC = () => {
  return (
    <section className="section">
      <h2 className="section-title">🧪 Error Boundary Testing</h2>
      <div className="space-y-4">
        <div>
          <p className="text-sm text-gray-600 mb-4">
            This demonstrates the app-level error boundary that provides
            system-wide protection against render errors:
          </p>
          <SimpleErrorTrigger />
        </div>

        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <h3 className="text-sm font-medium text-blue-800 mb-2">
            💡 Error Boundary Protection
          </h3>
          <div className="text-xs text-blue-700">
            <p>
              The error boundary catches React render errors and displays a
              graceful fallback UI instead of a blank page. It provides error
              context, recovery options, and maintains application stability.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default ErrorTestingSection;
