import { Head } from "@inertiajs/react";
import { EditUserPageProps, EditUserPagePropsSchema, withValidatedProps } from "../schemas";
import { 
  GradientBackground,
  Card,
  EditUserPageHeader,
  InfoRow,
  EditUserForm,
  Alert,
  EditUserDemoNotes,
  AuthInfo
} from "../components";

function EditUser({ user, errors, csrf_token, auth }: EditUserPageProps) {
  const hasValidationErrors = errors?.name || errors?.email;

  return (
    <>
      <Head title={`Edit User: ${user.name}`} />
      
      <GradientBackground variant="indigo">
        <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
          
          <EditUserPageHeader 
            userName={user.name}
            userId={user.id}
          />

          <div className="mx-auto max-w-xl">
            
            <Card className="shadow-xl ring-1 ring-gray-900/5">
              
              {hasValidationErrors && (
                <Alert variant="error" title="Validation errors:" className="m-6">
                  <ul className="list-disc pl-5 space-y-1">
                    {errors?.name && (
                      <li><strong>Name:</strong> {errors.name}</li>
                    )}
                    {errors?.email && (
                      <li><strong>Email:</strong> {errors.email}</li>
                    )}
                  </ul>
                </Alert>
              )}

              <div className="p-6">
                
                <InfoRow
                  label="Editing User ID"
                  value={user.id}
                  variant="indigo"
                  className="mb-6"
                />
                
                <EditUserForm
                  user={user}
                  errors={errors}
                  csrf_token={csrf_token}
                />

              </div>

              <EditUserDemoNotes />

              <AuthInfo auth={auth} />

            </Card>
          </div>
        </div>
      </GradientBackground>
    </>
  );
}

export default withValidatedProps(EditUserPagePropsSchema, EditUser);