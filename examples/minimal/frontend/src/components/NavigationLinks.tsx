import { LinkButton } from './LinkButton';
import { HomeIcon, UsersIcon } from './icons';

interface NavigationLink {
  href: string;
  label: string;
  variant: 'indigo' | 'green' | 'purple' | 'cyan';
  icon: React.ReactNode;
}

interface NavigationLinksProps {
  title?: string;
  links?: NavigationLink[];
  className?: string;
}

const defaultLinks: NavigationLink[] = [
  {
    href: "/",
    label: "Home",
    variant: "indigo",
    icon: <HomeIcon />
  },
  {
    href: "/users",
    label: "Users (Forms Demo)",
    variant: "green", 
    icon: <UsersIcon />
  }
];

export function NavigationLinks({
  title = "Quick Navigation",
  links = defaultLinks,
  className = "",
}: NavigationLinksProps) {
  return (
    <div className={`mb-8 ${className}`}>
      <h3 className="text-lg font-semibold text-gray-900 mb-4">{title}</h3>
      <div className="flex flex-wrap gap-3">
        {links.map((link, index) => (
          <LinkButton
            key={index}
            href={link.href}
            variant={link.variant}
            size="md"
            icon={link.icon}
          >
            {link.label}
          </LinkButton>
        ))}
      </div>
    </div>
  );
}