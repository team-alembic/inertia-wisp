import { LinkButton } from './LinkButton';
import { ArrowLeftIcon } from './icons';

interface PageHeaderProps {
  title: string;
  subtitle?: string;
  icon?: React.ReactNode;
  backHref?: string;
  backLabel?: string;
  className?: string;
}

export function PageHeader({
  title,
  subtitle,
  icon,
  backHref = "/",
  backLabel = "Back to Home",
  className = "",
}: PageHeaderProps) {
  return (
    <div className={`text-center mb-12 ${className}`}>
      {icon && (
        <div className="mx-auto h-16 w-16 rounded-full bg-gradient-to-r from-indigo-500 to-purple-600 flex items-center justify-center mb-6">
          {icon}
        </div>
      )}
      
      <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
        {title}
      </h1>
      
      {subtitle && (
        <p className="mt-4 text-lg text-gray-600">
          {subtitle}
        </p>
      )}
      
      <LinkButton
        href={backHref}
        variant="indigo"
        size="md"
        icon={<ArrowLeftIcon />}
        className="mt-6"
      >
        {backLabel}
      </LinkButton>
    </div>
  );
}