import type { FormEvent } from "react";
import { useForm } from "@inertiajs/react";
import { UpdateProfileRequest } from "../../../../shared_types/build/dev/javascript/shared_types/types.mjs";
import type { GleamToJS } from "../../types/gleam-projections";

interface EditProfileFormProps {
  user: {
    id: number;
    name: string;
    email: string;
    bio: string;
    interests?: string[] | null;
  };
  errors?: Record<string, string> | undefined;
}

// TypeScript projection of UpdateProfileRequest to JavaScript-compatible interface
// This automatically converts Gleam List<T> to T[] and maintains type safety
type UpdateProfileFormData = GleamToJS<UpdateProfileRequest>;

export default function EditProfileForm({
  user,
  errors,
}: EditProfileFormProps) {
  const { data, setData, put, processing } = useForm<UpdateProfileFormData>({
    name: user.name,
    bio: user.bio,
    interests: user.interests || [],
  });

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    put(`/users/${user.id}`);
  };

  const handleInterestChange = (index: number, value: string) => {
    const newInterests = [...data.interests];
    newInterests[index] = value;
    setData("interests", newInterests);
  };

  const addInterest = () => {
    setData("interests", [...data.interests, ""]);
  };

  const removeInterest = (index: number) => {
    const newInterests = data.interests.filter(
      (_: string, i: number) => i !== index,
    );
    setData("interests", newInterests);
  };

  return (
    <div className="max-w-2xl mx-auto p-6">
      <div className="bg-white shadow-lg rounded-lg overflow-hidden">
        <div className="bg-gradient-to-r from-purple-500 to-blue-600 px-6 py-8">
          <h1 className="text-3xl font-bold text-white">Edit Profile</h1>
          <p className="text-purple-100 mt-2">
            Update your profile information
          </p>
        </div>

        <div className="px-6 py-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label
                htmlFor="name"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Name
              </label>
              <input
                type="text"
                id="name"
                value={data.name}
                onChange={(e) => setData("name", e.target.value)}
                className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                  errors?.name ? "border-red-500" : "border-gray-300"
                }`}
                placeholder="Enter your full name"
              />
              {errors?.name && (
                <p className="mt-1 text-sm text-red-600">{errors.name}</p>
              )}
            </div>

            <div>
              <label
                htmlFor="bio"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Bio
              </label>
              <textarea
                id="bio"
                value={data.bio}
                onChange={(e) => setData("bio", e.target.value)}
                rows={4}
                className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                  errors?.bio ? "border-red-500" : "border-gray-300"
                }`}
                placeholder="Tell us about yourself"
              />
              {errors?.bio && (
                <p className="mt-1 text-sm text-red-600">{errors.bio}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Interests
              </label>
              <div className="space-y-2">
                {data.interests.map((interest: string, index: number) => (
                  <div key={index} className="flex items-center space-x-2">
                    <input
                      type="text"
                      value={interest}
                      onChange={(e) =>
                        handleInterestChange(index, e.target.value)
                      }
                      className="flex-1 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="Enter an interest"
                    />
                    <button
                      type="button"
                      onClick={() => removeInterest(index)}
                      className="px-3 py-2 text-red-600 bg-red-100 rounded-md hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-red-500"
                    >
                      Remove
                    </button>
                  </div>
                ))}
                <button
                  type="button"
                  onClick={addInterest}
                  className="px-4 py-2 text-blue-600 bg-blue-100 rounded-md hover:bg-blue-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  Add Interest
                </button>
              </div>
              {errors?.interests && (
                <p className="mt-1 text-sm text-red-600">{errors.interests}</p>
              )}
            </div>

            <div className="flex justify-between items-center pt-4">
              <button
                type="button"
                onClick={() => window.history.back()}
                className="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={processing}
                className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {processing ? "Updating..." : "Update Profile"}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
