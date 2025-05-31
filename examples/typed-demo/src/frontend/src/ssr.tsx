import React from 'react'
import ReactDOMServer from 'react-dom/server'
import { createInertiaApp } from '@inertiajs/react'

export function render(page: any) {
  return createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    resolve: async (name: string) => {
      try {
        const component = await import(`./${name}.tsx`)
        return component.default || component
      } catch (error) {
        console.error(`SSR: Component '${name}' not found:`, error)
        return () => React.createElement('div', {}, `Component '${name}' not found`)
      }
    },
    setup: ({ App, props }) => React.createElement(App, props),
  })
}