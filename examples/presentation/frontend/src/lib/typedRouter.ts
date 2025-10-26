/**
 * Type-safe wrapper around Inertia's router
 *
 * Provides type checking for prop names in partial reloads to prevent
 * runtime errors from typos in prop names.
 *
 * @example
 * ```tsx
 * import { useTypedRouter } from "../lib/typedRouter";
 * import type { MyPageProps } from "../generated/schemas";
 *
 * function MyPage(props: MyPageProps) {
 *   const router = useTypedRouter<MyPageProps>();
 *
 *   const handleAction = () => {
 *     router.reload({
 *       data: { page: 2 },
 *       only: ["users", "page"], // ✓ Type-checked against MyPageProps!
 *     });
 *   };
 * }
 * ```
 */

import { router } from "@inertiajs/react";
import type { VisitOptions } from "@inertiajs/core";

/**
 * Type-safe options for reload with typed `only` and `data` parameters
 *
 * Extends Inertia's VisitOptions with type-safe `only` and `data` parameters.
 *
 * Common options:
 * - `only` - Array of prop names to reload (type-checked!)
 * - `data` - Request data to send (type-checked!)
 * - `preserveScroll` - Preserve scroll position
 * - `preserveState` - Preserve component state
 * - `onSuccess` - Success callback
 * - `onError` - Error callback
 */
export interface TypedReloadOptions<
  TProps extends Record<string, any>,
  TData extends Record<string, any> = Record<string, any>,
> extends Omit<VisitOptions, "only" | "data"> {
  /**
   * Array of prop names to reload (partial reload).
   * Type-checked to ensure only valid prop names are used.
   */
  only?: Array<keyof TProps>;

  /**
   * Request data to send.
   * Type-checked to ensure only valid fields are sent.
   */
  data?: TData;
}

/**
 * Type-safe options for visit with typed `only` and `data` parameters
 *
 * Extends Inertia's VisitOptions with type-safe `only` and `data` parameters.
 *
 * Common options:
 * - `only` - Array of prop names to load (type-checked!)
 * - `data` - Request data to send (type-checked!)
 * - `method` - HTTP method
 * - `preserveScroll` - Preserve scroll position
 * - `preserveState` - Preserve component state
 * - `replace` - Replace history instead of push
 * - `onSuccess` - Success callback
 * - `onError` - Error callback
 */
export interface TypedVisitOptions<
  TProps extends Record<string, any>,
  TData extends Record<string, any> = Record<string, any>,
> extends Omit<VisitOptions, "only" | "data"> {
  /**
   * Array of prop names to load (partial reload).
   * Type-checked to ensure only valid prop names are used.
   */
  only?: Array<keyof TProps>;

  /**
   * Request data to send.
   * Type-checked to ensure only valid fields are sent.
   */
  data?: TData;
}

/**
 * Type-safe router interface
 *
 * Wraps Inertia's router with type-safe prop name and request data checking
 *
 * @template TProps - The page's response props type
 * @template TData - The page's request data type (defaults to any)
 */
export interface TypedRouter<
  TProps extends Record<string, any>,
  TData extends Record<string, any> = Record<string, any>,
> {
  /**
   * Reload the current page with optional partial data
   *
   * @param options - Options including type-safe `only` and `data`
   * @example
   * router.reload({
   *   data: { page: 2 }, // Type-checked!
   *   only: ["users", "page"] // Type-checked!
   * });
   */
  reload(options?: TypedReloadOptions<TProps, TData>): void;

  /**
   * Navigate to a different page
   *
   * @param href - URL to visit
   * @param options - Options including type-safe `only` and `data`
   */
  visit(href: string, options?: TypedVisitOptions<TProps, TData>): void;

  /** Make a GET request with type-safe data */
  get(
    href: string,
    data?: TData,
    options?: TypedVisitOptions<TProps, TData>,
  ): void;

  /** Make a POST request with type-safe data */
  post(
    href: string,
    data?: TData,
    options?: TypedVisitOptions<TProps, TData>,
  ): void;

  /** Make a PUT request with type-safe data */
  put(
    href: string,
    data?: TData,
    options?: TypedVisitOptions<TProps, TData>,
  ): void;

  /** Make a PATCH request with type-safe data */
  patch(
    href: string,
    data?: TData,
    options?: TypedVisitOptions<TProps, TData>,
  ): void;

  /** Make a DELETE request with type-safe data */
  delete(href: string, options?: TypedVisitOptions<TProps, TData>): void;
}

/**
 * Hook that provides type-safe access to Inertia's router
 *
 * Captures both the page's props type and request data type, ensuring that
 * the `only` array and `data` object are type-checked.
 *
 * @template TProps - The page's response props type
 * @template TData - The page's request data type (defaults to any)
 *
 * @example
 * ```tsx
 * interface UsersTableRequestData {
 *   page?: number;
 * }
 *
 * function UsersTable(props: UsersTablePageProps) {
 *   const router = useTypedRouter<UsersTablePageProps, UsersTableRequestData>();
 *
 *   router.reload({
 *     data: { page: 2 }, // ✓ Type-checked!
 *     only: ["users", "page"] // ✓ Type-checked!
 *   });
 * }
 * ```
 */
export function useTypedRouter<
  TProps extends Record<string, unknown>,
  TData extends Record<string, any> = Record<string, any>,
>(): TypedRouter<TProps, TData> {
  return {
    reload(options?: TypedReloadOptions<TProps, TData>): void {
      router.reload(options as VisitOptions);
    },

    visit(href: string, options?: TypedVisitOptions<TProps, TData>): void {
      router.visit(href, options as VisitOptions);
    },

    get(
      href: string,
      data?: TData,
      options?: TypedVisitOptions<TProps, TData>,
    ): void {
      router.get(href, data, options as VisitOptions);
    },

    post(
      href: string,
      data?: TData,
      options?: TypedVisitOptions<TProps, TData>,
    ): void {
      router.post(href, data, options as VisitOptions);
    },

    put(
      href: string,
      data?: TData,
      options?: TypedVisitOptions<TProps, TData>,
    ): void {
      router.put(href, data, options as VisitOptions);
    },

    patch(
      href: string,
      data?: TData,
      options?: TypedVisitOptions<TProps, TData>,
    ): void {
      router.patch(href, data, options as VisitOptions);
    },

    delete(href: string, options?: TypedVisitOptions<TProps, TData>): void {
      router.delete(href, options as VisitOptions);
    },
  };
}
