type LabelVariant = 'default' | 'bold' | 'muted';
type LabelSize = 'xs' | 'sm' | 'md';

interface LabelProps {
  children: React.ReactNode;
  variant?: LabelVariant;
  size?: LabelSize;
  className?: string;
}

const variantStyles: Record<LabelVariant, string> = {
  default: 'font-medium text-gray-700',
  bold: 'font-bold text-gray-900',
  muted: 'font-normal text-gray-500',
};

const sizeStyles: Record<LabelSize, string> = {
  xs: 'text-xs',
  sm: 'text-sm',
  md: 'text-base',
};

export function Label({
  children,
  variant = 'default',
  size = 'sm',
  className = '',
}: LabelProps) {
  const variantClasses = variantStyles[variant];
  const sizeClasses = sizeStyles[size];

  return (
    <span className={`${variantClasses} ${sizeClasses} ${className}`}>
      {children}
    </span>
  );
}