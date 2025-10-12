import React from "react";
import { z } from "zod";

/**
 * Higher-order component that validates props with a Zod schema
 * before passing them to the wrapped component.
 *
 * @example
 * ```tsx
 * function MyComponent(props: MyProps) {
 *   return <div>{props.title}</div>;
 * }
 *
 * export default validateProps(MyComponent, MyPropsSchema);
 * ```
 */
export function validateProps<T extends z.ZodType>(
  Component: React.ComponentType<z.infer<T>>,
  schema: T,
): React.ComponentType<unknown> {
  return function ValidatedComponent(props: unknown) {
    try {
      const validatedProps = schema.parse(props) as z.infer<T>;
      return <Component {...(validatedProps as any)} />;
    } catch (error) {
      if (error instanceof z.ZodError) {
        console.error("Props validation failed:", error.issues);
        return (
          <div className="min-h-screen flex items-center justify-center bg-red-50">
            <div className="max-w-2xl p-8 bg-white rounded-lg shadow-lg">
              <h1 className="text-2xl font-bold text-red-600 mb-4">
                Props Validation Error
              </h1>
              <p className="text-gray-700 mb-4">
                The props received from the backend don't match the expected
                schema.
              </p>
              <pre className="bg-gray-100 p-4 rounded text-sm overflow-auto">
                {JSON.stringify(error.issues, null, 2)}
              </pre>
            </div>
          </div>
        );
      }
      throw error;
    }
  };
}
