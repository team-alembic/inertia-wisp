import { Head, router } from "@inertiajs/react";
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
import {
  Button,
  LinkButton,
  InfoRow,
  SectionHeader,
} from "../components";

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
      <SectionHeader level="h2" size="lg">
        Server Information
      </SectionHeader>
      <div className="space-y-3">
        <InfoRow label="Message" value={message} variant="indigo" />
        <InfoRow label="Timestamp" value={timestamp} variant="cyan" />
        <InfoRow label="User Count" value={userCount} variant="purple" />
      </div>
    </div>
  );
}

function NavigationLinks() {
  return (
    <div className="mb-8">
      <SectionHeader>Navigation</SectionHeader>
      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        <LinkButton
          href="/about"
          variant="indigo"
          icon={<InfoIcon />}
        >
          About
        </LinkButton>
        <LinkButton
          href="/users"
          variant="green"
          icon={<UsersIcon />}
        >
          Users (Forms Demo)
        </LinkButton>
        <LinkButton
          href="/upload"
          variant="purple"
          icon={<UploadIcon />}
          className="sm:col-span-2 lg:col-span-1"
        >
          File Upload Demo
        </LinkButton>
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
      <SectionHeader>
        Demo Features
      </SectionHeader>
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
      <SectionHeader level="h4">
        Test Navigation
      </SectionHeader>
      <div className="flex flex-col sm:flex-row gap-3">
        <Button
          onClick={() => router.visit("/")}
          variant="outline"
          icon={<RefreshIcon />}
        >
          Reload Home (XHR)
        </Button>
        <Button
          onClick={() => (window.location.href = "/")}
          variant="ghost"
          icon={<RefreshIcon />}
        >
          Reload Home (Full)
        </Button>
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
