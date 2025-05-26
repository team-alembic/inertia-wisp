type InfoRowVariant = 'indigo' | 'cyan' | 'purple' | 'green' | 'gray';

interface InfoRowProps {
  label: string;
  value: string | number;
  variant?: InfoRowVariant;
  className?: string;
}

const variantStyles: Record<InfoRowVariant, string> = {
  indigo: 'bg-indigo-50',
  cyan: 'bg-cyan-50',
  purple: 'bg-purple-50',
  green: 'bg-green-50',
  gray: 'bg-gray-50',
};

const valueStyles: Record<InfoRowVariant, string> = {
  indigo: 'text-indigo-900',
  cyan: 'text-cyan-900',
  purple: 'text-purple-900',
  green: 'text-green-900',
  gray: 'text-gray-900',
};

export function InfoRow({
  label,
  value,
  variant = 'indigo',
  className = '',
}: InfoRowProps) {
  const baseClasses = 'flex items-center justify-between p-3 rounded-lg';
  const variantClasses = variantStyles[variant];
  const valueColorClasses = valueStyles[variant];

  return (
    <div className={`${baseClasses} ${variantClasses} ${className}`}>
      <span className="text-sm font-medium text-gray-700">{label}:</span>
      <span className={`text-sm font-bold ${valueColorClasses}`}>{value}</span>
    </div>
  );
}