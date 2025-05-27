import { Card } from './Card';
import { TechStackItem } from './TechStackItem';
import { SectionHeader } from './SectionHeader';
import { LayoutIcon, CodeIcon, DesktopIcon } from './icons';

interface TechnologyStackProps {
  title?: string;
  className?: string;
}

export function TechnologyStack({
  title = "Technology Stack",
  className = "",
}: TechnologyStackProps) {
  return (
    <Card variant="default" padding="md" className={`bg-gradient-to-r from-indigo-50 to-purple-50 mb-6 ${className}`}>
      <SectionHeader level="h3" size="md" className="mb-4">
        {title}
      </SectionHeader>
      <div className="space-y-3">
        <TechStackItem
          title="Backend: Gleam + Wisp"
          description="Type-safe functional programming with excellent performance"
          icon={<LayoutIcon />}
          variant="indigo"
        />
        
        <TechStackItem
          title="Frontend: React + Inertia.js"
          description="Modern SPA experience without API complexity"
          icon={<CodeIcon />}
          variant="cyan"
        />
        
        <TechStackItem
          title="Features: Full-stack TypeScript"
          description="SPA navigation, forms, validation, file uploads"
          icon={<DesktopIcon />}
          variant="purple"
        />
      </div>
    </Card>
  );
}