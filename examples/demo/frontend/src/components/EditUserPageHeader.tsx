import { LinkButton } from './LinkButton';
import { EditIconLarge, ArrowLeftIcon, UsersIcon } from './icons';

interface EditUserPageHeaderProps {
  userName: string;
  userId: number;
  className?: string;
}

export function EditUserPageHeader({
  userName,
  userId,
  className = "",
}: EditUserPageHeaderProps) {
  return (
    <div className={`text-center mb-12 ${className}`}>
      <div className="mx-auto h-16 w-16 rounded-full bg-gradient-to-r from-indigo-500 to-purple-600 flex items-center justify-center mb-6">
        <EditIconLarge />
      </div>
      
      <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
        Edit User
      </h1>
      
      <p className="mt-4 text-lg text-gray-600">
        Update information for {userName}
      </p>
      
      <div className="mt-6 flex flex-col sm:flex-row gap-3 items-center justify-center">
        <LinkButton
          href={`/users/${userId}`}
          variant="indigo"
          size="md"
          icon={<ArrowLeftIcon />}
        >
          Back to User Details
        </LinkButton>
        <LinkButton
          href="/users"
          variant="purple"
          size="md"
          icon={<UsersIcon />}
        >
          Back to Users List
        </LinkButton>
      </div>
    </div>
  );
}