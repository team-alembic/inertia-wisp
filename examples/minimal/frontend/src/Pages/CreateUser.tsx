import { Head } from "@inertiajs/react";
import {
  CreateUserPageProps,
  CreateUserPagePropsSchema,
  withValidatedProps,
} from "../schemas";
import {
  GradientBackground,
  Card,
  PageHeader,
  Alert,
  CreateUserForm,
  FeatureList,
  AuthInfo,
} from "../components";
import { LightningIcon } from "../components/icons";

function CreateUser({ errors, old, csrf_token, auth }: CreateUserPageProps) {
  const improvedFeatures = [
    "Runtime schema validation with detailed error handling",
    "Client-side validation before submission",
    "Type safety with compile-time and runtime checking",
    "Error merging - client errors shown immediately, server errors on submission",
    "Schema consistency with backend validation rules",
  ];

  return (
    <>
      <Head title="Create New User (Improved)" />

      <GradientBackground variant="indigo">
        <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
          <PageHeader
            title="Create New User"
            subtitle="Improved validation with advanced error handling"
            icon={<LightningIcon />}
            backHref="/users"
            backLabel="Back to Users"
          />

          <div className="mx-auto max-w-xl">
            <Card variant="elevated" padding="sm">
              <Alert variant="info" title="Improved Version">
                <p>
                  Enhanced form with prop validation, client-side validation,
                  and improved error handling patterns.
                </p>
              </Alert>

              <CreateUserForm
                errors={errors || {}}
                old={old || {}}
                csrf_token={csrf_token}
              />

              <FeatureList
                title="Improved Form Features"
                features={improvedFeatures}
                variant="blue"
              />

              <AuthInfo auth={auth} />
            </Card>
          </div>
        </div>
      </GradientBackground>
    </>
  );
}

export default withValidatedProps(CreateUserPagePropsSchema, CreateUser);
