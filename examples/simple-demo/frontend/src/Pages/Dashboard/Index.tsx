import { Head } from "@inertiajs/react";
import { DashboardProps } from "../../types";
import { TechBanner } from "../../components/TechBanner";
import { AnalyticsPanel } from "../../components/AnalyticsPanel";
import { ActivityPanel } from "../../components/ActivityPanel";
import { TechFooter } from "../../components/TechFooter";
import { DashboardHeader } from "../../components/DashboardHeader";
import { KeyMetrics } from "../../components/KeyMetrics";
import { Page, PageContent } from "../../components/ui/Layout";

export default function Index({
  user_count,
  analytics,
  activity_feed,
}: DashboardProps) {
  return (
    <>
      <Head title="Executive Dashboard - Analytics Platform" />

      <Page>
        <DashboardHeader />

        <PageContent>
          <KeyMetrics user_count={user_count} />

          {/* Tech Info Banner */}
          <TechBanner />

          {/* Analytics Dashboard Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <AnalyticsPanel analytics={analytics} />
            <ActivityPanel activity_feed={activity_feed} />
          </div>

          {/* Footer Tech Info */}
          <TechFooter />
        </PageContent>
      </Page>
    </>
  );
}
