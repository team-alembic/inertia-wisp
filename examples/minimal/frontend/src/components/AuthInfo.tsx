interface AuthInfoProps {
  auth: {
    authenticated: boolean;
    user: string;
  } | undefined;
  className?: string;
}

export function AuthInfo({ auth, className = "" }: AuthInfoProps) {
  if (!auth?.authenticated) {
    return null;
  }

  return (
    <div className={`bg-gray-50 px-6 py-4 ${className}`}>
      <div className="flex items-center justify-center">
        <div className="flex items-center space-x-2">
          <div className="h-2 w-2 bg-green-400 rounded-full"></div>
          <p className="text-sm text-gray-600">
            Logged in as: <span className="font-medium text-gray-900">{auth.user}</span>
          </p>
        </div>
      </div>
    </div>
  );
}