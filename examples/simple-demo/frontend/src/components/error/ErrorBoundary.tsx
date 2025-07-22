import React, { Component, ReactNode } from "react";

export interface ErrorInfo {
  componentStack: string;
  errorBoundary?: string;
  errorBoundaryStack?: string;
}

export interface ErrorContext {
  user_id?: string;
  route: string;
  timestamp: string;
  user_agent: string;
  component_stack: string;
  error_message: string;
  error_stack?: string;
}

export interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
  errorInfo?: ErrorInfo;
  errorId?: string;
  retryCount: number;
}

export interface ErrorBoundaryProps {
  children: ReactNode;
  fallback?: React.ComponentType<ErrorFallbackProps>;
  onError?: (error: Error, errorInfo: ErrorInfo, context: ErrorContext) => void;
  maxRetries?: number;
  feature?: string;
}

export interface ErrorFallbackProps {
  error: Error;
  errorInfo?: ErrorInfo;
  retry: () => void;
  canRetry: boolean;
  feature?: string;
  errorId?: string;
}

class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  private retryTimeoutId: number | null = null;

  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = {
      hasError: false,
      error: undefined,
      errorInfo: undefined,
      errorId: undefined,
      retryCount: 0,
    };
  }

  static getDerivedStateFromError(error: Error): Partial<ErrorBoundaryState> {
    // Update state so the next render will show the fallback UI
    return {
      hasError: true,
      error,
      errorId: `error_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // Capture additional error information
    this.setState({
      errorInfo,
    });

    // Create error context for logging
    const context: ErrorContext = {
      route: window.location.pathname,
      timestamp: new Date().toISOString(),
      user_agent: navigator.userAgent,
      component_stack: errorInfo.componentStack,
      error_message: error.message,
      error_stack: error.stack,
    };

    // Log error to console in development
    if (
      typeof window !== "undefined" &&
      window.location.hostname === "localhost"
    ) {
      console.group("🚨 Error Boundary Caught Error");
      console.error("Error:", error);
      console.error("Error Info:", errorInfo);
      console.error("Context:", context);
      console.groupEnd();
    }

    // Call optional error handler
    if (this.props.onError) {
      this.props.onError(error, errorInfo, context);
    }
  }

  componentDidUpdate(prevProps: ErrorBoundaryProps) {
    // Reset error state when children change (navigation)
    if (prevProps.children !== this.props.children && this.state.hasError) {
      this.setState({
        hasError: false,
        error: undefined,
        errorInfo: undefined,
        errorId: undefined,
        retryCount: 0,
      });
    }
  }

  componentWillUnmount() {
    // Clean up any pending retry timeouts
    if (this.retryTimeoutId) {
      clearTimeout(this.retryTimeoutId);
    }
  }

  handleRetry = () => {
    const { maxRetries = 3 } = this.props;
    const { retryCount } = this.state;

    if (retryCount < maxRetries) {
      this.setState({
        hasError: false,
        error: undefined,
        errorInfo: undefined,
        errorId: undefined,
        retryCount: retryCount + 1,
      });
    }
  };

  render() {
    if (this.state.hasError && this.state.error) {
      const { fallback: Fallback = DefaultErrorFallback, maxRetries = 3 } =
        this.props;
      const canRetry = this.state.retryCount < maxRetries;

      return (
        <Fallback
          error={this.state.error}
          errorInfo={this.state.errorInfo}
          retry={this.handleRetry}
          canRetry={canRetry}
          feature={this.props.feature}
          errorId={this.state.errorId}
        />
      );
    }

    return this.props.children;
  }
}

// Default fallback component
const DefaultErrorFallback: React.FC<ErrorFallbackProps> = ({
  error,
  retry,
  canRetry,
  feature,
  errorId,
}) => {
  const featureText = feature ? ` in ${feature}` : "";

  return (
    <div className="bg-red-50 border border-red-200 rounded-lg p-6 max-w-2xl mx-auto my-8">
      <div className="flex items-start">
        <div className="flex-shrink-0">
          <svg
            className="h-6 w-6 text-red-400"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 19.5c-.77.833.192 2.5 1.732 2.5z"
            />
          </svg>
        </div>
        <div className="ml-3 flex-1">
          <h3 className="text-sm font-medium text-red-800">
            Something went wrong{featureText}
          </h3>
          <div className="mt-2 text-sm text-red-700">
            <p>
              We encountered an unexpected error while rendering this part of
              the page.
            </p>
          </div>
          {typeof window !== "undefined" &&
            window.location.hostname === "localhost" && (
              <details className="mt-3">
                <summary className="text-sm font-medium text-red-800 cursor-pointer hover:text-red-900">
                  Technical Details (Development)
                </summary>
                <div className="mt-2 p-3 bg-red-100 rounded text-xs font-mono text-red-900 overflow-auto">
                  <div>
                    <strong>Error:</strong> {error.message}
                  </div>
                  {errorId && (
                    <div className="mt-1">
                      <strong>ID:</strong> {errorId}
                    </div>
                  )}
                  {error.stack && (
                    <div className="mt-2">
                      <strong>Stack Trace:</strong>
                      <pre className="mt-1 whitespace-pre-wrap">
                        {error.stack}
                      </pre>
                    </div>
                  )}
                </div>
              </details>
            )}
          <div className="mt-4 flex space-x-3">
            {canRetry && (
              <button
                onClick={retry}
                className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-red-700 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
              >
                Try Again
              </button>
            )}
            <button
              onClick={() => window.location.reload()}
              className="inline-flex items-center px-3 py-2 border border-gray-300 text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
            >
              Refresh Page
            </button>
            <button
              onClick={() => window.history.back()}
              className="inline-flex items-center px-3 py-2 border border-gray-300 text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
            >
              Go Back
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ErrorBoundary;
