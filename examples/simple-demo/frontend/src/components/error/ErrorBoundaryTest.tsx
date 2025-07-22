import React, { Component, ReactNode } from "react";

interface ErrorBoundaryTestState {
  hasError: boolean;
  error?: Error;
}

class SimpleErrorBoundary extends Component<
  { children: ReactNode },
  ErrorBoundaryTestState
> {
  constructor(props: { children: ReactNode }) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryTestState {
    console.log("ErrorBoundary caught error:", error);
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.log("componentDidCatch called:", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded m-4">
          <h3 className="font-bold">Error Caught!</h3>
          <p>Something went wrong: {this.state.error?.message}</p>
          <button
            onClick={() => this.setState({ hasError: false })}
            className="mt-2 bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded"
          >
            Try Again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

const ThrowError: React.FC = () => {
  const [shouldThrow, setShouldThrow] = React.useState(false);

  if (shouldThrow) {
    throw new Error("Test error from ThrowError component");
  }

  return (
    <button
      onClick={() => setShouldThrow(true)}
      className="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded"
    >
      Throw Error
    </button>
  );
};

const ErrorBoundaryTest: React.FC = () => {
  return (
    <div className="p-4 border border-gray-300 rounded">
      <h3 className="text-lg font-semibold mb-4">Error Boundary Test</h3>
      <SimpleErrorBoundary>
        <div className="space-y-4">
          <p>This content is protected by an error boundary.</p>
          <ThrowError />
        </div>
      </SimpleErrorBoundary>
    </div>
  );
};

export default ErrorBoundaryTest;
