import { Head, router } from "@inertiajs/react";
import {
  UsersPageProps,
  UsersPagePropsSchema,
  withValidatedProps,
} from "../schemas";
import {
  PageHeader,
  Card,
  LinkButton,
  UsersTable,
  EmptyUsersState,
  DemoNotes,
  AuthInfo,
  GradientBackground,
} from "../components";
import { UsersIconLarge, PlusIcon } from "../components/icons";

function Users({ users, auth, csrf_token }: UsersPageProps) {
  const handleDelete = (userId: number) => {
    if (confirm("Are you sure you want to delete this user?")) {
      router.post(`/users/${userId}/delete`, {
        _token: csrf_token,
      });
    }
  };

  return (
    <>
      <Head title="Users" />

      <GradientBackground>
        <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
          <PageHeader
            title="Users"
            subtitle="Manage users with forms, validation, and CRUD operations"
            icon={<UsersIconLarge />}
          />

          <div className="mx-auto max-w-6xl">
            {/* Create User Button */}
            <div className="flex justify-center mb-8">
              <LinkButton
                href="/users/create"
                variant="indigo"
                size="lg"
                icon={<PlusIcon />}
              >
                Create New User
              </LinkButton>
            </div>

            {/* Main Card */}
            <Card variant="elevated" padding="none" className="overflow-hidden">
              {users.length === 0 ? (
                <EmptyUsersState />
              ) : (
                <>
                  <UsersTable users={users} onDelete={handleDelete} />
                  <DemoNotes />
                </>
              )}

              {auth?.authenticated && <AuthInfo auth={auth} />}
            </Card>
          </div>
        </div>
      </GradientBackground>
    </>
  );
}

export default withValidatedProps(UsersPagePropsSchema, Users);
