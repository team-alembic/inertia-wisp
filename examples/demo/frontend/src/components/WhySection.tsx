import { Card } from './Card';

interface WhySectionProps {
  title: string;
  items: string[];
  className?: string;
}

export function WhySection({
  title,
  items,
  className = '',
}: WhySectionProps) {
  return (
    <Card variant="bordered" padding="sm" className={className}>
      <h4 className="font-semibold text-gray-900 mb-2">{title}</h4>
      <ul className="text-sm text-gray-600 space-y-1">
        {items.map((item, index) => (
          <li key={index}>• {item}</li>
        ))}
      </ul>
    </Card>
  );
}