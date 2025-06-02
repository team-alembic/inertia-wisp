import React from 'react';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  variant: 'blue' | 'green' | 'yellow' | 'purple';
  formatValue?: boolean;
}

export default function StatCard({ 
  title, 
  value, 
  icon, 
  variant, 
  formatValue = false 
}: StatCardProps) {
  const gradientClasses = {
    'blue': 'bg-gradient-to-br from-blue-400 to-blue-600',
    'green': 'bg-gradient-to-br from-green-400 to-green-600',
    'yellow': 'bg-gradient-to-br from-yellow-400 to-orange-500',
    'purple': 'bg-gradient-to-br from-purple-500 to-pink-500'
  };

  const formattedValue = formatValue && typeof value === 'number' 
    ? value.toLocaleString() 
    : value;

  return (
    <div className={`${gradientClasses[variant]} rounded-lg p-6 text-white`}>
      <div className="flex items-center justify-between">
        <div>
          <p className="text-white/80 text-sm font-medium">{title}</p>
          <p className="stat-number text-3xl font-bold">
            {formattedValue}
          </p>
        </div>
        <div className="bg-white/20 p-3 rounded-full">
          {icon}
        </div>
      </div>
    </div>
  );
}