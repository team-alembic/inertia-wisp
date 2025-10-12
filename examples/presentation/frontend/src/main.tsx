import React from "react";
import { createRoot } from "react-dom/client";
import { createInertiaApp } from "@inertiajs/react";

const appName = "Gleam + TypeScript Presentation";

async function resolvePageComponent(name: string) {
  try {
    const module = await import(`./Pages/${name}.tsx`);
    return module.default;
  } catch (error) {
    throw new Error(`Page ${name} not found`);
  }
}

createInertiaApp({
  title: (title) => `${title} - ${appName}`,
  resolve: (name) => resolvePageComponent(name),
  setup({ el, App, props }) {
    const root = createRoot(el);
    root.render(<App {...props} />);
  },
  progress: {
    color: "#9333ea",
  },
});
