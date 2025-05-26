type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  children: React.ReactNode;
  icon?: React.ReactNode;
}

const variantStyles: Record<ButtonVariant, string> = {
  primary: 'text-indigo-700 bg-indigo-100 hover:bg-indigo-200',
  secondary: 'text-green-700 bg-green-100 hover:bg-green-200',
  outline: 'text-indigo-700 bg-white border-indigo-300 hover:bg-indigo-50',
  ghost: 'text-gray-700 bg-white border-gray-300 hover:bg-gray-50',
};

const sizeStyles: Record<ButtonSize, string> = {
  sm: 'px-3 py-2 text-xs',
  md: 'px-4 py-2 text-sm',
  lg: 'px-4 py-3 text-sm',
};

const roundedStyles: Record<ButtonSize, string> = {
  sm: 'rounded',
  md: 'rounded-md',
  lg: 'rounded-lg',
};

export function Button({
  variant = 'primary',
  size = 'md',
  children,
  icon,
  className = '',
  ...props
}: ButtonProps) {
  const baseClasses = 'inline-flex items-center justify-center border border-transparent font-medium transition-colors duration-200';
  const variantClasses = variantStyles[variant];
  const sizeClasses = sizeStyles[size];
  const roundedClasses = roundedStyles[size];

  return (
    <button
      className={`${baseClasses} ${variantClasses} ${sizeClasses} ${roundedClasses} ${className}`}
      {...props}
    >
      {icon && <span className="mr-2">{icon}</span>}
      {children}
    </button>
  );
}