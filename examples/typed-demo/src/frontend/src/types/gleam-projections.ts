import type { Option$ } from "../../../shared/build/dev/javascript/gleam_stdlib/gleam/option.d.mts";
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
 * - Gleam classes → Plain JavaScript objects
 *
 * This enables full type safety while maintaining compatibility with JavaScript form libraries
 * like Inertia.js useForm hook, which expects plain objects rather than class instances.
 */

// Advanced recursive type projection that handles nested Gleam types
type ProjectGleamType<T> =
  T extends Option$<any>
    ? T extends { 0: infer U } 
      ? ProjectGleamType<U> | null 
      : null
    : T extends List<infer U>
      ? ProjectGleamType<U>[]
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

// Expected form data shapes (for documentation):
// ContactFormData → { name: string, email: string, subject: string, message: string, urgent: boolean | null }
// CreateUserFormData → { name: string, email: string, bio: string | null }
// LoginFormData → { email: string, password: string, remember_me: boolean | null }

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
 * Runtime utilities (for completeness - actual conversion happens via JSON)
 * These are included to show the bridge between compile-time types and runtime values
 */

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

// Export concrete form data types for easy importing
export type {
  ContactFormData as ContactForm,
  CreateUserFormData as CreateUserForm,
  UpdateProfileFormData as UpdateProfileForm,
  LoginFormData as LoginForm,
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
