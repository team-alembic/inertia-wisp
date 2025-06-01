import type { UserProfilePageProps } from "@shared_types/shared_types/users.mjs";
import type { ProjectType } from "../../types/gleam-projections";

export default function Foo(props: ProjectType<UserProfilePageProps>) {
  const userProfile = props.user_profile;
  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="bg-white shadow-lg rounded-lg overflow-hidden">
        <div className="bg-gradient-to-r from-blue-500 to-purple-600 px-6 py-8">
          <h1 className="text-3xl font-bold text-white">{userProfile.name}</h1>
          <p className="text-blue-100 mt-2">{userProfile.email}</p>
        </div>

        <div className="px-6 py-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h2 className="text-xl font-semibold text-gray-800 mb-4">
                Profile Information
              </h2>
              <div className="space-y-3">
                <div>
                  <span className="text-sm font-medium text-gray-500">
                    User ID
                  </span>
                  <p className="text-gray-900">{userProfile.id}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-500">
                    Email
                  </span>
                  <p className="text-gray-900">{userProfile.email}</p>
                </div>
                <div>
                  <span className="text-sm font-medium text-gray-500">Bio</span>
                  <p className="text-gray-900">{userProfile.bio}</p>
                </div>
              </div>
            </div>

            <div>
              <h2 className="text-xl font-semibold text-gray-800 mb-4">
                Interests
              </h2>
              <div className="flex flex-wrap gap-2">
                {userProfile.interests.length > 0 ? (
                  userProfile.interests.map(
                    (interest: string, index: number) => (
                      <span
                        key={index}
                        className="px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full"
                      >
                        {interest}
                      </span>
                    ),
                  )
                ) : (
                  <p className="text-gray-500 italic">
                    No interests specified.
                  </p>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
