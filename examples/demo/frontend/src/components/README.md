# Parameterized Components

This directory contains reusable React components that replace repeated TailwindCSS class patterns found in the original `Home.tsx` file. Each component uses a `variant` prop system to maintain consistent styling while avoiding the need to merge TailwindCSS classes.

## Components

### Button

A flexible button component for interactive elements.

**Props:**
- `variant`: `'primary' | 'secondary' | 'outline' | 'ghost'` (default: `'primary'`)
- `size`: `'sm' | 'md' | 'lg'` (default: `'md'`)
- `icon`: Optional React node for button icon
- `children`: Button content
- Standard button HTML attributes

**Variants:**
- `primary`: Indigo background with hover states
- `secondary`: Green background with hover states  
- `outline`: White background with indigo border
- `ghost`: White background with gray border

### LinkButton

Navigation link component styled as a button using Inertia.js Link.

**Props:**
- `href`: Navigation destination
- `variant`: `'indigo' | 'green' | 'purple' | 'cyan'` (default: `'indigo'`)
- `size`: `'sm' | 'md' | 'lg'` (default: `'lg'`)
- `icon`: Optional React node for link icon
- `fullWidth`: Boolean for full-width styling
- `children`: Link content

### InfoRow

Component for displaying label-value pairs with consistent styling.

**Props:**
- `label`: Label text
- `value`: Value to display (string or number)
- `variant`: `'indigo' | 'cyan' | 'purple' | 'green' | 'gray'` (default: `'indigo'`)

Each variant uses matching background and text colors for visual consistency.

### SectionHeader

Consistent heading component for section titles.

**Props:**
- `level`: `'h2' | 'h3' | 'h4'` (default: `'h3'`)
- `size`: `'sm' | 'md' | 'lg'` (default: `'md'`)
- `children`: Header content

### Label

Reusable text label component with consistent styling.

**Props:**
- `variant`: `'default' | 'bold' | 'muted'` (default: `'default'`)
- `size`: `'xs' | 'sm' | 'md'` (default: `'sm'`)
- `children`: Label content

## Usage Example

```tsx
import { Button, LinkButton, InfoRow, SectionHeader } from '../components';

// Button with icon
<Button variant="primary" icon={<RefreshIcon />} onClick={handleClick}>
  Refresh Data
</Button>

// Navigation link
<LinkButton href="/users" variant="green" icon={<UsersIcon />}>
  Users
</LinkButton>

// Info display
<InfoRow label="Status" value="Active" variant="green" />

// Section heading
<SectionHeader level="h2" size="lg">
  Dashboard
</SectionHeader>
```

## Benefits

1. **Consistency**: Standardized styling across the application
2. **Maintainability**: Single source of truth for component styles
3. **Type Safety**: TypeScript interfaces prevent invalid prop combinations
4. **Flexibility**: Variant system allows style variations without class merging
5. **Readability**: Component names clearly indicate purpose and styling