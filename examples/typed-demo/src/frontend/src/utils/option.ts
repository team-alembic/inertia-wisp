import {
  is_some,
  is_none,
  unwrap,
  map as option_map,
} from "../../../shared/build/dev/javascript/gleam_stdlib/gleam/option.mjs";
import {
  Some,
  None,
} from "../../../shared/build/dev/javascript/gleam_stdlib/gleam/option.mjs";
import type { Option$ } from "../../../shared/build/dev/javascript/gleam_stdlib/gleam/option.d.mts";

// Re-export types and constructors
export { Some, None };
export type Option<T> = Option$<T>;

// Helper functions for working with Options in TypeScript
export function isSome<T>(option: Option<T>): option is Some<T> {
  return is_some(option);
}

export function value<T>(some: Some<T>): T {
  return some[0];
}

export function isNone<T>(option: Option<T>): option is None {
  return is_none(option);
}

export function unwrapOr<T>(option: Option<T>, defaultValue: T): T {
  return unwrap(option, defaultValue);
}

export function map<T, U>(option: Option<T>, fn: (value: T) => U): Option<U> {
  return option_map(option, fn);
}

// TypeScript-friendly conditional access
export function ifSome<T, U>(option: Option<T>, fn: (value: T) => U): U | null {
  if (isSome(option)) {
    return fn(value(option));
  }
  return null;
}
