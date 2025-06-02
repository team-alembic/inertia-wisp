import React from 'react';
import { Link } from '@inertiajs/react';

interface ActionButtonProps {
  children: React.ReactNode;
  variant: 'blue' | 'green' | 'purple' | 'indigo' | 'teal' | 'orange' | 'pink';
  size?: 'small' | 'medium' | 'large';
  onClick?: () => void;
  href?: string;
  disabled?: boolean;
}

export default function ActionButton({ 
  children, 
  variant, 
  size = 'medium', 
  onClick, 
  href, 
  disabled = false 
}: ActionButtonProps) {
  const variantClasses = {
    'blue': 'bg-blue-600 hover:bg-blue-700 text-white',
    'green': 'bg-green-600 hover:bg-green-700 text-white',
    'purple': 'bg-purple-600 hover:bg-purple-700 text-white',
    'indigo': 'bg-indigo-600 hover:bg-indigo-700 text-white',
    'teal': 'bg-teal-600 hover:bg-teal-700 text-white',
    'orange': 'bg-orange-600 hover:bg-orange-700 text-white',
    'pink': 'bg-pink-600 hover:bg-pink-700 text-white'
  };

  const sizeClasses = {
    'small': 'px-3 py-1 text-sm',
    'medium': 'px-4 py-2',
    'large': 'px-6 py-3 text-lg'
  };

  const baseClasses = 'rounded-lg font-medium transition-colors inline-block text-center';
  const disabledClasses = disabled ? 'opacity-50 cursor-not-allowed' : '';
  
  const className = `${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${disabledClasses}`;

  if (href && !disabled) {
    return (
      <Link href={href} className={className}>
        {children}
      </Link>
    );
  }

  return (
    <button 
      className={className} 
      onClick={onClick} 
      disabled={disabled}
    >
      {children}
    </button>
  );
}