import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";

createInertiaApp({
  resolve: async (name) => {
    const component = await import(`./pages/${name}.jsx`);
    console.log("Found component:", component);

    if (!component) {
      console.error(`Component '${name}' not found`);
      return () => <div>Component '{name}' not found</div>;
    }

    return component.default || component;
  },
  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />);
  },
});
