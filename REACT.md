# React + Inertia.js Conventions and Best Practices

This document establishes conventions for React development within Inertia.js applications, emphasizing simplicity, maintainability, and component-driven architecture.

## Core Philosophy

### Simplicity First
- Prefer explicit over implicit
- Choose composition over inheritance
- Favor pure functions and declarative code
- Keep components small and focused (ideally under 100 lines)

### Inertia.js + React Principles
- Components should primarily render props received from the backend
- State management happens on the server; React handles presentation
- Minimal client-side state (mostly UI state like form inputs, modals)
- No complex state management libraries needed (Redux, Zustand, etc.)

## Component Architecture

### Component Organization

#### 1. Component Co-location
```
✅ GOOD: Co-locate related components
src/components/UserProfile/
├── UserProfile.tsx          // Main component
├── UserAvatar.tsx          // Child component
├── UserStats.tsx           // Child component
└── index.ts               // Barrel export

✅ BETTER: Co-locate loading states with their components
// Inside UserProfile.tsx
const UserProfileLoadingState = () => (/* skeleton */);
const UserProfile = ({ user }) => (/* content */);
```

#### 2. Component Size Guidelines
- **Main components**: 50-150 lines max
- **Leaf components**: 20-80 lines max  
- **Utility components**: 10-50 lines max
- If a component exceeds these limits, extract logical sub-components

#### 3. Component Extraction Patterns
Extract components when you have:
- **Repeated UI patterns** (cards, buttons, headers)
- **Complex conditional rendering** (if-else blocks > 10 lines)
- **Self-contained functionality** (forms, modals, charts)
- **Loading states** (co-locate with their main component)

### Component Types

#### 1. Page Components
```tsx
// src/Pages/Users/Index.tsx
interface UsersIndexProps {
  users: User[];
  pagination: Pagination;
  search_query: string;
}

export default function Index({ users, pagination, search_query }: UsersIndexProps) {
  return (
    <>
      <Head title="Users" />
      <UserHeader searchQuery={search_query} />
      <UsersList users={users} />
      <Pagination {...pagination} />
    </>
  );
}
```

#### 2. Layout Components
```tsx
// src/components/UsersList.tsx
interface UsersListProps {
  users: User[];
}

export const UsersList: React.FC<UsersListProps> = ({ users }) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {users.map(user => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
};
```

#### 3. Presentation Components
```tsx
// src/components/UserCard.tsx
interface UserCardProps {
  user: User;
  onClick?: (user: User) => void;
}

export const UserCard: React.FC<UserCardProps> = ({ user, onClick }) => {
  return (
    <div 
      className="bg-white rounded-lg shadow-sm border p-6 hover:shadow-md transition-shadow"
      onClick={() => onClick?.(user)}
    >
      <UserAvatar src={user.avatar} name={user.name} />
      <h3 className="font-semibold text-gray-900">{user.name}</h3>
      <p className="text-gray-600">{user.email}</p>
    </div>
  );
};
```

#### 4. Icon Components
```tsx
// src/components/Icons.tsx
export const Icons = {
  User: () => (
    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
    </svg>
  ),
  // More icons...
};
```

## State Management

### 1. Props-First Approach
```tsx
✅ GOOD: Render props from backend
const Dashboard = ({ user_count, analytics, activity_feed }) => {
  return (
    <div>
      <MetricCard title="Users" value={user_count} />
      <AnalyticsPanel analytics={analytics} />
      <ActivityPanel activity_feed={activity_feed} />
    </div>
  );
};

❌ AVOID: Client-side data fetching
const Dashboard = () => {
  const [users, setUsers] = useState([]);
  
  useEffect(() => {
    fetch('/api/users').then(/* ... */); // Don't do this!
  }, []);
};
```

### 2. Minimal Local State
```tsx
✅ GOOD: UI state only
const SearchForm = ({ onSearch }) => {
  const [query, setQuery] = useState('');
  const [isExpanded, setIsExpanded] = useState(false);
  
  return (
    <form onSubmit={() => onSearch(query)}>
      {/* form content */}
    </form>
  );
};
```

### 3. useEffect Usage Rules

**🚨 CRITICAL: useEffect is rarely needed in Inertia apps**

When useEffect IS required, add a comment explaining why:

```tsx
✅ ACCEPTABLE: DOM synchronization
useEffect(() => {
  // Synchronize with external chart library that requires DOM manipulation
  const chart = new Chart(chartRef.current, chartConfig);
  return () => chart.destroy();
}, [data]);

✅ ACCEPTABLE: Browser API integration  
useEffect(() => {
  // Listen for keyboard shortcuts for accessibility
  const handleKeyPress = (e) => {
    if (e.key === 'Escape') closeModal();
  };
  document.addEventListener('keydown', handleKeyPress);
  return () => document.removeEventListener('keydown', handleKeyPress);
}, []);

❌ FORBIDDEN: Data fetching
useEffect(() => {
  fetch('/api/data'); // Use Inertia props instead!
}, []);

❌ FORBIDDEN: State synchronization that should be props
useEffect(() => {
  setLocalUser(user); // Just use the prop directly!
}, [user]);
```

## Inertia.js Patterns

### 1. Deferred Props with Loading States
```tsx
// Co-locate loading state with component
const AnalyticsLoadingState = () => (
  <div className="animate-pulse">
    {/* skeleton content */}
  </div>
);

const AnalyticsPanel = ({ analytics }) => (
  <Deferred data="analytics" fallback={<AnalyticsLoadingState />}>
    <div>
      {/* analytics content */}
    </div>
  </Deferred>
);
```

### 2. Form Handling
```tsx
import { useForm } from '@inertiajs/react';

const UserForm = ({ user, errors }) => {
  const { data, setData, post, processing } = useForm({
    name: user?.name || '',
    email: user?.email || '',
  });

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      post('/users');
    }}>
      <input
        value={data.name}
        onChange={e => setData('name', e.target.value)}
        className={errors.name ? 'border-red-500' : 'border-gray-300'}
      />
      {errors.name && <span className="text-red-500">{errors.name}</span>}
      
      <button disabled={processing}>
        {processing ? 'Saving...' : 'Save'}
      </button>
    </form>
  );
};
```

### 3. Navigation
```tsx
import { Link, router } from '@inertiajs/react';

// Prefer Link for navigation
<Link href="/users" className="text-blue-600 hover:text-blue-800">
  View Users
</Link>

// Use router for programmatic navigation
const handleDelete = (userId) => {
  if (confirm('Are you sure?')) {
    router.delete(`/users/${userId}`);
  }
};
```

## Tailwind CSS Conventions

### 1. Responsive Design
```tsx
✅ GOOD: Mobile-first responsive classes
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">

✅ GOOD: Consistent spacing scale
<div className="p-4 m-2">        // Small
<div className="p-6 m-4">        // Medium  
<div className="p-8 m-6">        // Large
```

### 2. Color Patterns
```tsx
✅ GOOD: Semantic color usage
<div className="bg-white border border-gray-200">         // Neutral containers
<button className="bg-blue-600 hover:bg-blue-700">       // Primary actions
<span className="text-red-600 bg-red-50">               // Error states
<span className="text-emerald-600 bg-emerald-50">       // Success states
```

### 3. Component Styling Patterns
```tsx
// Card pattern
const cardClasses = "bg-white rounded-lg shadow-sm border border-gray-200 p-6";

// Button patterns
const buttonBase = "px-4 py-2 rounded-md font-medium transition-colors";
const buttonPrimary = `${buttonBase} bg-blue-600 text-white hover:bg-blue-700`;
const buttonSecondary = `${buttonBase} bg-gray-100 text-gray-900 hover:bg-gray-200`;
```

### 4. Layout Patterns
```tsx
// Page layout
<div className="min-h-screen bg-gray-50">
  <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    {/* content */}
  </div>
</div>

// Card grid
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

// Flexbox patterns
<div className="flex items-center justify-between">
<div className="flex items-center space-x-3">
```

### 5. Layout Utility Components

**Problem**: Nested divs with layout classes are hard to read and maintain:
```tsx
❌ HARD TO READ: Nested layout divs
<div className="bg-white border-b border-gray-200">
  <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div className="py-6">
      <div className="flex items-center justify-between">
        {/* What does each div do? */}
      </div>
    </div>
  </div>
</div>
```

**Solution**: Create semantic layout utility components:
```tsx
// src/components/ui/Layout.tsx
export const Page = ({ children }) => (
  <div className="min-h-screen bg-gray-50">{children}</div>
);

export const PageHeader = ({ children, className = "" }) => (
  <div className={`bg-white border-b border-gray-200 ${className}`}>
    <Container>
      <div className="py-6">{children}</div>
    </Container>
  </div>
);

export const PageContent = ({ children }) => (
  <Container>
    <div className="py-8">{children}</div>
  </Container>
);

export const Container = ({ children, className = "" }) => (
  <div className={`max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 ${className}`}>
    {children}
  </div>
);

export const FlexBetween = ({ children, className = "" }) => (
  <div className={`flex items-center justify-between ${className}`}>
    {children}
  </div>
);

export const Grid = ({ cols = "1 md:2 lg:3", gap = "6", children, className = "" }) => (
  <div className={`grid grid-cols-${cols} gap-${gap} ${className}`}>
    {children}
  </div>
);

// Usage - Much clearer
✅ CLEAR: Semantic layout components
<Page>
  <PageHeader>
    <FlexBetween>
      <div>
        <h1>Executive Dashboard</h1>
        <p>Real-time analytics</p>
      </div>
      <div>
        {/* header actions */}
      </div>
    </FlexBetween>
  </PageHeader>
  
  <PageContent>
    <Grid cols="1 md:4">
      <MetricCard />
    </Grid>
  </PageContent>
</Page>
```

## TypeScript Conventions

### 1. Props Interfaces
```tsx
// Always define props interfaces
interface UserCardProps {
  user: User;
  onClick?: (user: User) => void;
  className?: string;
  showAvatar?: boolean;
}

// Use React.FC when you need children
interface LayoutProps {
  children: React.ReactNode;
  title: string;
}
const Layout: React.FC<LayoutProps> = ({ children, title }) => {
  // component
};
```

### 2. Event Handlers
```tsx
// Type event handlers properly
const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
  e.preventDefault();
  // handle submit
};

const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
  setData(e.target.value);
};

const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
  // handle click
};
```

### 3. Backend Type Synchronization
```tsx
// Keep frontend types in sync with backend
interface User {
  id: number;
  name: string;
  email: string;
  created_at: string;
}

interface DashboardProps {
  user_count: number;
  analytics?: UserAnalytics;  // Optional for deferred props
  activity_feed?: ActivityFeed;
}
```

## Testing Patterns

### 1. Component Testing
```tsx
// Focus on behavior, not implementation
test('UserCard displays user information', () => {
  const user = { id: 1, name: 'John Doe', email: 'john@example.com' };
  render(<UserCard user={user} />);
  
  expect(screen.getByText('John Doe')).toBeInTheDocument();
  expect(screen.getByText('john@example.com')).toBeInTheDocument();
});

test('UserCard calls onClick when clicked', () => {
  const handleClick = jest.fn();
  const user = { id: 1, name: 'John Doe', email: 'john@example.com' };
  
  render(<UserCard user={user} onClick={handleClick} />);
  fireEvent.click(screen.getByRole('button'));
  
  expect(handleClick).toHaveBeenCalledWith(user);
});
```

## Performance Guidelines

### 1. Loading Strategy: React.lazy vs Inertia Deferred

**React.lazy**: Client-side code splitting (loads JavaScript bundles)
```tsx
// Use for heavy JS components (reduces initial bundle size)
const HeavyChart = React.lazy(() => import('./HeavyChart'));
```

**Inertia Deferred**: Server-side data loading (loads data from backend)
```tsx
// Use for expensive server operations (reduces server response time)
<Deferred data="analytics" fallback={<LoadingState />}>
```

**When to use each**:
- React.lazy: Large/infrequent components, admin panels, modals
- Inertia Deferred: Expensive DB queries, external APIs, heavy computations

### 2. Component Optimization
```tsx
// Use React.memo for expensive pure components
export const ExpensiveUserList = React.memo(({ users }) => {
  return (
    <div>
      {users.map(user => (
        <ExpensiveUserCard key={user.id} user={user} />
      ))}
    </div>
  );
});

// Use useCallback for event handlers passed to children
const UsersList = ({ users, onUserClick }) => {
  const handleUserClick = useCallback((user) => {
    // Comment: Memoized to prevent child re-renders when parent re-renders
    onUserClick(user);
  }, [onUserClick]);

  return (
    <div>
      {users.map(user => (
        <UserCard key={user.id} user={user} onClick={handleUserClick} />
      ))}
    </div>
  );
};
```

### 3. Advanced Loading Patterns
```tsx
// Combined: Deferred data + lazy components
const Dashboard = ({ analytics }) => (
  <Deferred data="analytics" fallback={<AnalyticsLoading />}>
    <Suspense fallback={<ChartComponentLoading />}>
      <HeavyChart analytics={analytics} />
    </Suspense>
  </Deferred>
);
```

## Anti-Patterns to Avoid

### 1. Common React Anti-patterns
```tsx
❌ DON'T: Mutate props
const Component = ({ items }) => {
  items.push(newItem); // Never mutate props!
};

❌ DON'T: Use array indices as keys in dynamic lists
{items.map((item, index) => (
  <Item key={index} item={item} /> // Use stable IDs instead
))}

❌ DON'T: Create components inside render
const Component = () => {
  const NestedComponent = () => <div />; // Creates new component every render
  return <NestedComponent />;
};
```

### 2. Inertia-specific Anti-patterns
```tsx
❌ DON'T: Use useEffect for data that should come from props
useEffect(() => {
  fetchUsers().then(setUsers); // Use Inertia props instead!
}, []);

❌ DON'T: Duplicate server state in React state
const [user, setUser] = useState(props.user); // Just use props.user directly!

❌ DON'T: Complex client-side routing
// Inertia handles routing - don't fight it with React Router
```

## File Organization

```
src/
├── components/           # Reusable UI components
│   ├── Icons.tsx        # Icon collection
│   ├── MetricCard.tsx   # Reusable cards
│   ├── UserProfile/     # Complex components get folders
│   │   ├── UserProfile.tsx
│   │   ├── UserAvatar.tsx
│   │   └── index.ts
│   └── ui/              # Basic UI primitives
│       ├── Button.tsx
│       ├── Input.tsx
│       ├── Modal.tsx
│       └── Layout.tsx   # Layout utility components
├── Pages/               # Inertia page components
│   ├── Dashboard/
│   │   └── Index.tsx
│   └── Users/
│       ├── Index.tsx
│       ├── Create.tsx
│       └── Edit.tsx
├── types/               # TypeScript type definitions
│   └── index.ts
└── utils/               # Utility functions
    └── helpers.ts
```

## Summary

1. **Keep it simple**: Components should primarily render props from the backend
2. **Component size**: Aim for components under 100 lines
3. **Co-location**: Keep related functionality together (loading states, child components)
4. **Layout utilities**: Use semantic layout components instead of nested divs with layout classes
5. **Minimal state**: Only UI state in React; data state on server
6. **useEffect sparingly**: Only for DOM/browser API integration, always with justifying comments
7. **Props-first**: Let Inertia handle data flow, React handles presentation
8. **Type safety**: Use TypeScript interfaces for all props and data structures
9. **Test behavior**: Focus on what users see and do, not implementation details

Following these conventions will result in maintainable, performant React applications that work harmoniously with Inertia.js.