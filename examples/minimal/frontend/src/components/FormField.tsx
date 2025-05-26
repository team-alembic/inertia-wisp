import { ChangeEvent } from "react";

type FormFieldVariant = "default" | "error" | "success";

interface FormFieldProps {
  id: string;
  name: string;
  type?: "text" | "email" | "password";
  label: string;
  value: string;
  onChange: (e: ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string;
  disabled?: boolean;
  error?: string | undefined;
  variant?: FormFieldVariant;
  icon?: React.ReactNode;
  validationIcon?: React.ReactNode;
  className?: string;
}

const variantStyles: Record<FormFieldVariant, string> = {
  default:
    "border-gray-300 text-gray-900 focus:ring-blue-500 focus:border-transparent",
  error: "border-red-300 text-red-900 focus:ring-red-500",
  success: "border-green-300 text-green-900 focus:ring-green-500",
};

export function FormField({
  id,
  name,
  type = "text",
  label,
  value,
  onChange,
  placeholder,
  disabled = false,
  error,
  variant = "default",
  icon,
  validationIcon,
  className = "",
}: FormFieldProps) {
  const variantClasses = variantStyles[error ? "error" : variant];

  return (
    <div className={className}>
      <label
        htmlFor={id}
        className="block text-sm font-medium text-gray-700 mb-2"
      >
        {label}
      </label>
      <div className="relative">
        {icon && (
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            {icon}
          </div>
        )}
        <input
          type={type}
          id={id}
          name={name}
          value={value}
          onChange={onChange}
          disabled={disabled}
          className={`
            block w-full ${icon ? "pl-10" : "pl-3"} pr-3 py-3 border rounded-lg shadow-sm
            placeholder-gray-400 focus:outline-none focus:ring-2
            disabled:bg-gray-50 disabled:text-gray-500 disabled:cursor-not-allowed
            ${variantClasses}
          `}
          placeholder={placeholder}
        />
        {validationIcon && !error && (
          <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
            {validationIcon}
          </div>
        )}
      </div>
    </div>
  );
}
