import { useEffect } from "react";
import { Link, router } from "@inertiajs/react";
import type { SlideNavigation as SlideNavigationType } from "../schemas";

interface SlideNavigationProps {
  navigation: SlideNavigationType;
}

export function SlideNavigation({ navigation }: SlideNavigationProps) {
  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "ArrowRight" && navigation.has_next) {
        router.visit(navigation.next_url);
      } else if (e.key === "ArrowLeft" && navigation.has_previous) {
        router.visit(navigation.previous_url);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [navigation]);

  return (
    <footer className="p-6 flex items-center justify-between">
      <div className="flex items-center gap-4">
        {navigation.has_previous ? (
          <Link
            href={navigation.previous_url}
            className="px-4 py-2 bg-white bg-opacity-80 rounded-lg hover:bg-opacity-100 transition-all shadow-md"
          >
            ← Previous
          </Link>
        ) : (
          <div className="px-4 py-2 text-gray-400">← Previous</div>
        )}

        {navigation.has_next ? (
          <Link
            href={navigation.next_url}
            className="px-4 py-2 bg-white bg-opacity-80 rounded-lg hover:bg-opacity-100 transition-all shadow-md"
          >
            Next →
          </Link>
        ) : (
          <div className="px-4 py-2 text-gray-400">Next →</div>
        )}
      </div>

      <div className="text-lg font-semibold">
        {navigation.current} / {navigation.total}
      </div>
    </footer>
  );
}
