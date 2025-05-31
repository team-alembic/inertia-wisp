import React from "react";

// Error boundary component for decoder failures
export interface DecoderErrorFallbackProps {
  error: Error;
  reset: () => void;
  rawProps: unknown;
}

export function DefaultDecoderErrorFallback({
  error,
  reset,
  rawProps,
}: DecoderErrorFallbackProps) {
  return React.createElement(
    "div",
    {
      style: {
        padding: "20px",
        border: "2px solid red",
        borderRadius: "4px",
        backgroundColor: "#fff5f5",
        color: "#c53030",
        fontFamily: "monospace",
      },
    },
    [
      React.createElement("h2", { key: "title" }, "Props Decoder Error"),
      React.createElement("p", { key: "message" }, error.message),
      React.createElement(
        "details",
        {
          key: "raw-props",
          style: { marginTop: "10px" },
        },
        [
          React.createElement("summary", { key: "summary" }, "Raw Props"),
          React.createElement(
            "pre",
            {
              key: "content",
              style: {
                backgroundColor: "#f7fafc",
                padding: "10px",
                borderRadius: "4px",
                fontSize: "12px",
                overflow: "auto",
              },
            },
            JSON.stringify(rawProps, null, 2),
          ),
        ],
      ),
      React.createElement(
        "button",
        {
          key: "retry",
          onClick: reset,
          style: {
            marginTop: "10px",
            padding: "8px 16px",
            backgroundColor: "#c53030",
            color: "white",
            border: "none",
            borderRadius: "4px",
            cursor: "pointer",
          },
        },
        "Retry",
      ),
    ],
  );
}

// Configuration options for the HOC
export interface WithDecodedPropsOptions {
  ErrorFallback?: React.ComponentType<DecoderErrorFallbackProps>;
  logErrors?: boolean;
  onError?: (error: Error, props: unknown) => void;
}

// Higher-order component for validating page props with Gleam decoders
export function withDecodedProps<T>(
  decoder: (data: unknown) => T,
  Component: React.ComponentType<T>,
  options: WithDecodedPropsOptions = {},
): React.ComponentType<any> {
  const {
    ErrorFallback = DefaultDecoderErrorFallback,
    logErrors = true,
    onError,
  } = options;

  const WrappedComponent = function DecodedComponent(rawProps: unknown) {
    const [error, setError] = React.useState<Error | null>(null);

    const handleReset = React.useCallback(() => {
      setError(null);
    }, []);

    React.useEffect(() => {
      try {
        decoder(rawProps);
        setError(null);
      } catch (decoderError) {
        const error =
          decoderError instanceof Error
            ? decoderError
            : new Error("Decoder failed");

        if (logErrors) {
          console.error("Props decoder failed:", error, { rawProps });
        }

        if (onError) {
          onError(error, rawProps);
        }

        setError(error);
      }
    }, [rawProps, logErrors, onError]);

    if (error) {
      return React.createElement(ErrorFallback, {
        error,
        reset: handleReset,
        rawProps,
      });
    }

    try {
      const decodedProps = decoder(rawProps);
      return React.createElement(Component as any, decodedProps as any);
    } catch (decoderError) {
      const error =
        decoderError instanceof Error
          ? decoderError
          : new Error("Decoder failed");
      return React.createElement(ErrorFallback, {
        error,
        reset: handleReset,
        rawProps,
      });
    }
  };

  WrappedComponent.displayName = `withDecodedProps(${Component.displayName || Component.name || "Component"})`;

  return WrappedComponent;
}
