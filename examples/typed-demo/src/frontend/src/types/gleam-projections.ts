import type { Option$ } from "../../../shared/build/dev/javascript/gleam_stdlib/gleam/option.d.mts";
import type { Dict$ } from "../../../shared/build/dev/javascript/gleam_stdlib/gleam/dict.d.mts";
import type { List } from "../../../shared/build/dev/javascript/shared_types/gleam.d.mts";
import type {
  ContactFormRequest,
  CreateUserRequest,
  UpdateProfileRequest,
  LoginRequest,
  UserProfilePageProps,
  BlogPostPageProps,
  DashboardPageProps,
  HomePageProps,
  CreateUserFormProps,
  EditProfileFormProps,
  LoginFormProps,
  ContactFormProps,
} from "../../../shared/build/dev/javascript/shared_types/types.d.mts";

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

// Advanced recursive type projection that handles nested Gleam types
type ProjectGleamType<T> =
  T extends Option$<any>
    ? T extends { 0: infer U } 
      ? ProjectGleamType<U> | null 
      : null
    : T extends List<infer U>
      ? ProjectGleamType<U>[]
      : T extends Dict$<infer K, infer V>
        ? K extends string
          ? V extends string
            ? Record<string, string>
            : V extends List<infer U>
              ? Record<string, ProjectGleamType<U>[]>
              : V extends Option$<infer W>
                ? Record<string, ProjectGleamType<W> | null>
                : Record<string, ProjectGleamType<V>>
          : Record<string, ProjectGleamType<V>>
        : T extends object
          ? {
              [K in keyof T as K extends "withFields"
                ? never
                : K]: ProjectGleamType<T[K]>;
            }
          : T;

// Main utility type: Transforms Gleam class to JavaScript-compatible interface
// Filters out methods (functions) and projects all property types
export type GleamToJS<T> = {
  [K in keyof T as K extends "withFields" ? never : K]: ProjectGleamType<T[K]>;
};

// Alternative approach: Extract types from constructor parameters
// Useful when the class properties aren't directly accessible
export type GleamConstructorToJS<T> = T extends new (
  ...args: infer P
) => infer Instance
  ? {
      [K in keyof Instance as Instance[K] extends Function
        ? never
        : K]: ProjectGleamType<Instance[K]>;
    }
  : never;

// Specific type aliases for form submission data (using the projection utility)
export type ContactFormData = GleamToJS<ContactFormRequest>;
export type CreateUserFormData = GleamToJS<CreateUserRequest>;
export type UpdateProfileFormData = GleamToJS<UpdateProfileRequest>;
export type LoginFormData = GleamToJS<LoginRequest>;

// Page prop projections - Convert Gleam page props to JavaScript-compatible interfaces
export type UserProfilePageData = GleamToJS<UserProfilePageProps>;
export type BlogPostPageData = GleamToJS<BlogPostPageProps>;
export type DashboardPageData = GleamToJS<DashboardPageProps>;
export type HomePageData = GleamToJS<HomePageProps>;

// Form page prop projections - For pages that render forms
export type CreateUserFormPageData = GleamToJS<CreateUserFormProps>;
export type EditProfileFormPageData = GleamToJS<EditProfileFormProps>;
export type LoginFormPageData = GleamToJS<LoginFormProps>;
export type ContactFormPageData = GleamToJS<ContactFormProps>;

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
export const createFormErrors = (errors: Record<string, string>): FormErrors => errors;

export const createMultiFieldErrors = (errors: Record<string, string[]>): MultiFieldErrors => errors;

export const createOptionalErrors = (errors: Record<string, string | null>): OptionalFieldErrors => errors;

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
export const isDictProjection = (value: unknown): value is Record<string, unknown> => {
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
  CreateUserFormPageData as CreateUserFormPage,
  EditProfileFormPageData as EditProfileFormPage,
  LoginFormPageData as LoginFormPage,
  ContactFormPageData as ContactFormPage,
};

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
