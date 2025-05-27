import { Button } from './Button';
import { RefreshIcon } from './icons';
import { router } from '@inertiajs/react';

interface TestNavigationProps {
  title?: string;
  className?: string;
}

export function TestNavigation({
  title = "Test Navigation",
  className = "",
}: TestNavigationProps) {
  return (
    <div className={className}>
      <h4 className="text-lg font-semibold text-gray-900 mb-4">{title}</h4>
      <div className="flex flex-col sm:flex-row gap-3">
        <Button
          variant="outline"
          size="md"
          icon={<RefreshIcon />}
          onClick={() => router.visit("/about")}
        >
          Reload About (XHR)
        </Button>
        <Button 
          variant="ghost"
          size="md"
          icon={<RefreshIcon />}
          onClick={() => (window.location.href = "/about")}
        >
          Reload About (Full)
        </Button>
      </div>
    </div>
  );
}