import React from 'react';
import { ExclamationTriangleIcon, CheckCircleIcon } from './icons';

interface ValidationErrorsProps {
  errors: Record<string, string>;
}

export function ValidationErrors({ errors }: ValidationErrorsProps) {
  return (
    <div className="space-y-4">
      {Object.keys(errors).map((field) => (
        <div key={field} className="flex items-start">
          <div className="flex-shrink-0">
            <ExclamationTriangleIcon />
          </div>
          <div className="ml-3">
            <p className="text-sm text-red-700">{errors[field]}</p>
          </div>
        </div>
      ))}
    </div>
  );
}

export function ValidationSuccess({ message }: { message: string }) {
  return (
    <div className="flex items-start">
      <div className="flex-shrink-0">
        <CheckCircleIcon />
      </div>
      <div className="ml-3">
        <p className="text-sm text-blue-700">{message}</p>
      </div>
    </div>
  );
}