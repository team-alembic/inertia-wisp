import { Head } from "@inertiajs/react";
import {
  AboutPageProps,
  AboutPagePropsSchema,
  withValidatedProps,
} from "../schemas";
import {
  GradientBackground,
  PageHeader,
  NavigationLinks,
  TechnologyStack,
  WhySection,
  TestNavigation,
  AuthInfo,
  Card,
  SectionHeader,
} from "../components";
import { InfoIconLarge } from "../components/icons";

function About({ page_title, auth }: AboutPageProps) {
  const gleamReasons = [
    "Type safety without complexity",
    "Functional programming paradigm",
    "Excellent error messages",
    "Concurrent and fault-tolerant",
  ];

  const inertiaReasons = [
    "No API layer needed",
    "Server-side routing",
    "SPA-like experience",
    "Simple data flow",
  ];

  return (
    <>
      <Head title={page_title} />

      <GradientBackground variant="indigo">
        <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
          <PageHeader
            title={page_title}
            subtitle="Learn about this Inertia.js and Gleam integration"
            icon={<InfoIconLarge />}
          />

          <div className="mx-auto max-w-3xl">
            <Card variant="elevated" padding="none" className="overflow-hidden">
              <div className="p-6">
                <NavigationLinks />

                <div className="mb-8">
                  <SectionHeader level="h2" size="lg" className="mb-6">
                    About Inertia Gleam
                  </SectionHeader>

                  <div className="prose prose-indigo max-w-none">
                    <p className="text-gray-600 mb-6">
                      This demo showcases a full-stack application that bridges
                      the gap between modern frontend development and the
                      emerging Gleam programming language.
                    </p>

                    <TechnologyStack />

                    <div className="grid md:grid-cols-2 gap-6 mb-6">
                      <WhySection title="Why Gleam?" items={gleamReasons} />

                      <WhySection
                        title="Why Inertia.js?"
                        items={inertiaReasons}
                      />
                    </div>
                  </div>
                </div>

                <TestNavigation />
              </div>

              <AuthInfo auth={auth} />
            </Card>
          </div>
        </div>
      </GradientBackground>
    </>
  );
}

export default withValidatedProps(AboutPagePropsSchema, About);
