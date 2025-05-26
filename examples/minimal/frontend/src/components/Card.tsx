type CardVariant = 'default' | 'elevated' | 'bordered';
type CardPadding = 'none' | 'sm' | 'md' | 'lg';

interface CardProps {
  children: React.ReactNode;
  variant?: CardVariant;
  padding?: CardPadding;
  className?: string;
}

const variantStyles: Record<CardVariant, string> = {
  default: 'bg-white shadow-md ring-1 ring-gray-900/5 rounded-lg',
  elevated: 'bg-white shadow-xl ring-1 ring-gray-900/5 rounded-2xl',
  bordered: 'bg-white border border-gray-200 rounded-lg',
};

const paddingStyles: Record<CardPadding, string> = {
  none: '',
  sm: 'p-4',
  md: 'p-6',
  lg: 'p-8',
};

export function Card({
  children,
  variant = 'default',
  padding = 'md',
  className = '',
}: CardProps) {
  const variantClasses = variantStyles[variant];
  const paddingClasses = paddingStyles[padding];

  return (
    <div className={`${variantClasses} ${paddingClasses} ${className}`}>
      {children}
    </div>
  );
}