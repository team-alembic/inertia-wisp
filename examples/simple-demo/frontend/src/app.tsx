import React from "react";
import { createRoot } from "react-dom/client";
import { createInertiaApp } from "@inertiajs/react";
import { resolvePageComponent } from "./utils";
import ErrorBoundary from "./components/error/ErrorBoundary";

const appName = "Simple Demo";

createInertiaApp({
  title: (title) => `${title} - ${appName}`,
  resolve: (name) => resolvePageComponent(name),
  setup({ el, App, props }) {
    const root = createRoot(el);

    root.render(
      <ErrorBoundary feature="app">
        <App {...props} />
      </ErrorBoundary>,
    );
  },
  progress: {
    color: "#4F46E5",
  },
});
