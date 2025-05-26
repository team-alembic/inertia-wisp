import { Head, Link, router } from "@inertiajs/react";
import {
  HomePageProps,
  HomePagePropsSchema,
  withValidatedProps,
} from "../schemas";
import {
  CheckIcon,
  InfoIcon,
  LightningIcon,
  RefreshIcon,
  UploadIcon,
  UsersIcon,
} from "../components/icons";

interface PageHeaderProps {
  title: string;
  subtitle: string;
}

function PageHeader({ title, subtitle }: PageHeaderProps) {
  return (
    <div className="text-center mb-12">
      <div className="mx-auto h-16 w-16 rounded-full bg-gradient-to-r from-indigo-500 to-purple-600 flex items-center justify-center mb-6">
        <LightningIcon />
      </div>
      <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
        {title}
      </h1>
      <p className="mt-4 text-lg text-gray-600">{subtitle}</p>
    </div>
  );
}

interface ServerInfoCardProps {
  message: string;
  timestamp: string;
  userCount: number;
}

function ServerInfoCard({
  message,
  timestamp,
  userCount,
}: ServerInfoCardProps) {
  return (
    <div className="mb-8">
      <h2 className="text-2xl font-bold text-gray-900 mb-4">
        Server Information
      </h2>
      <div className="space-y-3">
        <div className="flex items-center justify-between p-3 bg-indigo-50 rounded-lg">
          <span className="text-sm font-medium text-gray-700">Message:</span>
          <span className="text-sm font-bold text-indigo-900">{message}</span>
        </div>
        <div className="flex items-center justify-between p-3 bg-cyan-50 rounded-lg">
          <span className="text-sm font-medium text-gray-700">Timestamp:</span>
          <span className="text-sm text-cyan-900">{timestamp}</span>
        </div>
        <div className="flex items-center justify-between p-3 bg-purple-50 rounded-lg">
          <span className="text-sm font-medium text-gray-700">User Count:</span>
          <span className="text-sm font-bold text-purple-900">{userCount}</span>
        </div>
      </div>
    </div>
  );
}

function NavigationLinks() {
  return (
    <div className="mb-8">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Navigation</h3>
      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        <Link
          href="/about"
          className="inline-flex items-center justify-center px-4 py-3 border border-transparent text-sm font-medium rounded-lg text-indigo-700 bg-indigo-100 hover:bg-indigo-200 transition-colors duration-200"
        >
          <InfoIcon />
          About
        </Link>
        <Link
          href="/users"
          className="inline-flex items-center justify-center px-4 py-3 border border-transparent text-sm font-medium rounded-lg text-green-700 bg-green-100 hover:bg-green-200 transition-colors duration-200"
        >
          <UsersIcon />
          Users (Forms Demo)
        </Link>
        <Link
          href="/upload"
          className="inline-flex items-center justify-center px-4 py-3 border border-transparent text-sm font-medium rounded-lg text-purple-700 bg-purple-100 hover:bg-purple-200 transition-colors duration-200 sm:col-span-2 lg:col-span-1"
        >
          <UploadIcon />
          File Upload Demo
        </Link>
      </div>
    </div>
  );
}

interface FeatureItemProps {
  title: string;
  description: string;
}

function FeatureItem({ title, description }: FeatureItemProps) {
  return (
    <div className="flex items-start space-x-3">
      <div className="flex-shrink-0">
        <div className="h-6 w-6 rounded-full bg-green-100 flex items-center justify-center">
          <CheckIcon />
        </div>
      </div>
      <div>
        <p className="text-sm font-medium text-gray-900">{title}</p>
        <div
          className="text-sm text-gray-500"
          dangerouslySetInnerHTML={{ __html: description }}
        />
      </div>
    </div>
  );
}

function DemoFeaturesList() {
  const features = [
    {
      title: "Navigation",
      description: "All page transitions use Inertia XHR requests",
    },
    {
      title: "Props System",
      description: "Server-side data passed to React components",
    },
    {
      title: "Forms & Validation",
      description:
        'Check out the <a href="/users" class="text-indigo-600 hover:text-indigo-500">Users section</a>',
    },
    {
      title: "File Uploads",
      description:
        'Try the <a href="/upload" class="text-indigo-600 hover:text-indigo-500">File Upload demo</a>',
    },
    {
      title: "Redirects",
      description: "Form submissions redirect properly",
    },
  ];

  return (
    <div className="mb-8">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">
        Demo Features
      </h3>
      <div className="space-y-4">
        {features.map((feature, index) => (
          <FeatureItem
            key={index}
            title={feature.title}
            description={feature.description}
          />
        ))}
      </div>
    </div>
  );
}

function TestNavigationButtons() {
  return (
    <div>
      <h4 className="text-lg font-semibold text-gray-900 mb-4">
        Test Navigation
      </h4>
      <div className="flex flex-col sm:flex-row gap-3">
        <button
          onClick={() => router.visit("/")}
          className="inline-flex items-center justify-center px-4 py-2 border border-indigo-300 text-sm font-medium rounded-md text-indigo-700 bg-white hover:bg-indigo-50 transition-colors duration-200"
        >
          <RefreshIcon />
          Reload Home (XHR)
        </button>
        <button
          onClick={() => (window.location.href = "/")}
          className="inline-flex items-center justify-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 transition-colors duration-200"
        >
          <RefreshIcon />
          Reload Home (Full)
        </button>
      </div>
    </div>
  );
}

interface AuthenticatedUserIndicatorProps {
  user: string;
}

function AuthenticatedUserIndicator({ user }: AuthenticatedUserIndicatorProps) {
  return (
    <div className="bg-gray-50 px-6 py-4">
      <div className="flex items-center justify-center">
        <div className="flex items-center space-x-2">
          <div className="h-2 w-2 bg-green-400 rounded-full"></div>
          <p className="text-sm text-gray-600">
            Logged in as:{" "}
            <span className="font-medium text-gray-900">{user}</span>
          </p>
        </div>
      </div>
    </div>
  );
}

interface MainLayoutProps {
  children: React.ReactNode;
}

function MainLayout({ children }: MainLayoutProps) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-cyan-50">
      <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
        {children}
      </div>
    </div>
  );
}

interface MainCardProps {
  children: React.ReactNode;
  auth?: { authenticated: boolean; user: string } | null | undefined;
}

function MainCard({ children, auth }: MainCardProps) {
  return (
    <div className="mx-auto max-w-3xl">
      <div className="bg-white shadow-xl ring-1 ring-gray-900/5 rounded-2xl overflow-hidden mb-8">
        <div className="p-6">{children}</div>
        {auth?.authenticated && <AuthenticatedUserIndicator user={auth.user} />}
      </div>
    </div>
  );
}

function Home({
  message,
  timestamp,
  user_count,
  auth,
  csrf_token,
}: HomePageProps) {
  return (
    <>
      <Head title="Welcome to Inertia Gleam" />

      <MainLayout>
        <PageHeader
          title="Welcome to Inertia Gleam!"
          subtitle="Full-stack web applications with Gleam and React"
        />

        <MainCard auth={auth}>
          <ServerInfoCard
            message={message}
            timestamp={timestamp}
            userCount={user_count}
          />

          <NavigationLinks />

          <DemoFeaturesList />

          <TestNavigationButtons />
        </MainCard>
      </MainLayout>
    </>
  );
}

export default withValidatedProps(HomePagePropsSchema, Home);
