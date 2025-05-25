// Types that match the Gleam backend types

export interface User {
  id: number;
  name: string;
  email: string;
}

export interface CreateUserRequest {
  name: string;
  email: string;
  _token: string;
}

export interface Auth {
  authenticated: boolean;
  user: string;
}

export interface ValidationErrors {
  [key: string]: string;
}

export interface FormOldValues {
  name?: string;
  email?: string;
}

// Page component props
export interface BasePageProps {
  auth?: Auth;
  csrf_token: string;
  errors?: ValidationErrors;
}

export interface HomePageProps extends BasePageProps {
  message: string;
  timestamp: string;
  user_count: number;
}

export interface AboutPageProps extends BasePageProps {
  page_title: string;
}

export interface UsersPageProps extends BasePageProps {
  users: User[];
}

export interface ShowUserPageProps extends BasePageProps {
  user: User;
}

export interface CreateUserPageProps extends BasePageProps {
  old?: FormOldValues;
}

export interface EditUserPageProps extends BasePageProps {
  user: User;
}