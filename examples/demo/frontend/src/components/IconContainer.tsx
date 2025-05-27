type IconContainerVariant = 'indigo' | 'cyan' | 'purple' | 'green' | 'gray';
type IconContainerSize = 'sm' | 'md' | 'lg';

interface IconContainerProps {
  children: React.ReactNode;
  variant?: IconContainerVariant;
  size?: IconContainerSize;
  className?: string;
}

const variantStyles: Record<IconContainerVariant, string> = {
  indigo: 'bg-indigo-100 text-indigo-600',
  cyan: 'bg-cyan-100 text-cyan-600',
  purple: 'bg-purple-100 text-purple-600',
  green: 'bg-green-100 text-green-600',
  gray: 'bg-gray-100 text-gray-600',
};

const sizeStyles: Record<IconContainerSize, string> = {
  sm: 'h-6 w-6',
  md: 'h-8 w-8',
  lg: 'h-16 w-16',
};

export function IconContainer({
  children,
  variant = 'indigo',
  size = 'md',
  className = '',
}: IconContainerProps) {
  const variantClasses = variantStyles[variant];
  const sizeClasses = sizeStyles[size];

  return (
    <div className={`rounded-full flex items-center justify-center ${variantClasses} ${sizeClasses} ${className}`}>
      {children}
    </div>
  );
}