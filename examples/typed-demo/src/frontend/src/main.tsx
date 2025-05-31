import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";

createInertiaApp({
  resolve: async (name: string) => {
    try {
      const component = await import(`./${name}.tsx`);
      return component.default || component;
    } catch (error) {
      console.error(`Component '${name}' not found:`, error);
      return () => <div>Component '{name}' not found</div>;
    }
  },
  setup({ el, App, props }) {
    if (!el) {
      throw new Error("Root element not found");
    }
    createRoot(el).render(<App {...props} />);
  },
});