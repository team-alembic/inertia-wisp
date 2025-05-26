import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";
import "./styles.css";

createInertiaApp({
  resolve: async (name: string) => {
    const component = await import(`./Pages/${name}.tsx`);

    if (!component) {
      console.error(`Component '${name}' not found`);
      return () => <div>Component '{name}' not found</div>;
    }

    return component.default || component;
  },
  setup({ el, App, props }) {
    if (!el) {
      throw new Error("Root element not found");
    }
    createRoot(el).render(<App {...props} />);
  },
});