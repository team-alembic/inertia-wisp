import { z } from "zod";

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

export type CreateUserFormData = z.infer<typeof CreateUserFormSchema>;
export type EditUserFormData = z.infer<typeof EditUserFormSchema>;