import { UserActionButton } from './UserActionButton';
import { EyeIcon, EditIcon, TrashIcon } from './icons';

interface User {
  id: number;
  name: string;
  email: string;
}

interface UserTableRowProps {
  user: User;
  onDelete: (userId: number) => void;
}

export function UserTableRow({ user, onDelete }: UserTableRowProps) {
  const handleDelete = () => {
    onDelete(user.id);
  };

  return (
    <tr className="hover:bg-gray-50 transition-colors duration-150">
      <td className="px-6 py-4 whitespace-nowrap">
        <div className="flex items-center">
          <div className="h-8 w-8 rounded-full bg-indigo-100 flex items-center justify-center">
            <span className="text-sm font-medium text-indigo-600">
              {user.id}
            </span>
          </div>
        </div>
      </td>
      <td className="px-6 py-4 whitespace-nowrap">
        <div className="text-sm font-medium text-gray-900">{user.name}</div>
      </td>
      <td className="px-6 py-4 whitespace-nowrap">
        <div className="text-sm text-gray-500">{user.email}</div>
      </td>
      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
        <UserActionButton
          variant="view"
          href={`/users/${user.id}`}
          icon={<EyeIcon />}
        >
          View
        </UserActionButton>
        <UserActionButton
          variant="edit"
          href={`/users/${user.id}/edit`}
          icon={<EditIcon />}
        >
          Edit
        </UserActionButton>
        <UserActionButton
          variant="delete"
          onClick={handleDelete}
          icon={<TrashIcon />}
        >
          Delete
        </UserActionButton>
      </td>
    </tr>
  );
}