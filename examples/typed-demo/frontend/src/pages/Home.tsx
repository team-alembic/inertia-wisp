import type { HomePageProps } from "@shared_types/shared_types/home.mjs";
import type { ProjectType } from "../types/gleam-projections";
import PageContainer from "../components/layout/PageContainer";
import SectionHeader from "../components/layout/SectionHeader";
import GridLayout from "../components/layout/GridLayout";
import FeatureCard from "../components/cards/FeatureCard";
import ContentCard from "../components/cards/ContentCard";
import ActionButton from "../components/interactive/ActionButton";

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
            icon={
              <svg
                className="w-6 h-6 text-white"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            }
          />

          <FeatureCard
            title="Shared Types"
            description="Define your data structures once in Gleam and automatically generate TypeScript types for your frontend."
            iconColor="green"
            icon={
              <svg
                className="w-6 h-6 text-white"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z" />
              </svg>
            }
          />

          <FeatureCard
            title="Transformations"
            description="Build your props incrementally using transformation functions while maintaining full type safety."
            iconColor="purple"
            icon={
              <svg
                className="w-6 h-6 text-white"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path d="M4 4a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2H4zm12 4l-6 4-6-4h12z" />
              </svg>
            }
          />

          <FeatureCard
            title="Partial Reloads"
            description="Keep all the benefits of Inertia.js partial reloads while enjoying static type checking."
            iconColor="orange"
            icon={
              <svg
                className="w-6 h-6 text-white"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path
                  fillRule="evenodd"
                  d="M4 2a1 1 0 011 1v2.101a7.002 7.002 0 0111.601 2.566 1 1 0 11-1.885.666A5.002 5.002 0 005.999 7H9a1 1 0 010 2H4a1 1 0 01-1-1V3a1 1 0 011-1zm.008 9.057a1 1 0 011.276.61A5.002 5.002 0 0014.001 13H11a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0v-2.101a7.002 7.002 0 01-11.601-2.566 1 1 0 01.61-1.276z"
                  clipRule="evenodd"
                />
              </svg>
            }
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
