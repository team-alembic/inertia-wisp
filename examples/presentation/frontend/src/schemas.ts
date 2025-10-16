// Zod schemas for validating props from Gleam backend
// These match the JSON structure produced by the backend encoders

import { z } from "zod";
import {
  SlideNavigationSchema,
  SlidePagePropsSchema,
  SlideSchema,
  UserSchema,
} from "./generated/schemas";

export { SlidePagePropsSchema, type SlidePageProps } from "./generated/schemas";

// ContactFormPageProps schema
export const ContactFormPagePropsSchema = z
  .object({
    name: z.string(),
    email: z.string(),
    message: z.string(),
    errors: z.record(z.string(), z.string()).optional(),
  })
  .strict();

export type ContactFormPageProps = z.infer<typeof ContactFormPagePropsSchema>;

// UsersTablePageProps schema
export const UsersTablePagePropsSchema = z
  .object({
    users: z.array(UserSchema),
    page: z.number(),
    total_pages: z.number(),
    demo_info: z.string().optional(),
  })
  .strict();

export type UsersTablePageProps = z.infer<typeof UsersTablePagePropsSchema>;
