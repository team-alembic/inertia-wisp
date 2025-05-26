import { Link } from '@inertiajs/react';

type LinkButtonVariant = 'indigo' | 'green' | 'purple' | 'cyan';
type LinkButtonSize = 'sm' | 'md' | 'lg';

interface LinkButtonProps {
  href: string;
  variant?: LinkButtonVariant;
  size?: LinkButtonSize;
  children: React.ReactNode;
  icon?: React.ReactNode;
  className?: string;
  fullWidth?: boolean;
}

const variantStyles: Record<LinkButtonVariant, string> = {
  indigo: 'text-indigo-700 bg-indigo-100 hover:bg-indigo-200',
  green: 'text-green-700 bg-green-100 hover:bg-green-200',
  purple: 'text-purple-700 bg-purple-100 hover:bg-purple-200',
  cyan: 'text-cyan-700 bg-cyan-100 hover:bg-cyan-200',
};

const sizeStyles: Record<LinkButtonSize, string> = {
  sm: 'px-3 py-2 text-xs',
  md: 'px-4 py-2 text-sm',
  lg: 'px-4 py-3 text-sm',
};

export function LinkButton({
  href,
  variant = 'indigo',
  size = 'lg',
  children,
  icon,
  className = '',
  fullWidth = false,
}: LinkButtonProps) {
  const baseClasses = 'inline-flex items-center justify-center border border-transparent font-medium rounded-lg transition-colors duration-200';
  const variantClasses = variantStyles[variant];
  const sizeClasses = sizeStyles[size];
  const widthClasses = fullWidth ? 'w-full' : '';

  return (
    <Link
      href={href}
      className={`${baseClasses} ${variantClasses} ${sizeClasses} ${widthClasses} ${className}`}
    >
      {icon && <span className="mr-2">{icon}</span>}
      {children}
    </Link>
  );
}