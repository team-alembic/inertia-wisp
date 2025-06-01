import type { DashboardPageProps } from "@shared_types/shared_types/dashboard.d.mts";
import type { ProjectType } from "../types/gleam-projections";
import PageContainer from "../components/layout/PageContainer";
import SectionHeader from "../components/layout/SectionHeader";
import GridLayout from "../components/layout/GridLayout";
import StatCard from "../components/cards/StatCard";
import ContentCard from "../components/cards/ContentCard";
import StatusIndicator from "../components/data/StatusIndicator";
import ActivityList from "../components/data/ActivityList";

export default function Dashboard(props: ProjectType<DashboardPageProps>) {
  return (
    <PageContainer maxWidth="6xl">
      <SectionHeader 
        title="Dashboard" 
        subtitle="Welcome to your admin dashboard"
        variant="large"
      />

      <GridLayout columns={{ md: 2, lg: 4 }} className="mb-8">
        <StatCard
          title="Total Users"
          value={props.user_count}
          variant="blue"
          formatValue={true}
          icon={
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z" />
            </svg>
          }
        />

        <StatCard
          title="Total Posts"
          value={props.post_count}
          variant="green"
          formatValue={true}
          icon={
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path d="M2 5a2 2 0 012-2h7a2 2 0 012 2v4a2 2 0 01-2 2H9l-3 3v-3H4a2 2 0 01-2-2V5z" />
              <path d="M15 7v2a4 4 0 01-4 4H9.828l-1.766 1.767c.28.149.599.233.938.233h2l3 3v-3h2a2 2 0 002-2V9a2 2 0 00-2-2h-1z" />
            </svg>
          }
        />

        <StatCard
          title="New Signups"
          value={props.recent_signups ? props.recent_signups.length : 0}
          variant="yellow"
          icon={
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path
                fillRule="evenodd"
                d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
                clipRule="evenodd"
              />
            </svg>
          }
        />

        <StatCard
          title="System Status"
          value={props.system_status}
          variant="purple"
          icon={
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path
                fillRule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clipRule="evenodd"
              />
            </svg>
          }
        />
      </GridLayout>

      <GridLayout columns={{ lg: 2 }}>
        <ContentCard>
          <SectionHeader title="Recent Signups" />
          <ActivityList
            items={
              props.recent_signups && props.recent_signups.length > 0
                ? props.recent_signups.map((email: string, index: number) => ({
                    id: index.toString(),
                    primary: email
                  }))
                : []
            }
            emptyMessage="No recent signups data loaded. This is an optional prop that's only included when specifically requested."
          />
        </ContentCard>

        <ContentCard>
          <SectionHeader title="System Overview" />
          <div className="space-y-4">
            <StatusIndicator
              label="Server Status"
              status="Online"
              variant="green"
            />

            <StatusIndicator
              label="Database"
              status="Connected"
              variant="blue"
            />

            <StatusIndicator
              label="Cache"
              status="Active"
              variant="purple"
            />
          </div>

          <div className="mt-6 p-4 bg-gray-50 rounded-lg">
            <p className="text-sm text-gray-600">
              <strong>Status:</strong> {props.system_status}
            </p>
            <p className="text-xs text-gray-500 mt-1">
              Last updated: {new Date().toLocaleString()}
            </p>
          </div>
        </ContentCard>
      </GridLayout>
    </PageContainer>
  );
}
