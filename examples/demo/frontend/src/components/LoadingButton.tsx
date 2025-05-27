import { ButtonHTMLAttributes } from 'react';
import { SpinnerIcon } from './icons';

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
          <SpinnerIcon />
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