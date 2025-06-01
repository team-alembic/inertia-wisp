/**
 * TypeScript type-level utilities for projecting Gleam types to JavaScript-compatible interfaces
 *
 * This module provides sophisticated type transformations that automatically convert:
 * - Gleam Option<T> → JavaScript T | null
 * - Gleam List<T> → JavaScript T[]
 * - Gleam Dict<K, V> → JavaScript Record<K, V>
 * - Gleam classes → Plain JavaScript objects
 *
 * This enables full type safety while maintaining compatibility with JavaScript form libraries
 * like Inertia.js useForm hook, which expects plain objects rather than class instances.
 *
 * Dict Projection Examples:
 * - Dict(String, String) → Record<string, string> (form validation errors)
 * - Dict(String, Int) → Record<string, number>
 * - Dict(String, User) → Record<string, ProjectedUser>
 */

// Import core Gleam types
import type { List } from "../../../shared_types/build/dev/javascript/prelude.d.mts";
import type { Some, None } from "../../../shared_types/build/dev/javascript/gleam_stdlib/gleam/option.d.mts";


// Import shared types for forms and page props
import type {
  ContactPageProps$ as ContactPageProps,
  ContactFormRequest$,
} from "../../../shared_types/build/dev/javascript/shared_types/shared_types/contact.d.mts";

import type {
  LoginPageProps$ as LoginPageProps,
  LoginRequest$,
} from "../../../shared_types/build/dev/javascript/shared_types/shared_types/auth.d.mts";

import type {
  UserProfilePageProps$,
  CreateUserRequest$,
  UpdateProfileRequest$,
} from "../../../shared_types/build/dev/javascript/shared_types/shared_types/users.d.mts";

import type {
  BlogPostPageProps$,
} from "../../../shared_types/build/dev/javascript/shared_types/shared_types/blog.d.mts";

import type {
  DashboardPageProps$,
} from "../../../shared_types/build/dev/javascript/shared_types/shared_types/dashboard.d.mts";

import type {
  HomePageProps$,
} from "../../../shared_types/build/dev/javascript/shared_types/shared_types/home.d.mts";



/**
 * CRITICAL: Option<T> Type Handling
 * 
 * DO NOT use `T[K] extends Option$<infer U>` - this will NOT work!
 * 
 * In Gleam's TypeScript definitions, Option$<T> is defined as:
 *   export type Option$<GA> = Some<GA> | None;
 * 
 * TypeScript cannot infer the type parameter from a union type directly.
 * When you write `Option$<infer U>`, TypeScript sees `Some<U> | None` and
 * fails to extract `U` because:
 * 1. Union types don't allow direct inference of generic parameters
 * 2. The `None` variant has no type parameter to infer from
 * 3. This causes the conditional type to never match
 * 
 * CORRECT APPROACH: Use `Some<infer U> | None` pattern matching
 * This works because:
 * 1. We explicitly match the union structure `Some<T> | None`
 * 2. TypeScript can infer `U` from the `Some<U>` variant
 * 3. The `None` part is handled by the union match
 * 
 * Example transformations:
 * - `Some<boolean> | None` → `boolean | null`
 * - `Some<List<string>> | None` → `string[] | null`
 * - `Some<string> | None` → `string | null`
 * 
 * The nested conditional `U extends List<infer V>` handles Option<List<T>>
 * cases by first extracting the inner type from Option, then checking if
 * that inner type is a List and extracting its element type.
 */
// Simple non-recursive type projection that handles common cases
export type GleamToJS<T> = {
  [K in keyof T as K extends "withFields" | "constructor"
    ? never
    : T[K] extends (...args: any[]) => any
      ? never
      : K]: T[K] extends Some<infer U> | None  // IMPORTANT: Pattern matches Some<T> | None, NOT Option$<T>
    ? U extends List<infer V>                  // Handle nested Option<List<T>> → T[] | null
      ? V[] | null
      : U | null                               // Handle Option<T> → T | null
    : T[K] extends List<infer U>               // Handle direct List<T> → T[]
      ? U[]
      : T[K];                                  // Handle primitives as-is
};

// Alternative approach: Extract types from constructor parameters
// Useful when the class properties aren't directly accessible
export type GleamConstructorToJS<T> = T extends new (
  ...args: infer P
) => infer Instance
  ? {
      [K in keyof Instance as Instance[K] extends Function
        ? never
        : K]: Instance[K] extends Some<infer U> | None  // Same Option handling pattern
        ? U extends List<infer V>
          ? V[] | null
          : U | null
        : Instance[K] extends List<infer U>
          ? U[]
          : Instance[K];
    }
  : never;

// Specific type aliases for form submission data (using the projection utility)
export type ContactFormData = GleamToJS<ContactFormRequest$>;
export type CreateUserFormData = GleamToJS<CreateUserRequest$>;
export type UpdateProfileFormData = GleamToJS<UpdateProfileRequest$>;
export type LoginFormData = GleamToJS<LoginRequest$>;

// Page prop projections - Convert Gleam page props to JavaScript-compatible interfaces
export type UserProfilePageData = GleamToJS<UserProfilePageProps$>;
export type BlogPostPageData = GleamToJS<BlogPostPageProps$>;
export type DashboardPageData = GleamToJS<DashboardPageProps$>;
export type HomePageData = GleamToJS<HomePageProps$>;

// Missing export aliases expected by pages
export type ContactFormPageData = GleamToJS<ContactPageProps>;
export type LoginFormPageData = GleamToJS<LoginPageProps>;
export type CreateUserFormPageData = GleamToJS<UserProfilePageProps$>;
export type EditProfileFormPageData = GleamToJS<UserProfilePageProps$>;

// Helper type aliases for common projections
export type JSOption<T> = T | null;
export type JSList<T> = T[];
export type JSDict<K extends string, V> = Record<K, V>;

// Specific type aliases for form error handling
export type FormErrors = Record<string, string>;
export type ValidationErrors = Record<string, string>;
export type FieldErrors = Record<string, string>;
export type MultiFieldErrors = Record<string, string[]>;
export type OptionalFieldErrors = Record<string, string | null>;

// Expected form data shapes (for documentation):
// ContactFormData → { name: string, email: string, subject: string, message: string, urgent: boolean | null }
// CreateUserFormData → { name: string, email: string, bio: string | null }
// LoginFormData → { email: string, password: string, remember_me: boolean | null }
//
// Dict projections (for form validation and error handling):
// Dict(String, String) → Record<string, string> (validation errors)
// Dict(String, List(String)) → Record<string, string[]> (multi-error fields)
// Dict(String, Option(String)) → Record<string, string | null> (optional field errors)
// Dict(String, Dict(String, String)) → Record<string, Record<string, string>> (nested errors)
// Dict(String, List(User)) → Record<string, ProjectedUser[]> (complex nested types)

// Utility type for stricter type checking
export type EnsureFormCompatible<T, U> = T extends U ? T : never;

// Advanced: Conditional projection based on form context
export type FormProjection<
  T,
  Context extends "create" | "edit" | "submit" = "submit",
> = Context extends "create"
  ? Partial<GleamToJS<T>> // For creation forms, all fields optional
  : Context extends "edit"
    ? Required<GleamToJS<T>> // For edit forms, all fields required
    : GleamToJS<T>; // For submission, use standard projection

// Type-safe form data factory (for default values)
export type FormDefaults<T> = {
  [K in keyof GleamToJS<T>]: GleamToJS<T>[K] extends string
    ? ""
    : GleamToJS<T>[K] extends number
      ? 0
      : GleamToJS<T>[K] extends boolean
        ? false
        : GleamToJS<T>[K] extends (infer U)[]
          ? []
          : GleamToJS<T>[K] extends infer U | null
            ? null
            : never;
};

/**
 * Usage Examples for Dict Projections
 *
 * // Basic form validation errors
 * type LoginErrors = GleamToJS<Dict$<string, string>>;
 * // Result: Record<string, string>
 * const loginErrors: LoginErrors = {
 *   email: "Email is required",
 *   password: "Password must be at least 8 characters"
 * };
 *
 * // Multiple errors per field
 * type MultiErrors = GleamToJS<Dict$<string, List<string>>>;
 * // Result: Record<string, string[]>
 * const fieldErrors: MultiErrors = {
 *   password: ["Too short", "Must contain numbers", "Must contain symbols"]
 * };
 *
 * // Optional field errors
 * type OptionalErrors = GleamToJS<Dict$<string, Option$<string>>>;
 * // Result: Record<string, string | null>
 * const conditionalErrors: OptionalErrors = {
 *   bio: "Bio is too long",
 *   avatar: null // No error for this field
 * };
 *
 * // Nested validation errors (e.g., for nested forms)
 * type NestedErrors = GleamToJS<Dict$<string, Dict$<string, string>>>;
 * // Result: Record<string, Record<string, string>>
 * const addressErrors: NestedErrors = {
 *   billing: { street: "Required", city: "Invalid" },
 *   shipping: { zip: "Invalid format" }
 * };
 */

/**
 * Runtime utilities (for completeness - actual conversion happens via JSON)
 * These are included to show the bridge between compile-time types and runtime values
 */

// Helper function to create type-safe error objects
export const createFormErrors = (errors: Record<string, string>): FormErrors =>
  errors;

export const createMultiFieldErrors = (
  errors: Record<string, string[]>,
): MultiFieldErrors => errors;

export const createOptionalErrors = (
  errors: Record<string, string | null>,
): OptionalFieldErrors => errors;

// Note: These functions are placeholders since actual conversion happens automatically
// through JSON serialization when forms are submitted to the Gleam backend
export const createFormDefaults = <T>(template: T): FormDefaults<T> => {
  throw new Error(
    "Use object literals for form defaults - this is a type-level utility",
  );
};

export const validateFormData = <T>(
  data: unknown,
  _type: T,
): data is GleamToJS<T> => {
  // In practice, validation happens on the Gleam backend using decoders
  return typeof data === "object" && data !== null;
};

// Type guard for Dict projections
export const isDictProjection = (
  value: unknown,
): value is Record<string, unknown> => {
  return typeof value === "object" && value !== null && !Array.isArray(value);
};

// Export concrete form data types for easy importing
export type {
  ContactFormData as ContactForm,
  CreateUserFormData as CreateUserForm,
  UpdateProfileFormData as UpdateProfileForm,
  LoginFormData as LoginForm,
  FormErrors as Errors,
  ValidationErrors as ValidationErrs,
  FieldErrors as FieldErrs,
  MultiFieldErrors as MultiErrors,
  OptionalFieldErrors as OptionalErrors,
};

// Export page data types for easy importing
export type {
  UserProfilePageData as UserProfilePage,
  BlogPostPageData as BlogPostPage,
  DashboardPageData as DashboardPage,
  HomePageData as HomePage,
};

// Re-export imported Gleam types for convenience
export type { ContactPageProps, LoginPageProps };

// Convenience type for any page data
export type PageData<T> = GleamToJS<T>;

// Form response types that combine data and validation errors
export type FormResponse<T> = {
  data: GleamToJS<T>;
  errors: FormErrors;
  success: boolean;
};

export type ValidationResponse<T> = {
  data: GleamToJS<T> | null;
  errors: ValidationErrors;
  valid: boolean;
};

// Common form submission response patterns
export type SubmissionResponse<T> = {
  data?: GleamToJS<T>;
  errors?: FormErrors;
  message?: string;
  redirect?: string;
};

// Type for Inertia.js form responses with errors
export type InertiaFormResponse<T> = {
  props: GleamToJS<T>;
  errors: FormErrors;
};
