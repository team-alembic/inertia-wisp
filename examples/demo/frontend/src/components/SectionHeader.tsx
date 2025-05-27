type SectionHeaderLevel = 'h2' | 'h3' | 'h4';
type SectionHeaderSize = 'sm' | 'md' | 'lg';

interface SectionHeaderProps {
  children: React.ReactNode;
  level?: SectionHeaderLevel;
  size?: SectionHeaderSize;
  className?: string;
}

const sizeStyles: Record<SectionHeaderSize, string> = {
  sm: 'text-base font-semibold',
  md: 'text-lg font-semibold',
  lg: 'text-2xl font-bold',
};

export function SectionHeader({
  children,
  level = 'h3',
  size = 'md',
  className = '',
}: SectionHeaderProps) {
  const baseClasses = 'text-gray-900 mb-4';
  const sizeClasses = sizeStyles[size];
  const combinedClasses = `${baseClasses} ${sizeClasses} ${className}`;

  const Component = level;

  return (
    <Component className={combinedClasses}>
      {children}
    </Component>
  );
}