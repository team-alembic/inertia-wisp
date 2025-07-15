# Product Overview

Inertia Wisp is a modern server-side adapter for Inertia.js built specifically for Gleam and the Wisp web framework. It enables developers to build single-page applications using classic server-side routing and controllers without maintaining a separate API.

## Key Features

- **Type-Safe Props**: Compile-time prop validation using Gleam's type system
- **Multiple Prop Types**: Support for DefaultProp, LazyProp, OptionalProp, AlwaysProp, DeferProp, and MergeProp
- **Partial Reloads**: Performance optimization for large datasets
- **Deferred Props**: Background data loading with grouping support
- **Server-Side Rendering**: SSR support with graceful CSR fallback
- **Form Validation**: Built-in error handling for form submissions
- **Asset Versioning**: Cache-busting and version mismatch handling

## Target Users

Gleam developers who want to build modern web applications with the simplicity of server-side rendering combined with the user experience benefits of single-page applications.

## Architecture Philosophy

The library follows Gleam's principles of type safety and functional programming, providing a clean API that leverages the type system to prevent runtime errors and ensure correct prop handling across different request types.