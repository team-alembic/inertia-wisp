type AlertVariant = "error" | "info" | "success" | "warning";

import { 
  AlertErrorIcon, 
  AlertInfoIcon, 
  AlertSuccessIcon, 
  AlertWarningIcon 
} from "./icons";

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
  switch (variant) {
    case "error":
      return <AlertErrorIcon />;
    case "success":
      return <AlertSuccessIcon />;
    case "warning":
      return <AlertWarningIcon />;
    case "info":
    default:
      return <AlertInfoIcon />;
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