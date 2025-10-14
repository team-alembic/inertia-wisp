import { router, Deferred } from "@inertiajs/react";
import {
  UsersTablePagePropsSchema,
  type UsersTablePageProps,
} from "../schemas";
import { validateProps } from "../lib/validateProps";

function UsersTable({
  users,
  page,
  total_pages,
  demo_info,
}: UsersTablePageProps) {
  const handlePrevious = () => {
    router.get(
      `/users/table?page=${page - 1}`,
      {},
      {
        only: ["users", "page"],
      },
    );
  };

  const handleNext = () => {
    router.get(
      `/users/table?page=${page + 1}`,
      {},
      {
        only: ["users", "page"],
      },
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-purple-800 to-indigo-900 p-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-white mb-4">
            Pagination Demo
          </h1>
          <p className="text-purple-200 text-lg">
            Navigate pages and watch the network tab - only the table data
            reloads!
          </p>
        </div>

        {/* Demo Info Badge - DeferProp loads separately! */}
        <Deferred
          data="demo_info"
          fallback={
            <div className="mb-6 bg-yellow-500/20 border border-yellow-400 rounded-lg p-4 animate-pulse">
              <p className="text-yellow-100 font-mono text-sm">
                <span className="font-bold">DeferProp:</span> Loading...
              </p>
              <p className="text-yellow-200 text-xs mt-1">
                ⏳ This DeferProp loads in a separate request after the page
                renders!
              </p>
            </div>
          }
        >
          <div className="mb-6 bg-green-500/20 border border-green-400 rounded-lg p-4">
            <p className="text-green-100 font-mono text-sm">
              <span className="font-bold">DeferProp:</span> {demo_info}
            </p>
            <p className="text-green-200 text-xs mt-1">
              ✅ This DeferProp loaded separately after the initial page load!
            </p>
          </div>
        </Deferred>

        {/* Users Table */}
        <div className="bg-white rounded-lg shadow-xl overflow-hidden mb-6">
          <table className="w-full">
            <thead className="bg-purple-700 text-white">
              <tr>
                <th className="px-6 py-3 text-left text-sm font-semibold">
                  ID
                </th>
                <th className="px-6 py-3 text-left text-sm font-semibold">
                  Name
                </th>
                <th className="px-6 py-3 text-left text-sm font-semibold">
                  Email
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {users.map((user) => (
                <tr
                  key={user.id}
                  className="hover:bg-purple-50 transition-colors"
                >
                  <td className="px-6 py-4 text-sm text-gray-900">{user.id}</td>
                  <td className="px-6 py-4 text-sm font-medium text-gray-900">
                    {user.name}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-600">
                    {user.email}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination Controls */}
        <div className="bg-white rounded-lg shadow-lg p-6 mb-8">
          <div className="flex items-center justify-between">
            <button
              onClick={handlePrevious}
              disabled={page === 1}
              className="px-6 py-3 bg-purple-600 text-white font-semibold rounded-lg
                       hover:bg-purple-700 transition-colors disabled:opacity-50
                       disabled:cursor-not-allowed disabled:hover:bg-purple-600"
            >
              ← Previous
            </button>

            <div className="text-gray-700 font-medium">
              Page {page} of {total_pages}
            </div>

            <button
              onClick={handleNext}
              disabled={page === total_pages}
              className="px-6 py-3 bg-purple-600 text-white font-semibold rounded-lg
                       hover:bg-purple-700 transition-colors disabled:opacity-50
                       disabled:cursor-not-allowed disabled:hover:bg-purple-600"
            >
              Next →
            </button>
          </div>
        </div>

        {/* Navigation */}
        <div className="flex justify-center">
          <a
            href="/slides/1"
            className="px-8 py-3 bg-white text-purple-700 font-semibold rounded-lg
                     hover:bg-purple-50 transition-colors shadow-lg"
          >
            ← Back to Presentation
          </a>
        </div>
      </div>
    </div>
  );
}

export default validateProps(UsersTable, UsersTablePagePropsSchema);
