import { Link } from '@inertiajs/react';

type UserActionVariant = 'view' | 'edit' | 'delete';

interface UserActionButtonProps {
  variant: UserActionVariant;
  href?: string;
  onClick?: () => void;
  icon: React.ReactNode;
  children: React.ReactNode;
}

const variantStyles: Record<UserActionVariant, string> = {
  view: 'text-blue-700 bg-blue-100 hover:bg-blue-200',
  edit: 'text-green-700 bg-green-100 hover:bg-green-200',
  delete: 'text-red-700 bg-red-100 hover:bg-red-200',
};

export function UserActionButton({
  variant,
  href,
  onClick,
  icon,
  children,
}: UserActionButtonProps) {
  const baseClasses = 'inline-flex items-center px-3 py-1 border border-transparent text-xs font-medium rounded-full transition-colors duration-200';
  const variantClasses = variantStyles[variant];
  const classes = `${baseClasses} ${variantClasses}`;

  if (href) {
    return (
      <Link href={href} className={classes}>
        {icon}
        {children}
      </Link>
    );
  }

  return (
    <button onClick={onClick} className={classes}>
      {icon}
      {children}
    </button>
  );
}