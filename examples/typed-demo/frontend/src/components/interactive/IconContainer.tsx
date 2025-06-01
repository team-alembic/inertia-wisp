import React from 'react';

interface IconContainerProps {
  children: React.ReactNode;
  variant: 'blue' | 'green' | 'purple' | 'orange' | 'red' | 'yellow';
  size?: 'small' | 'medium' | 'large';
  className?: string;
}

export default function IconContainer({ 
  children, 
  variant, 
  size = 'medium',
  className = ''
}: IconContainerProps) {
  const variantClasses = {
    'blue': 'bg-blue-500',
    'green': 'bg-green-500',
    'purple': 'bg-purple-500',
    'orange': 'bg-orange-500',
    'red': 'bg-red-500',
    'yellow': 'bg-yellow-500'
  };

  const sizeClasses = {
    'small': 'w-8 h-8',
    'medium': 'w-12 h-12',
    'large': 'w-16 h-16'
  };

  const iconSizeClasses = {
    'small': 'w-4 h-4',
    'medium': 'w-6 h-6',
    'large': 'w-8 h-8'
  };

  return (
    <div className={`${sizeClasses[size]} ${variantClasses[variant]} rounded-lg flex items-center justify-center text-white ${className}`}>
      <div className={iconSizeClasses[size]}>
        {children}
      </div>
    </div>
  );
}