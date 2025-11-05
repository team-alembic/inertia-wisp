import { ComponentType } from "react";
import * as Decode from "@gleam/gleam_stdlib/gleam/dynamic/decode.mjs";
import {
  Result$Error$0 as unwrapError,
  Result$isOk as isOk,
  Result$Ok$0 as unwrapOk,
} from "@gleam/prelude.mjs";
import { Dynamic$ } from "@gleam/gleam_stdlib/gleam/dynamic.mjs";

/**
 * HOC that validates Inertia props using a Gleam decoder
 *
 * This demonstrates Type Safety Approach #1: Compile Gleam → JavaScript
 * The same decoder that validates props on the backend also validates them on the frontend!
 */
export function decodeProps<P extends object>(
  Component: ComponentType<P>,
  decoder: Decode.Decoder$<P>,
) {
  return function ValidatedComponent(props: Dynamic$) {
    try {
      const result = Decode.run(props, decoder);
      if (isOk(result)) {
        const decodedProps = unwrapOk(result)!;
        return <Component {...decodedProps} />;
      } else {
        // Decoding failed - process DecodeError list
        const errorsList = unwrapError(result)!;
        const errors = Array.from(errorsList);

        // Process each DecodeError: { expected, found, path }
        const formattedErrors = errors.map((err: any) => {
          const path = Array.from(err.path || []);
          const pathStr = path.length > 0 ? path.join(".") : "(root)";
          return {
            path: pathStr,
            expected: err.expected,
            found: err.found,
          };
        });

        console.error("❌ Gleam decoder validation failed:", formattedErrors);

        return (
          <div className="min-h-screen bg-red-900 p-8">
            <div className="max-w-2xl mx-auto bg-white rounded-lg p-6">
              <h1 className="text-2xl font-bold text-red-600 mb-4">
                Props Validation Failed (Gleam Decoder)
              </h1>
              <div className="space-y-4">
                {formattedErrors.map((error, idx) => (
                  <div key={idx} className="bg-gray-100 p-4 rounded">
                    <div className="font-mono text-sm">
                      <div className="mb-2">
                        <span className="font-bold">Path:</span> {error.path}
                      </div>
                      <div className="mb-2">
                        <span className="font-bold">Expected:</span>{" "}
                        {error.expected}
                      </div>
                      <div>
                        <span className="font-bold">Found:</span> {error.found}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
              <details className="mt-4">
                <summary className="cursor-pointer text-gray-600 hover:text-gray-800">
                  Raw error data
                </summary>
                <pre className="bg-gray-100 p-4 rounded overflow-auto mt-2">
                  {JSON.stringify(formattedErrors, null, 2)}
                </pre>
              </details>
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
