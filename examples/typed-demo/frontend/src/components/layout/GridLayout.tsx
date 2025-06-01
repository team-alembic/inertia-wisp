import React from 'react';

interface GridLayoutProps {
  children: React.ReactNode;
  columns: number | {
    sm?: number;
    md?: number;
    lg?: number;
    xl?: number;
  };
  gap?: 'small' | 'medium' | 'large';
  className?: string;
}

export default function GridLayout({ 
  children, 
  columns, 
  gap = 'medium',
  className = ''
}: GridLayoutProps) {
  const gapClasses = {
    'small': 'gap-4',
    'medium': 'gap-6',
    'large': 'gap-8'
  };

  let gridClasses = '';
  
  if (typeof columns === 'number') {
    const columnClasses = {
      1: 'grid-cols-1',
      2: 'grid-cols-2',
      3: 'grid-cols-3',
      4: 'grid-cols-4'
    };
    gridClasses = columnClasses[columns as keyof typeof columnClasses] || 'grid-cols-1';
  } else {
    const responsiveClasses = [];
    responsiveClasses.push('grid-cols-1'); // Default base
    
    if (columns.sm) {
      const smClass = `sm:grid-cols-${columns.sm}`;
      responsiveClasses.push(smClass);
    }
    if (columns.md) {
      const mdClass = `md:grid-cols-${columns.md}`;
      responsiveClasses.push(mdClass);
    }
    if (columns.lg) {
      const lgClass = `lg:grid-cols-${columns.lg}`;
      responsiveClasses.push(lgClass);
    }
    if (columns.xl) {
      const xlClass = `xl:grid-cols-${columns.xl}`;
      responsiveClasses.push(xlClass);
    }
    
    gridClasses = responsiveClasses.join(' ');
  }

  return (
    <div className={`grid ${gridClasses} ${gapClasses[gap]} ${className}`}>
      {children}
    </div>
  );
}