# Feature 001: Refactor Gleam Projections

## Plan

### Overview
Refactor `gleam-projections.ts` to improve modularity by removing page props exports and adding a `WithErrors<Props>` utility type for form pages.

### Goals
1. **Remove page props coupling**: Page components should import Gleam types directly instead of through the projection file
2. **Add WithErrors utility**: Create a `WithErrors<Props>` type that adds form error handling to page props
3. **Improve separation of concerns**: Keep projection utilities focused on type transformations, not specific page types
4. **Maintain form data projections**: Keep the useful form request projections that handle Option/List transformations

### Changes Required

#### 1. Remove Page Props Imports and Exports
Remove these imports from `gleam-projections.ts`:
- `ContactPageProps$` and related types from contact module
- `LoginPageProps$` and related types from auth module  
- `UserProfilePageProps$` and related types from users module
- `BlogPostPageProps$` from blog module
- `DashboardPageProps$` from dashboard module
- `HomePageProps$` from home module

Remove these type aliases:
- `UserProfilePageData`
- `BlogPostPageData` 
- `DashboardPageData`
- `HomePageData`
- `ContactFormPageData`
- `LoginFormPageData`
- `CreateUserFormPageData`
- `EditProfileFormPageData`
- All page-related convenience exports

#### 2. Add WithErrors Utility Type
Create a new utility type:
```typescript
export type WithErrors<Props> = GleamToJS<Props> & {
  errors: Record<string, string>;
};
```

This allows pages to opt-in to error handling:
- Form pages: `WithErrors<LoginPageProps$>`
- Read-only pages: `GleamToJS<BlogPostPageProps$>`

#### 3. Keep Form Data Projections
Maintain these useful projections since they handle complex Option/List transformations:
- `ContactFormData`
- `CreateUserFormData`
- `UpdateProfileFormData` 
- `LoginFormData`
- Form error types (`FormErrors`, `ValidationErrors`, etc.)

#### 4. Update Documentation
- Remove page-specific examples
- Add clear examples of how pages should import types directly
- Document the WithErrors pattern for form pages
- Update usage examples to reflect new approach

#### 5. Clean Up Unused Code
- Remove page data convenience exports
- Remove `PageData<T>` generic if no longer needed
- Clean up any orphaned documentation

### Benefits
1. **Better modularity**: Page components own their type dependencies
2. **Cleaner separation**: Projection file focused on transformation utilities
3. **Flexible error handling**: Pages can opt-in to error props as needed
4. **Reduced coupling**: Changes to page types don't require projection file updates
5. **Clearer intent**: `WithErrors<Props>` explicitly shows which pages handle forms

### Usage After Refactor
```typescript
// In a form page component
import type { LoginPageProps$ } from "path/to/gleam/types";
import type { WithErrors } from "./types/gleam-projections";

type Props = WithErrors<LoginPageProps$>;

// In a read-only page component  
import type { BlogPostPageProps$ } from "path/to/gleam/types";
import type { GleamToJS } from "./types/gleam-projections";

type Props = GleamToJS<BlogPostPageProps$>;

// For form data (still projected)
import type { LoginFormData } from "./types/gleam-projections";
```

This refactor will make the type system more explicit about which pages handle forms while reducing unnecessary coupling between the projection utilities and specific page types.

## Log

### Implementation Complete
Successfully refactored `gleam-projections.ts` with the following changes:

#### 1. Removed Page Props Imports and Exports ✅
- Removed all page props imports from contact, auth, users, blog, dashboard, and home modules
- Removed type aliases: `UserProfilePageData`, `BlogPostPageData`, `DashboardPageData`, `HomePageData`
- Removed convenience aliases: `ContactFormPageData`, `LoginFormPageData`, `CreateUserFormPageData`, `EditProfileFormPageData`
- Removed re-exports of `ContactPageProps` and `LoginPageProps`
- Removed page data convenience exports section

#### 2. Added WithErrors Utility Type ✅
Created the `WithErrors<Props>` utility type:
```typescript
export type WithErrors<Props> = GleamToJS<Props> & {
  errors: Record<string, string>;
};
```

Added comprehensive documentation with usage examples showing:
- Form pages: `WithErrors<LoginPageProps$>`
- Read-only pages: `GleamToJS<BlogPostPageProps$>`
- How pages should import Gleam types directly

#### 3. Preserved Form Data Projections ✅
Kept all important form request projections:
- `ContactFormData`, `CreateUserFormData`, `UpdateProfileFormData`, `LoginFormData`
- All form error types (`FormErrors`, `ValidationErrors`, `FieldErrors`, etc.)
- Form response and validation types

#### 4. Updated Documentation ✅
- Replaced page-specific examples with generic usage patterns
- Added clear examples of direct Gleam type imports
- Documented the `WithErrors` pattern for form pages
- Updated Dict projection examples to be more focused
- Removed page-specific Dict examples in favor of general patterns

#### 5. Cleaned Up Unused Code ✅
- Removed all page data convenience exports
- Kept `PageData<T>` generic as it's still useful for general projections
- Streamlined import statements to only include form-related types
- Maintained all form-related utilities and runtime helpers

### Key Benefits Achieved
1. **Better modularity**: Page components now own their type dependencies
2. **Cleaner separation**: Projection file focused purely on transformation utilities
3. **Flexible error handling**: Pages can explicitly opt-in to error props via `WithErrors<T>`
4. **Reduced coupling**: Page type changes no longer require projection file updates
5. **Clearer intent**: `WithErrors<Props>` makes form pages obvious in the codebase

### Implementation Notes
- All existing form data projections remain unchanged to avoid breaking form submissions
- The `WithErrors<T>` type uses intersection (`&`) to cleanly add the errors field
- Documentation now emphasizes direct imports from Gleam-generated types
- Runtime utilities preserved for backward compatibility

### Completed Task: Update Page Components
Successfully updated all page components in `examples/typed-demo/frontend/src/pages/*` to use the new type system:

**Components Updated:**
- ✅ Analyzed existing components and their current type usage
- ✅ Home.tsx - Updated to use `GleamToJS<HomePageProps$>` with direct import
- ✅ Dashboard.tsx - Updated to use `GleamToJS<DashboardPageProps$>` with direct import  
- ✅ auth/Login.tsx - Updated to use `WithErrors<LoginPageProps$>` for form error handling
- ✅ contact/ContactForm.tsx - Updated to use `WithErrors<ContactPageProps$>` for form error handling
- ✅ users/CreateUser.tsx - Updated to use `WithErrors<HomePageProps$>` (backend uses home props)
- ✅ users/EditProfile.tsx - Updated to use `WithErrors<UserProfilePageProps$>` with proper prop mapping
- ✅ users/UserProfile.tsx - Updated to use `GleamToJS<UserProfilePageProps$>` with direct import
- ✅ blog/BlogPost.tsx - Updated to use `GleamToJS<BlogPostPageProps$>` with direct import

**Key Changes Per Component:**
1. ✅ Replaced projection type imports with direct Gleam type imports using `@shared_types/*` path mappings
2. ✅ Used `WithErrors<T>` for form pages that need error handling (Login, ContactForm, CreateUser, EditProfile)
3. ✅ Used `GleamToJS<T>` for read-only pages (Home, Dashboard, UserProfile, BlogPost)
4. ✅ Updated import paths to use tsconfig path mappings (`@shared_types/shared_types/*.d.mts`)
5. ✅ Fixed all TypeScript errors - `npx tsc --noEmit` passes successfully
6. ✅ Fixed EditProfile component to properly map UserProfilePageProps individual fields to expected user object

**Implementation Notes:**
- CreateUser page uses HomePageProps$ because the backend handler uses `home.with_home_page_props()`
- EditProfile required prop mapping since EditProfileForm expects a `user` object but UserProfilePageProps has individual fields
- All imports now use the configured path mappings for cleaner, more maintainable imports
- No TypeScript compilation errors after the refactor

## Conclusion

The refactoring has been successfully completed, achieving all the goals outlined in the plan:

### ✅ Successfully Achieved Goals

1. **Removed page props coupling**: Page components now import Gleam types directly using `@shared_types/*` path mappings instead of going through the projection file
2. **Added WithErrors utility**: Created and implemented `WithErrors<Props>` type that cleanly adds form error handling to page props
3. **Improved separation of concerns**: The projection file is now focused purely on type transformation utilities, not specific page types
4. **Maintained form data projections**: All useful form request projections that handle Option/List transformations are preserved

### 📊 Impact Summary

**Before:**
- 9 page-specific type aliases exported from gleam-projections.ts
- Tight coupling between projection utilities and page types
- Page components dependent on projection file exports
- Mixed responsibilities in the projection file

**After:**
- 0 page-specific exports in gleam-projections.ts (removed 9 type aliases)
- Pages import Gleam types directly using path mappings
- Clear separation: `WithErrors<T>` for form pages, `GleamToJS<T>` for read-only pages
- Projection file focused purely on type transformation utilities

### 🎯 Benefits Realized

1. **Better modularity**: Page components own their type dependencies and can evolve independently
2. **Clearer intent**: `WithErrors<Props>` makes it immediately obvious which pages handle forms
3. **Reduced coupling**: Changes to page types no longer require updates to the projection file
4. **Cleaner imports**: Using tsconfig path mappings provides shorter, more maintainable import statements
5. **Type safety maintained**: Full compile-time type checking preserved while improving architecture

### 🔄 New Usage Patterns

```typescript
// Form pages with error handling
import type { LoginPageProps$ } from "@shared_types/shared_types/auth.d.mts";
import type { WithErrors } from "../types/gleam-projections";
type Props = WithErrors<LoginPageProps$>;

// Read-only pages
import type { BlogPostPageProps$ } from "@shared_types/shared_types/blog.d.mts";
import type { GleamToJS } from "../types/gleam-projections";
type Props = GleamToJS<BlogPostPageProps$>;

// Form data (still projected for Option/List transformations)
import type { LoginFormData } from "../types/gleam-projections";
```

The refactoring successfully modernized the type system architecture while maintaining full type safety and backward compatibility for form submissions. The codebase is now more modular, maintainable, and expressive about the intent of each page component.