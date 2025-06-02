import React from 'react'
import ReactDOMServer from 'react-dom/server'
import { createInertiaApp } from '@inertiajs/react'

export function render(page: any) {
  return createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    resolve: async (name: string) => {
      try {
        // Try loading from pages directory first
        const component = await import(`./pages/${name}.tsx`)
        return component.default || component
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
          console.error(`SSR: Component '${name}' not found:`, error)
          return () => React.createElement('div', {}, `Component '${name}' not found`)
        }
      }
    },
    setup: ({ App, props }) => React.createElement(App, props),
  })
}