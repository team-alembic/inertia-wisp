import { ButtonHTMLAttributes } from 'react';

type LoadingButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost';
type LoadingButtonSize = 'sm' | 'md' | 'lg';

interface LoadingButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: LoadingButtonVariant;
  size?: LoadingButtonSize;
  loading?: boolean;
  loadingText?: string;
  icon?: React.ReactNode;
  children: React.ReactNode;
  fullWidth?: boolean;
}

const variantStyles: Record<LoadingButtonVariant, string> = {
  primary: 'text-white bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5',
  secondary: 'text-green-700 bg-green-100 hover:bg-green-200',
  outline: 'text-indigo-700 bg-white border-indigo-300 hover:bg-indigo-50',
  ghost: 'text-gray-700 bg-white border-gray-300 hover:bg-gray-50',
};

const loadingStyles: Record<LoadingButtonVariant, string> = {
  primary: 'bg-gray-300 text-gray-500 cursor-not-allowed',
  secondary: 'bg-gray-300 text-gray-500 cursor-not-allowed',
  outline: 'bg-gray-300 text-gray-500 cursor-not-allowed',
  ghost: 'bg-gray-300 text-gray-500 cursor-not-allowed',
};

const sizeStyles: Record<LoadingButtonSize, string> = {
  sm: 'px-3 py-2 text-xs',
  md: 'px-4 py-2 text-sm',
  lg: 'px-4 py-3 text-sm',
};

function LoadingSpinner() {
  return (
    <svg
      className="animate-spin -ml-1 mr-3 h-5 w-5 text-gray-500"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle
        className="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        strokeWidth="4"
      />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      />
    </svg>
  );
}

export function LoadingButton({
  variant = 'primary',
  size = 'lg',
  loading = false,
  loadingText = 'Loading...',
  icon,
  children,
  fullWidth = false,
  className = '',
  disabled,
  ...props
}: LoadingButtonProps) {
  const baseClasses = 'inline-flex justify-center items-center border border-transparent font-medium rounded-lg transition-all duration-200';
  const variantClasses = loading ? loadingStyles[variant] : variantStyles[variant];
  const sizeClasses = sizeStyles[size];
  const widthClasses = fullWidth ? 'w-full' : '';
  const isDisabled = disabled || loading;

  return (
    <button
      className={`${baseClasses} ${variantClasses} ${sizeClasses} ${widthClasses} ${className}`}
      disabled={isDisabled}
      {...props}
    >
      {loading ? (
        <>
          <LoadingSpinner />
          {loadingText}
        </>
      ) : (
        <>
          {icon && <span className="mr-2">{icon}</span>}
          {children}
        </>
      )}
    </button>
  );
}