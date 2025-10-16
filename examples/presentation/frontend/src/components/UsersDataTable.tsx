import type { User } from "../generated/schemas";

interface UsersDataTableProps {
  users: User[];
}

export function UsersDataTable({ users }: UsersDataTableProps) {
  return (
    <div className="bg-white rounded-lg shadow-xl overflow-hidden mb-6">
      <table className="w-full">
        <thead className="bg-purple-700 text-white">
          <tr>
            <th className="px-6 py-3 text-left text-sm font-semibold">ID</th>
            <th className="px-6 py-3 text-left text-sm font-semibold">Name</th>
            <th className="px-6 py-3 text-left text-sm font-semibold">Email</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200">
          {users.map((user) => (
            <tr key={user.id} className="hover:bg-purple-50 transition-colors">
              <td className="px-6 py-4 text-sm text-gray-900">{user.id}</td>
              <td className="px-6 py-4 text-sm font-medium text-gray-900">
                {user.name}
              </td>
              <td className="px-6 py-4 text-sm text-gray-600">{user.email}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
