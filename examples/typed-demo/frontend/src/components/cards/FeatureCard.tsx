import React from 'react';

interface FeatureCardProps {
  title: string;
  description: string;
  icon: React.ReactNode;
  iconColor?: 'blue' | 'green' | 'purple' | 'orange';
  variant?: 'default' | 'compact';
}

export default function FeatureCard({ 
  title, 
  description, 
  icon, 
  iconColor = 'blue',
  variant = 'default'
}: FeatureCardProps) {
  const iconColorClasses = {
    'blue': 'bg-blue-500',
    'green': 'bg-green-500',
    'purple': 'bg-purple-500',
    'orange': 'bg-orange-500'
  };

  const cardClasses = {
    'default': 'bg-white rounded-xl shadow-lg p-8 hover:shadow-xl transition-shadow',
    'compact': 'bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow'
  };

  const iconSizeClasses = {
    'default': 'w-12 h-12',
    'compact': 'w-10 h-10'
  };

  const titleClasses = {
    'default': 'text-xl font-semibold text-gray-900 ml-4',
    'compact': 'text-lg font-semibold text-gray-900 ml-3'
  };

  const descriptionClasses = {
    'default': 'text-gray-600',
    'compact': 'text-gray-600 text-sm'
  };

  return (
    <div className={cardClasses[variant]}>
      <div className="flex items-center mb-4">
        <div className={`${iconSizeClasses[variant]} ${iconColorClasses[iconColor]} rounded-lg flex items-center justify-center`}>
          {icon}
        </div>
        <h3 className={titleClasses[variant]}>
          {title}
        </h3>
      </div>
      <p className={descriptionClasses[variant]}>
        {description}
      </p>
    </div>
  );
}