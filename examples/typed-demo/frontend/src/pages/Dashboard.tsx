import type { DashboardPageProp$ } from "@shared_types/shared_types/dashboard.d.mts";
import type { PageProps } from "../types/gleam-projections";
import PageContainer from "../components/layout/PageContainer";
import SectionHeader from "../components/layout/SectionHeader";
import GridLayout from "../components/layout/GridLayout";
import StatCard from "../components/cards/StatCard";
import ContentCard from "../components/cards/ContentCard";
import StatusIndicator from "../components/data/StatusIndicator";
import ActivityList from "../components/data/ActivityList";
import {
  UsersIcon,
  PostsIcon,
  UserIcon,
  CheckCircleIcon,
} from "../components/ui/Icons";

export default function Dashboard(props: PageProps<DashboardPageProp$>) {
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
          icon={<UsersIcon className="text-white" />}
        />

        <StatCard
          title="Total Posts"
          value={props.post_count}
          variant="green"
          formatValue={true}
          icon={<PostsIcon className="text-white" />}
        />

        <StatCard
          title="New Signups"
          value={props.recent_signups ? props.recent_signups.length : 0}
          variant="yellow"
          icon={<UserIcon className="text-white" />}
        />

        <StatCard
          title="System Status"
          value={props.system_status}
          variant="purple"
          icon={<CheckCircleIcon className="text-white" />}
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
                    primary: email,
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

            <StatusIndicator label="Cache" status="Active" variant="purple" />
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
