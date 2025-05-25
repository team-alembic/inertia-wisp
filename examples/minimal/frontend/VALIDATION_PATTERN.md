# Page Props Validation Pattern

This project implements an ergonomic pattern for validating page props in React components using Zod schemas and higher-order components (HOCs).

## Overview

Instead of manually validating props inside components with `unknown` types, this pattern allows you to:

1. Write components with properly typed props
2. Automatically validate props at the component boundary
3. Handle validation errors gracefully
4. Maintain type safety throughout

## Basic Usage

```typescript
import { withValidatedProps, AboutPageProps, AboutPagePropsSchema } from "../schemas";

// Write your component with properly typed props
function About({ page_title, auth, csrf_token }: AboutPageProps) {
  return (
    <div>
      <h1>{page_title}</h1>
      {auth?.authenticated && <p>Welcome, {auth.user}!</p>}
    </div>
  );
}

// Export with validation HOC
export default withValidatedProps(AboutPagePropsSchema, About);
```

## Simplified API

For common use cases, use the `validateProps` helper:

```typescript
import { validateProps, AboutPageProps, AboutPagePropsSchema } from "../schemas";

function About({ page_title, auth, csrf_token }: AboutPageProps) {
  // Component implementation
}

export default validateProps(AboutPagePropsSchema, About);
```

## Advanced Usage

For custom error handling and logging:

```typescript
import { withValidatedProps } from "../schemas";

function CustomErrorFallback({ error, reset }) {
  return (
    <div style={{ color: 'red' }}>
      <h2>Validation Error</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Retry</button>
    </div>
  );
}

const ValidatedComponent = withValidatedProps(
  MyPagePropsSchema,
  MyComponent,
  {
    ErrorFallback: CustomErrorFallback,
    logErrors: true,
    onError: (error, props) => {
      // Send to error reporting service
      console.error('Page props validation failed:', error);
    }
  }
);
```

## Benefits

### 🎯 Clean Component Signatures
Components accept properly typed props, making them easy to read and understand:

```typescript
// ✅ Clear and readable
function CreateUser({ errors, old, csrf_token, auth }: CreateUserPageProps) {

// ❌ Unclear what props are expected
function CreateUser(props: unknown) {
```

### 🛡️ Runtime Safety
Props are validated automatically at the component boundary using Zod schemas.

### 🔧 Better Developer Experience
- Type errors shown at component definition, not usage
- IntelliSense works properly for prop types
- Refactoring is safer with proper typing

### ♻️ Reusable Pattern
Same HOC works for all page components with their respective schemas.

### 🚨 Error Boundaries
Graceful handling of validation failures with customizable error UI.

### 🔍 Debugging Support
- Automatic error logging in development
- Custom error reporting integration
- Component display names for React DevTools

## File Structure

```
src/
├── schemas/
│   └── index.ts          # Zod schemas and validation HOCs
├── types/
│   └── index.ts          # Re-exports of schema-inferred types
└── Pages/
    ├── Home.tsx          # Example: withValidatedProps usage
    ├── About.tsx         # Example: validateProps usage
    └── Users.tsx         # Example: form validation + props validation
```

## Schema-First Development

All types are derived from Zod schemas, ensuring:

1. **Single source of truth**: Types defined only in schemas
2. **Runtime validation**: Automatic validation with descriptive errors
3. **Type safety**: Compile-time and runtime type checking
4. **Schema consistency**: Frontend validation matches backend expectations

## Migration Guide

To migrate existing components:

1. **Update imports**: Change from `../types` to `../schemas`
2. **Update component signature**: Change `(props: unknown)` to `({ prop1, prop2 }: PageProps)`
3. **Remove manual validation**: Remove `validatePageProps` calls from component body
4. **Wrap export**: Use `withValidatedProps(Schema, Component)` or `validateProps(Schema, Component)`

### Before
```typescript
import { validatePageProps, MyPagePropsSchema } from "../schemas";

export default function MyPage(props: unknown) {
  const { prop1, prop2 } = validatePageProps(MyPagePropsSchema, props);
  // Component logic
}
```

### After
```typescript
import { withValidatedProps, MyPageProps, MyPagePropsSchema } from "../schemas";

function MyPage({ prop1, prop2 }: MyPageProps) {
  // Component logic
}

export default withValidatedProps(MyPagePropsSchema, MyPage);
```

## Error Handling

The HOC provides several error handling strategies:

### Default Error Boundary
Shows a basic error message with retry functionality.

### Custom Error Fallback
Provide your own error UI component.

### Error Reporting
Hook into validation failures for logging/monitoring.

### Development vs Production
- Development: Detailed error logging enabled by default
- Production: Silent failures with optional custom error reporting

## TypeScript Configuration

The pattern uses `any` types strategically to work around React's strict component typing while maintaining type safety at the component level. This is a conscious trade-off for better ergonomics.

## Performance Considerations

- Validation runs on every prop change
- Schemas are cached by Zod for performance
- Error boundaries prevent cascade failures
- Minimal overhead for successful validations

## Testing

Components can be tested independently of the validation HOC:

```typescript
import { render } from '@testing-library/react';
import About from './About'; // Import unwrapped component

// Test the component logic
const props: AboutPageProps = {
  page_title: 'Test',
  csrf_token: 'test-token',
  auth: { authenticated: true, user: 'test@example.com' }
};

render(<About {...props} />);
```

For integration testing, use the wrapped component to test validation behavior.