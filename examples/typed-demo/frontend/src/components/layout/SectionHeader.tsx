interface SectionHeaderProps {
  title: string;
  subtitle?: string;
  variant?: 'default' | 'large';
}

export default function SectionHeader({ 
  title, 
  subtitle, 
  variant = 'default' 
}: SectionHeaderProps) {
  const titleClasses = {
    'default': 'text-xl font-semibold text-gray-800',
    'large': 'text-3xl font-bold text-gray-900'
  };

  const subtitleClasses = {
    'default': 'text-gray-600 mt-1',
    'large': 'text-gray-600 mt-2'
  };

  const containerClasses = {
    'default': 'mb-4',
    'large': 'mb-8'
  };

  return (
    <div className={containerClasses[variant]}>
      <h2 className={titleClasses[variant]}>
        {title}
      </h2>
      {subtitle && (
        <p className={subtitleClasses[variant]}>
          {subtitle}
        </p>
      )}
    </div>
  );
}