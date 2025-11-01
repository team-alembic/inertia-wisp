import { ComponentType } from "react";
import { Decoder$, run } from "@gleam/gleam_stdlib/gleam/dynamic/decode.mjs";
import { Result$Error$0, Result$isOk, Result$Ok$0 } from "@gleam/prelude.mjs";

/**
 * HOC that validates Inertia props using a Gleam decoder
 *
 * This demonstrates Type Safety Approach #1: Compile Gleam → JavaScript
 * The same decoder that validates props on the backend also validates them on the frontend!
 */
export function decodeProps<P extends object>(
  Component: ComponentType<P>,
  decoder: Decoder$<P>, // Gleam decoder function factory
) {
  return function ValidatedComponent(props: P) {
    try {
      const result = run(props, decoder);

      // Check if decoding succeeded using Gleam Result helper
      if (Result$isOk(result)) {
        // Props are valid! Extract the decoded value and render the component
        const decodedProps = Result$Ok$0(result) as P;
        return <Component {...decodedProps} />;
      } else {
        // Decoding failed - show error
        const errors = Result$Error$0(result); // Error value from Gleam Result
        console.error("❌ Gleam decoder validation failed:", errors);
        return (
          <div className="min-h-screen bg-red-900 p-8">
            <div className="max-w-2xl mx-auto bg-white rounded-lg p-6">
              <h1 className="text-2xl font-bold text-red-600 mb-4">
                Props Validation Failed (Gleam Decoder)
              </h1>
              <pre className="bg-gray-100 p-4 rounded overflow-auto">
                {JSON.stringify(errors, null, 2)}
              </pre>
            </div>
          </div>
        );
      }
    } catch (error) {
      console.error("Gleam decoder error:", error);
      return (
        <div className="min-h-screen bg-red-900 p-8">
          <div className="max-w-2xl mx-auto bg-white rounded-lg p-6">
            <h1 className="text-2xl font-bold text-red-600 mb-4">
              Decoder Error
            </h1>
            <pre className="bg-gray-100 p-4 rounded overflow-auto">
              {error instanceof Error ? error.message : String(error)}
            </pre>
          </div>
        </div>
      );
    }
  };
}
