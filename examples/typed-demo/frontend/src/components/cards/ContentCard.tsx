import React from 'react';

interface ContentCardProps {
  children: React.ReactNode;
  variant?: 'default' | 'elevated' | 'bordered';
  padding?: 'none' | 'small' | 'medium' | 'large';
  className?: string;
}

export default function ContentCard({ 
  children, 
  variant = 'default',
  padding = 'medium',
  className = ''
}: ContentCardProps) {
  const variantClasses = {
    'default': 'bg-white shadow-lg rounded-lg',
    'elevated': 'bg-white shadow-xl rounded-lg',
    'bordered': 'bg-white border border-gray-200 rounded-lg'
  };

  const paddingClasses = {
    'none': '',
    'small': 'p-4',
    'medium': 'p-6',
    'large': 'p-8'
  };

  return (
    <div className={`${variantClasses[variant]} ${paddingClasses[padding]} ${className}`}>
      {children}
    </div>
  );
}