export interface NavigationItem {
  name: string
  url: string
  active: boolean
}

export interface CurrentUser {
  name: string
  email: string
}

export interface HomePageProps {
  welcome_message: string
  navigation: NavigationItem[]
  csrf_token: string
  app_version: string
  current_user: CurrentUser
}
