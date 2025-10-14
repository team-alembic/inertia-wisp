# 032 - Pagination with DeferProp Demo

## What We're Building

A simple paginated users table demonstrating Inertia's `only` parameter for partial reloads and `DeferProp` for async loading.

**User clicks "Next"** → Only `users` and `page` reload, not entire page props.
**DeferProp loads separately** → The `demo_info` prop loads in a separate request after 2 seconds, demonstrating deferred loading.

## Components

### Backend Handler (`handlers/users_table.gleam`)
```gleam
pub type User {
  User(id: Int, name: String, email: String)
}

pub fn show(req, page: Int) {
  let users = generate_users(100)  // Total users
  let per_page = 10
  let paginated = slice(users, page, per_page)
  
  inertia.render(req, "UsersTable", [
    #("users", paginated),
    #("page", page),
    #("total_pages", 10),
    #("demo_info", "This prop doesn't reload!")  // Static prop
  ])
}
```

### Frontend Component (`Pages/UsersTable.tsx`)
```tsx
interface Props {
  users: Array<{id: number, name: string, email: string}>
  page: number
  total_pages: number
  demo_info: string
}

// Navigation uses:
router.get(`/users/table?page=${page + 1}`, {
  only: ['users', 'page', 'total_pages']  // demo_info stays cached
})
```

### Presentation Slide
- Intro to pagination
- Link to `/users/table`
- Shows `only` parameter usage

## Implementation Tasks

### Phase 1: Backend (TDD) ✅
- [x] Create handler with pagination logic
- [x] Generate 100 sample users
- [x] Handle page parameter
- [x] Add route
- [x] Use DeferProp for demo_info with 2-second sleep

### Phase 2: Frontend ✅
- [x] Create UsersTable page
- [x] Add table with 3 columns (ID, Name, Email)
- [x] Add Previous/Next buttons with disabled states
- [x] Use `only` parameter in router.get()
- [x] Use `<Deferred>` component with loading fallback

### Phase 3: Integration ✅
- [x] Create slide 20 with DeferProp intro
- [x] Add navigation links (to demo and back to slides)
- [x] Register slide in handlers
- [x] Update total_slides to 20
- [x] All tests passing (21 tests, no failures)
- [ ] Test in browser (start backend and navigate to /slides/20)

## Key Concepts

**DeferProp:** Loads in a separate request after initial render
- The `demo_info` prop has a 2-second artificial delay
- Page renders immediately without waiting for it
- Use `<Deferred>` component with loading fallback

**Partial Reload with `only`:** Only specified props reload during navigation
- `only: ['users', 'page', 'total_pages']` on pagination
- `demo_info` DeferProp is NOT re-fetched when navigating pages
- Dramatically reduces payload size

**Open the network tab to see:**
1. Initial page load + separate deferred prop request
2. Smaller payloads when navigating pages