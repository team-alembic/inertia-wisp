// Re-export types inferred from Zod schemas to eliminate redundancy
export type {
  User,
  CreateUserRequest,
  Auth,
  ValidationErrors,
  FormOldValues,
  BasePageProps,
  HomePageProps,
  AboutPageProps,
  UsersPageProps,
  ShowUserPageProps,
  CreateUserPageProps,
  EditUserPageProps,
  CreateUserFormData,
  EditUserFormData
} from '../schemas/index.js';