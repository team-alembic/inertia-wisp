import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";

createInertiaApp({
  resolve: async (name: string) => {
    try {
      // Try loading from pages directory first
      const component = await import(`./pages/${name}.tsx`);
      return component.default || component;
    } catch (error) {
      try {
        // Fallback to domain-specific subdirectories
        const paths = [
          `./pages/auth/${name}.tsx`,
          `./pages/users/${name}.tsx`, 
          `./pages/blog/${name}.tsx`,
          `./pages/contact/${name}.tsx`
        ];
        
        for (const path of paths) {
          try {
            const component = await import(path);
            return component.default || component;
          } catch (e) {
            // Continue to next path
          }
        }
        
        throw new Error(`Component not found in any location`);
      } catch (fallbackError) {
        console.error(`Component '${name}' not found:`, error);
        return () => <div>Component '{name}' not found</div>;
      }
    }
  },
  setup({ el, App, props }) {
    if (!el) {
      throw new Error("Root element not found");
    }
    createRoot(el).render(<App {...props} />);
  },
});