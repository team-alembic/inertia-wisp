import React from 'react';
import { UsersIconLarge } from './icons';

interface EmptyUsersStateProps {
  title: string;
  description: string;
}

export function EmptyUsersState({ title, description }: EmptyUsersStateProps) {
  return (
    <div className="flex flex-col items-center justify-center h-full">
      <div className="flex-shrink-0">
        <UsersIconLarge />
      </div>
      <h3 className="mt-4 text-lg font-medium text-gray-900">{title}</h3>
      <p className="mt-2 text-sm text-gray-500">{description}</p>
    </div>
  );
}