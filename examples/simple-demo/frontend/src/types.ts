export interface NavigationItem {
  name: string;
  url: string;
  active: boolean;
}

export interface CurrentUser {
  name: string;
  email: string;
}

export interface HomePageProps {
  welcome_message: string;
  navigation: NavigationItem[];
  csrf_token: string;
  app_version: string;
  current_user: CurrentUser;
}

// User management types
export interface User {
  id: number;
  name: string;
  email: string;
  created_at: string;
}

export interface UserFormData {
  name: string;
  email: string;
}

export interface Pagination {
  current_page: number;
  total_pages: number;
  per_page: number;
}

// User page props
export interface UsersIndexProps {
  users: User[];
  user_count: number;
  search_query: string;
  pagination?: Pagination;
}

export interface UsersCreateProps {
  form_data: UserFormData;
  errors?: Record<string, string>;
}

export interface UsersShowProps {
  user: User;
}

export interface UsersEditProps {
  user?: User;
  form_data?: UserFormData;
  errors?: Record<string, string>;
}
