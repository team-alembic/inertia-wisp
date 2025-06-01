/**
 * TypeScript type-level utilities for projecting Gleam types to JavaScript-compatible interfaces
 *
 * This module provides sophisticated type transformations that automatically convert:
 * - Gleam Option<T> → JavaScript T | null
 * - Gleam List<T> → JavaScript T[]
 * - Gleam classes → Plain JavaScript objects
 *
 * This enables full type safety while maintaining compatibility with JavaScript form libraries
 * like Inertia.js useForm hook, which expects plain objects rather than class instances.
 */

// Import core Gleam types
import type { CustomType, List } from "@gleam/prelude.d.mts";
import type { Some, None } from "@gleam_stdlib/gleam/option.d.mts";

/**
 * Projects Gleam Option<T> types to JavaScript-compatible T | null
 * 
 * This helper type handles the transformation of Gleam's Option<T> which can be:
 * - Some<T> → T | null (extracts the inner type and adds null possibility)
 * - None → null (represents the absence of a value)
 * 
 * The conditional logic uses type inference to extract the inner type U from Some<U>,
 * then recursively projects that inner type in case it contains nested Gleam types.
 */
export type ProjectOption<T> =
  T extends Some<infer U>
    ? ProjectType<U> | null
    : T extends None
      ? null
      : never;

/**
 * Projects Gleam List<T> types to JavaScript arrays T[]
 * 
 * Extracts the inner type from Gleam's List<T> and converts it to a native JavaScript array.
 * The inner type U is not recursively projected here - that happens in ProjectType.
 */
export type ProjectList<T> = T extends List<infer U> ? U[] : never;

/**
 * Main type projection utility that recursively transforms Gleam types to JavaScript-compatible types
 * 
 * This type uses a series of conditional checks to handle different Gleam type patterns:
 * 
 * 1. List<T> → T[] (with recursive projection of inner type)
 * 2. Option<T> → T | null (using the clever `Some<any> extends T` trick)
 * 3. CustomType → Plain object (with method filtering and recursive field projection)
 * 4. Primitive types → Pass through unchanged
 * 
 * CRITICAL TypeScript Trick: Option Detection
 * ==========================================
 * 
 * The line `Some<any> extends T` is a crucial TypeScript pattern that was discovered
 * through trial and error. Here's why it works when other approaches fail:
 * 
 * ❌ DOESN'T WORK: `T extends Option$<infer U>`
 *    - This fails because TypeScript can't properly match against generic union types
 *    - Option$<T> = Some<T> | None, and TypeScript struggles with this pattern matching
 *    - The inference of U becomes unreliable or impossible
 * 
 * ✅ WORKS: `Some<any> extends T`
 *    - This leverages TypeScript's structural typing and contravariance
 *    - If T is Option<U> (i.e., Some<U> | None), then Some<any> can be assigned to T
 *    - This is true because Some<any> is more general than Some<U>
 *    - If T is any other type, Some<any> cannot be assigned to it
 *    - This pattern reliably detects Option types without needing explicit generic matching
 * 
 * The beauty of this approach is that it sidesteps TypeScript's limitations with
 * union type pattern matching by using assignability checks instead.
 */
export type ProjectType<T> =
  T extends List<infer U>
    ? ProjectType<U>[]
    : Some<any> extends T
      ? ProjectOption<T>
      : T extends CustomType
        ? {
            [K in keyof T as T[K] extends (...args: any[]) => any
              ? never
              : K]: ProjectType<T[K]>;
          }
        : T;
/*
 * Utility type for pages that handle forms and need access to validation errors.
 * Adds an `errors` field containing form validation errors to any page props type.
 *
 * Usage:
 * - Form pages: `WithErrors<LoginPageProps$>`
 * - Read-only pages: `GleamToJS<BlogPostPageProps$>`
 *
 * Example:
 * ```typescript
 * import type { LoginPageProps$ } from "path/to/gleam/types";
 * import type { WithErrors } from "./types/gleam-projections";
 *
 * type Props = WithErrors<LoginPageProps$>;
 * // Result: { ...loginPageFields, errors: Record<string, string> }
 * ```
 */
export type WithErrors<Props> = ProjectType<Props> & {
  errors: Record<string, string>;
};
