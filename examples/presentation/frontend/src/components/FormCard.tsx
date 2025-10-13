import { ReactNode } from "react";

interface FormCardProps {
  title: string;
  subtitle: string;
  children: ReactNode;
}

export function FormCard({ title, subtitle, children }: FormCardProps) {
  return (
    <div className="bg-white/90 rounded-2xl shadow-2xl p-8">
      <h1 className="text-4xl font-bold text-gray-900 mb-2 text-center">
        {title}
      </h1>
      <p className="text-lg text-gray-600 mb-8 text-center">{subtitle}</p>
      {children}
    </div>
  );
}
