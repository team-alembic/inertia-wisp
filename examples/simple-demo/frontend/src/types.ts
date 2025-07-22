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

// Search functionality types
export interface SearchFilters {
  query: string;
  category?: string;
  sort_by: string;
}

export interface SearchAnalytics {
  total_filtered: number;
  matching_percentage: number;
  filter_performance_ms: number;
}

export interface UsersSearchProps {
  search_filters: SearchFilters;
  search_results: User[];
  analytics?: SearchAnalytics; // OptionalProp - only included when requested
}

// Dashboard types for DeferredProp demo
export interface UserAnalytics {
  total_users: number;
  active_users: number;
  growth_rate: number;
  new_users_this_month: number;
  average_session_duration: number;
}

export interface Activity {
  id: number;
  user_name: string;
  action: string;
  timestamp: string;
}

export interface ActivityFeed {
  recent_activities: Activity[];
  total_activities: number;
  last_updated: string;
}

export interface DashboardProps {
  user_count: number; // Always included (AlwaysProp)
  analytics?: UserAnalytics; // DeferredProp in "default" group
  activity_feed?: ActivityFeed; // DeferredProp in "activity" group
}

// News/Articles types
export type ArticleCategory =
  | "technology"
  | "business"
  | "science"
  | "sports"
  | "entertainment";

export interface Article {
  id: number;
  title: string;
  summary: string;
  author: string;
  published_at: string;
  category: ArticleCategory;
  read_time: number;
  image_url?: string;
}

export interface ArticleWithReadStatus {
  article: Article;
  is_read: boolean;
  read_at: string;
}

export interface PaginationMeta {
  current_page: number;
  per_page: number;
  total_count: number;
  last_page: number;
}

export interface NewsFeed {
  articles: ArticleWithReadStatus[];
  meta: PaginationMeta;
  has_more: boolean;
  total_unread: number;
  current_category: string;
}

// News page props
export interface NewsFeedProps {
  news_feed: NewsFeed;
  available_categories: ArticleCategory[];
}

export interface ArticleProps {
  article: ArticleWithReadStatus;
}
