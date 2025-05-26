type GradientVariant = 'indigo' | 'purple' | 'cyan' | 'green';

interface GradientBackgroundProps {
  children: React.ReactNode;
  variant?: GradientVariant;
  className?: string;
}

const variantStyles: Record<GradientVariant, string> = {
  indigo: 'bg-gradient-to-br from-indigo-50 via-white to-cyan-50',
  purple: 'bg-gradient-to-br from-purple-50 via-white to-indigo-50',
  cyan: 'bg-gradient-to-br from-cyan-50 via-white to-blue-50',
  green: 'bg-gradient-to-br from-green-50 via-white to-emerald-50',
};

export function GradientBackground({
  children,
  variant = 'indigo',
  className = '',
}: GradientBackgroundProps) {
  const variantClasses = variantStyles[variant];

  return (
    <div className={`min-h-screen ${variantClasses} ${className}`}>
      {children}
    </div>
  );
}