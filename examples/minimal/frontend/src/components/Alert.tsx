type AlertVariant = "error" | "info" | "success" | "warning";

interface AlertProps {
  variant?: AlertVariant;
  title?: string;
  children: React.ReactNode;
  className?: string;
}

const variantStyles: Record<AlertVariant, string> = {
  error: "bg-red-50 border-l-4 border-red-400",
  info: "bg-gradient-to-r from-blue-50 to-cyan-50 border-l-4 border-blue-400",
  success: "bg-green-50 border-l-4 border-green-400",
  warning: "bg-yellow-50 border-l-4 border-yellow-400",
};

const iconStyles: Record<AlertVariant, string> = {
  error: "h-5 w-5 text-red-400",
  info: "h-5 w-5 text-blue-400",
  success: "h-5 w-5 text-green-400",
  warning: "h-5 w-5 text-yellow-400",
};

const titleStyles: Record<AlertVariant, string> = {
  error: "text-sm font-medium text-red-800",
  info: "text-sm font-medium text-blue-800",
  success: "text-sm font-medium text-green-800",
  warning: "text-sm font-medium text-yellow-800",
};

const contentStyles: Record<AlertVariant, string> = {
  error: "text-sm text-red-700",
  info: "text-sm text-blue-700",
  success: "text-sm text-green-700",
  warning: "text-sm text-yellow-700",
};

function getAlertIcon(variant: AlertVariant) {
  const iconClass = iconStyles[variant];

  switch (variant) {
    case "error":
      return (
        <svg className={iconClass} viewBox="0 0 20 20" fill="currentColor">
          <path
            fillRule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
            clipRule="evenodd"
          />
        </svg>
      );
    case "success":
      return (
        <svg className={iconClass} viewBox="0 0 20 20" fill="currentColor">
          <path
            fillRule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
            clipRule="evenodd"
          />
        </svg>
      );
    case "warning":
      return (
        <svg className={iconClass} viewBox="0 0 20 20" fill="currentColor">
          <path
            fillRule="evenodd"
            d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
            clipRule="evenodd"
          />
        </svg>
      );
    case "info":
    default:
      return (
        <svg className={iconClass} viewBox="0 0 20 20" fill="currentColor">
          <path
            fillRule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
            clipRule="evenodd"
          />
        </svg>
      );
  }
}

export function Alert({
  variant = "info",
  title,
  children,
  className = "",
}: AlertProps) {
  const variantClasses = variantStyles[variant];
  const titleClasses = titleStyles[variant];
  const contentClasses = contentStyles[variant];

  return (
    <div className={`${variantClasses} p-4 rounded-md ${className}`}>
      <div className="flex">
        <div className="flex-shrink-0">{getAlertIcon(variant)}</div>
        <div className="ml-3">
          {title && <h3 className={titleClasses}>{title}</h3>}
          <div className={`${title ? "mt-2" : ""} ${contentClasses}`}>
            {children}
          </div>
        </div>
      </div>
    </div>
  );
}
