import { LinkButton } from './LinkButton';
import { ArrowLeftIcon, InfoIcon } from './icons';

interface UserPageNavigationProps {
  className?: string;
}

export function UserPageNavigation({ className = "" }: UserPageNavigationProps) {
  return (
    <div className={`mt-6 flex flex-col sm:flex-row gap-3 items-center justify-center ${className}`}>
      <LinkButton 
        href="/" 
        variant="indigo"
        size="md"
        icon={<ArrowLeftIcon />}
      >
        Back to Home
      </LinkButton>
      <LinkButton 
        href="/about" 
        variant="purple"
        size="md"
        icon={<InfoIcon />}
      >
        About
      </LinkButton>
    </div>
  );
}