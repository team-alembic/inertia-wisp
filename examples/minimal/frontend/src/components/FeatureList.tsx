type FeatureListVariant = 'blue' | 'green' | 'gray' | 'purple';

interface FeatureListProps {
  title: string;
  features: string[];
  variant?: FeatureListVariant;
  className?: string;
}

const variantStyles: Record<FeatureListVariant, string> = {
  blue: 'bg-gradient-to-r from-gray-50 to-gray-100 text-gray-900',
  green: 'bg-gradient-to-r from-green-50 to-emerald-50 text-green-900',
  gray: 'bg-gradient-to-r from-gray-50 to-gray-100 text-gray-900',
  purple: 'bg-gradient-to-r from-purple-50 to-indigo-50 text-purple-900',
};

const dotStyles: Record<FeatureListVariant, string> = {
  blue: 'bg-blue-400',
  green: 'bg-green-400',
  gray: 'bg-gray-400',
  purple: 'bg-purple-400',
};

const textStyles: Record<FeatureListVariant, string> = {
  blue: 'text-gray-600',
  green: 'text-green-700',
  gray: 'text-gray-600',
  purple: 'text-purple-700',
};

export function FeatureList({
  title,
  features,
  variant = 'gray',
  className = '',
}: FeatureListProps) {
  const variantClasses = variantStyles[variant];
  const dotClasses = dotStyles[variant];
  const textClasses = textStyles[variant];

  return (
    <div className={`${variantClasses} px-6 py-4 border-t border-gray-200 ${className}`}>
      <h4 className="text-sm font-medium mb-3">{title}</h4>
      <div className="space-y-2 text-xs">
        {features.map((feature, index) => (
          <div key={index} className="flex items-start space-x-2">
            <div className={`h-1.5 w-1.5 ${dotClasses} rounded-full mt-1.5 flex-shrink-0`} />
            <span className={textClasses}>{feature}</span>
          </div>
        ))}
      </div>
    </div>
  );
}