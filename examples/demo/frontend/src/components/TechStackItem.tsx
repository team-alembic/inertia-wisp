import { IconContainer } from './IconContainer';

type TechStackItemVariant = 'indigo' | 'cyan' | 'purple' | 'green';

interface TechStackItemProps {
  title: string;
  description: string;
  icon: React.ReactNode;
  variant?: TechStackItemVariant;
  className?: string;
}

export function TechStackItem({
  title,
  description,
  icon,
  variant = 'indigo',
  className = '',
}: TechStackItemProps) {
  return (
    <div className={`flex items-center space-x-3 ${className}`}>
      <IconContainer variant={variant} size="md">
        {icon}
      </IconContainer>
      <div>
        <p className="font-medium text-gray-900">{title}</p>
        <p className="text-sm text-gray-600">{description}</p>
      </div>
    </div>
  );
}