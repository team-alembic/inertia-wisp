import type { HomePageProps } from "@shared_types/shared_types/home.mjs";
import type { ProjectType } from "../types/gleam-projections";
import PageContainer from "../components/layout/PageContainer";
import SectionHeader from "../components/layout/SectionHeader";
import GridLayout from "../components/layout/GridLayout";
import FeatureCard from "../components/cards/FeatureCard";
import ContentCard from "../components/cards/ContentCard";
import ActionButton from "../components/interactive/ActionButton";
import { CheckIcon, TeamIcon, MailIcon, RefreshIcon } from "../components/ui/Icons";

export default function Home(props: ProjectType<HomePageProps>) {
  console.log({ props });
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <PageContainer>
        <div className="text-center py-12">
          <h1 className="text-5xl font-bold text-gray-900 mb-4">
            {props.title}
          </h1>
          <p className="text-xl text-gray-600 mb-12">{props.message}</p>
        </div>

        <GridLayout columns={{ md: 2 }} className="mb-12">
          <FeatureCard
            title="Type Safety"
            description="Enjoy compile-time type safety across your entire stack with shared Gleam and TypeScript definitions."
            iconColor="blue"
            icon={<CheckIcon className="text-white" />}
          />

          <FeatureCard
            title="Shared Types"
            description="Define your data structures once in Gleam and automatically generate TypeScript types for your frontend."
            iconColor="green"
            icon={<TeamIcon className="text-white" />}
          />

          <FeatureCard
            title="Transformations"
            description="Build your props incrementally using transformation functions while maintaining full type safety."
            iconColor="purple"
            icon={<MailIcon className="text-white" />}
          />

          <FeatureCard
            title="Partial Reloads"
            description="Keep all the benefits of Inertia.js partial reloads while enjoying static type checking."
            iconColor="orange"
            icon={<RefreshIcon className="text-white" />}
          />
        </GridLayout>

        <ContentCard variant="elevated" padding="large">
          <SectionHeader title="Features" variant="large" />
          <GridLayout columns={{ md: 2 }} gap="small">
            {props.features.map((feature: string, index: number) => (
              <div key={index} className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                <span className="text-gray-700">{feature}</span>
              </div>
            ))}
          </GridLayout>
        </ContentCard>

        <div className="text-center mt-12">
          <SectionHeader title="Demo Pages" variant="large" />
          <GridLayout columns={{ md: 2 }} className="mb-8">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-4">
                View Examples
              </h3>
              <div className="flex flex-col space-y-3">
                <ActionButton href="/user/1" variant="blue">
                  View User Profile
                </ActionButton>
                <ActionButton href="/blog/1" variant="green">
                  Read Blog Post
                </ActionButton>
                <ActionButton href="/dashboard" variant="purple">
                  View Dashboard
                </ActionButton>
              </div>
            </div>
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-4">
                Form Examples
              </h3>
              <div className="flex flex-col space-y-3">
                <ActionButton href="/users/create" variant="indigo">
                  Create User Form
                </ActionButton>
                <ActionButton href="/users/1/edit" variant="teal">
                  Edit Profile Form
                </ActionButton>
                <ActionButton href="/auth/login" variant="orange">
                  Login Form
                </ActionButton>
                <ActionButton href="/contact" variant="pink">
                  Contact Form
                </ActionButton>
              </div>
            </div>
          </GridLayout>
        </div>
      </PageContainer>
    </div>
  );
}
