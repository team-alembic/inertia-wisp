import { z } from "zod";
import React from "react";

// Zod schemas that match our TypeScript types and Gleam backend types

export const UserSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.string().email(),
});

export const CreateUserRequestSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Email must be valid"),
  _token: z.string(),
});

export const AuthSchema = z.object({
  authenticated: z.boolean(),
  user: z.string(),
});

export const ValidationErrorsSchema = z.record(z.string());

export const FormOldValuesSchema = z.object({
  name: z.string().optional(),
  email: z.string().optional(),
});

// Base page props schema
export const BasePagePropsSchema = z.object({
  auth: AuthSchema.optional(),
  csrf_token: z.string(),
  errors: ValidationErrorsSchema.optional(),
});

// Page-specific schemas
export const HomePagePropsSchema = BasePagePropsSchema.extend({
  message: z.string(),
  timestamp: z.string(),
  user_count: z.number(),
});

export const AboutPagePropsSchema = BasePagePropsSchema.extend({
  page_title: z.string(),
});

export const UsersPagePropsSchema = BasePagePropsSchema.extend({
  users: z.array(UserSchema),
});

export const ShowUserPagePropsSchema = BasePagePropsSchema.extend({
  user: UserSchema,
});

export const CreateUserPagePropsSchema = BasePagePropsSchema.extend({
  old: FormOldValuesSchema.optional(),
});

export const EditUserPagePropsSchema = BasePagePropsSchema.extend({
  user: UserSchema,
});

export const UploadedFileSchema = z.object({
  filename: z.string(),
  content_type: z.string(),
  size: z.number(),
});

export const UploadFormPagePropsSchema = BasePagePropsSchema.extend({
  max_files: z.number(),
  max_size_mb: z.number(),
  allowed_types: z.array(z.string()).optional(),
});

export const UploadSuccessPagePropsSchema = BasePagePropsSchema.extend({
  success: z.string(),
  uploaded_files: z.record(UploadedFileSchema),
});

// Form data schemas for client-side validation
export const CreateUserFormSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Email must be valid"),
});

export const EditUserFormSchema = CreateUserFormSchema;

// Runtime validation helpers
export function validatePageProps<T>(schema: z.ZodSchema<T>, data: unknown): T {
  try {
    return schema.parse(data);
  } catch (error) {
    console.error("Page props validation failed:", error);
    throw new Error("Invalid page props received from server");
  }
}

export function validateFormData<T>(schema: z.ZodSchema<T>, data: unknown): { success: true; data: T } | { success: false; errors: Record<string, string> } {
  try {
    const validData = schema.parse(data);
    return { success: true, data: validData };
  } catch (error) {
    if (error instanceof z.ZodError) {
      const errors: Record<string, string> = {};
      error.errors.forEach(err => {
        if (err.path.length > 0) {
          const key = err.path[0];
          if (typeof key === 'string') {
            errors[key] = err.message;
          }
        }
      });
      return { success: false, errors };
    }
    throw error;
  }
}

// Type inference from schemas (alternative to manually defined types)
export type User = z.infer<typeof UserSchema>;
export type CreateUserRequest = z.infer<typeof CreateUserRequestSchema>;
export type Auth = z.infer<typeof AuthSchema>;
export type ValidationErrors = z.infer<typeof ValidationErrorsSchema>;
export type FormOldValues = z.infer<typeof FormOldValuesSchema>;

export type BasePageProps = z.infer<typeof BasePagePropsSchema>;
export type HomePageProps = z.infer<typeof HomePagePropsSchema>;
export type AboutPageProps = z.infer<typeof AboutPagePropsSchema>;
export type UsersPageProps = z.infer<typeof UsersPagePropsSchema>;
export type ShowUserPageProps = z.infer<typeof ShowUserPagePropsSchema>;
export type CreateUserPageProps = z.infer<typeof CreateUserPagePropsSchema>;
export type EditUserPageProps = z.infer<typeof EditUserPagePropsSchema>;
export type UploadedFile = z.infer<typeof UploadedFileSchema>;
export type UploadFormPageProps = z.infer<typeof UploadFormPagePropsSchema>;
export type UploadSuccessPageProps = z.infer<typeof UploadSuccessPagePropsSchema>;

export type CreateUserFormData = z.infer<typeof CreateUserFormSchema>;
export type EditUserFormData = z.infer<typeof EditUserFormSchema>;

// Error boundary component for validation failures
export interface ValidationErrorFallbackProps {
  error: Error;
  reset: () => void;
}

export function DefaultValidationErrorFallback({ error, reset }: ValidationErrorFallbackProps) {
  return React.createElement('div', {
    style: {
      padding: '20px',
      border: '2px solid red',
      borderRadius: '4px',
      backgroundColor: '#fff5f5',
      color: '#c53030',
      fontFamily: 'monospace'
    }
  }, [
    React.createElement('h2', { key: 'title' }, 'Page Props Validation Error'),
    React.createElement('p', { key: 'message' }, error.message),
    React.createElement('button', { 
      key: 'retry',
      onClick: reset,
      style: {
        padding: '8px 16px',
        backgroundColor: '#c53030',
        color: 'white',
        border: 'none',
        borderRadius: '4px',
        cursor: 'pointer'
      }
    }, 'Retry')
  ]);
}

// Configuration options for the HOC
export interface WithValidatedPropsOptions {
  // Custom error boundary component to show when validation fails
  ErrorFallback?: React.ComponentType<ValidationErrorFallbackProps>;
  // Whether to log validation errors to console (default: true in dev)
  logErrors?: boolean;
  // Custom error handler (called before showing error boundary)
  onError?: (error: Error, props: unknown) => void;
}

// Higher-order component for validating page props
export function withValidatedProps<T>(
  schema: z.ZodSchema<T>,
  Component: React.ComponentType<T>,
  options: WithValidatedPropsOptions = {}
): React.ComponentType<any> {
  const {
    ErrorFallback = DefaultValidationErrorFallback,
    logErrors = false, // Default to false, can be overridden in options
    onError
  } = options;

  const WrappedComponent = function ValidatedComponent(props: unknown) {
    const [error, setError] = React.useState<Error | null>(null);

    const handleReset = React.useCallback(() => {
      setError(null);
    }, []);

    React.useEffect(() => {
      try {
        validatePageProps(schema, props);
        setError(null);
      } catch (validationError) {
        const error = validationError instanceof Error ? validationError : new Error('Validation failed');
        
        if (logErrors) {
          console.error('Page props validation failed:', error, { props });
        }
        
        if (onError) {
          onError(error, props);
        }
        
        setError(error);
      }
    }, [props, logErrors, onError]);

    if (error) {
      return React.createElement(ErrorFallback, { error, reset: handleReset });
    }

    try {
      const validatedProps = validatePageProps(schema, props);
      return React.createElement(Component as any, validatedProps as any);
    } catch (validationError) {
      // This shouldn't happen due to the useEffect, but handle it as fallback
      const error = validationError instanceof Error ? validationError : new Error('Validation failed');
      return React.createElement(ErrorFallback, { error, reset: handleReset });
    }
  };

  // Set display name for better debugging
  WrappedComponent.displayName = `withValidatedProps(${Component.displayName || Component.name || 'Component'})`;

  return WrappedComponent;
}

// Simplified version for common use case
export function validateProps<T>(
  schema: z.ZodSchema<T>,
  Component: React.ComponentType<T>
): React.ComponentType<any> {
  return withValidatedProps(schema, Component);
}