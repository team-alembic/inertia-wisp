// TypeScript interfaces for form request types
// These match the Gleam types defined in the shared module

export interface CreateUserRequest {
  name: string;
  email: string;
  bio: string | null;
}

export interface UpdateProfileRequest {
  name: string;
  bio: string;
  interests: string[];
}

export interface LoginRequest {
  email: string;
  password: string;
  remember_me: boolean | null;
}

export interface ContactFormRequest {
  name: string;
  email: string;
  subject: string;
  message: string;
  urgent: boolean | null;
}