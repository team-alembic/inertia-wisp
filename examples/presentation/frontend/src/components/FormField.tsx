interface FormFieldProps {
  id: string;
  label: string;
  type?: "text" | "email" | "textarea";
  value: string;
  onChange: (value: string) => void;
  error?: string;
  disabled?: boolean;
  placeholder?: string;
  rows?: number;
  showCharCount?: boolean;
  minChars?: number;
}

export function FormField({
  id,
  label,
  type = "text",
  value,
  onChange,
  error,
  disabled = false,
  placeholder,
  rows = 5,
  showCharCount = false,
  minChars,
}: FormFieldProps) {
  const baseClassName = `w-full px-4 py-3 rounded-lg border-2 transition-colors ${
    error
      ? "border-red-500 focus:border-red-600"
      : "border-gray-300 focus:border-purple-500"
  } focus:outline-none focus:ring-2 focus:ring-purple-200`;

  return (
    <div>
      <label
        htmlFor={id}
        className="block text-sm font-semibold text-gray-700 mb-2"
      >
        {label}
      </label>

      {type === "textarea" ? (
        <textarea
          id={id}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          rows={rows}
          className={`${baseClassName} resize-none`}
          placeholder={placeholder}
          disabled={disabled}
        />
      ) : (
        <input
          id={id}
          type={type}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className={baseClassName}
          placeholder={placeholder}
          disabled={disabled}
        />
      )}

      {error && (
        <p className="mt-2 text-sm text-red-600 font-medium">{error}</p>
      )}

      {showCharCount && (
        <p className="mt-2 text-sm text-gray-600">
          {value.length} character{value.length !== 1 ? "s" : ""}
          {minChars && value.length < minChars && (
            <span className="text-orange-600">
              {" "}
              (minimum {minChars} required)
            </span>
          )}
        </p>
      )}
    </div>
  );
}
