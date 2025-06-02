import React from 'react';

interface PageContainerProps {
  children: React.ReactNode;
  maxWidth?: '4xl' | '6xl';
  padding?: 'standard' | 'large';
  className?: string;
}

export default function PageContainer({ 
  children, 
  maxWidth = '4xl', 
  padding = 'standard',
  className = ''
}: PageContainerProps) {
  const maxWidthClasses = {
    '4xl': 'max-w-4xl',
    '6xl': 'max-w-6xl'
  };

  const paddingClasses = {
    'standard': 'p-6',
    'large': 'p-8'
  };

  return (
    <div className={`${maxWidthClasses[maxWidth]} mx-auto ${paddingClasses[padding]} ${className}`}>
      {children}
    </div>
  );
}