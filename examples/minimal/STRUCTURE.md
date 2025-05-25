# Project Structure

This document describes the reorganized structure of the minimal Inertia.js example application.

## Overview

The user-related code has been refactored from a single monolithic file into a well-organized, modular structure following Gleam and Wisp conventions.

## Directory Structure

```
src/
├── minimal_inertia_example.gleam    # Main application entry point
├── types/
│   └── user.gleam                   # User-related type definitions
├── data/
│   └── users.gleam                  # Data access and state management
├── validators/
│   └── user_validator.gleam         # User input validation logic
└── handlers/
    ├── utils.gleam                  # Shared handler utilities and patterns
    ├── users.gleam                  # Aggregated user handlers (main export)
    └── users/
        ├── create_handler.gleam     # User creation handlers
        ├── list_handler.gleam       # User listing handlers
        ├── show_handler.gleam       # User display handlers
        ├── edit_handler.gleam       # User editing handlers
        └── delete_handler.gleam     # User deletion handlers
```

## Module Responsibilities

### `types/user.gleam`
- Defines `User` type for user entities
- Defines `CreateUserRequest` type for form submissions
- Defines `AppState` type for application state management

### `data/users.gleam`
- Manages user data access (simulated in-memory storage)
- Provides `get_initial_state()` function for demo data
- Provides `find_user_by_id()` helper function

### `validators/user_validator.gleam`
- Contains `validate_user_input()` function
- Handles name and email validation
- Checks for duplicate emails across users

### `handlers/users/*.gleam`
Individual handler modules for specific user operations:
- **create_handler**: `create_user_page()`, `create_user()`
- **list_handler**: `users_page()`
- **show_handler**: `show_user_page()`
- **edit_handler**: `edit_user_page()`, `update_user()`
- **delete_handler**: `delete_user()`

### `handlers/utils.gleam`
- Contains shared utilities used across multiple handlers
- Provides `assign_common_props()` for consistent authentication/CSRF setup
- Provides `parse_user_id()` for consistent ID parsing
- Provides `serialize_user_data()` for consistent JSON serialization

### `handlers/users.gleam`
- Aggregates and re-exports all user handler functions
- Provides a clean, single import point for the main application
- Maintains consistent function signatures across handlers

## Benefits of This Structure

1. **Separation of Concerns**: Each module has a single, well-defined responsibility
2. **Reusability**: Validation and data access logic can be reused across handlers
3. **Maintainability**: Changes to specific operations only affect their respective modules
4. **Testability**: Individual handlers and validators can be tested in isolation
5. **Scalability**: Easy to add new user operations or extend existing ones
6. **Clean Imports**: Main application only needs to import `handlers/users`
7. **Single Level of Abstraction**: Each function operates at one level of abstraction
8. **DRY Principle**: Common patterns are extracted into shared utilities
9. **Consistent Error Handling**: Uniform approach to parsing and validation errors
10. **Clear Function Responsibilities**: Each function has one clear purpose

## Usage Example

```gleam
import handlers/users

// In your routing logic:
["users"], http.Get -> users.users_page(req)
["users"], http.Post -> users.create_user(req)
["users", id], http.Get -> users.show_user_page(req, id)
```

## Design Principles Applied

### Single Level of Abstraction (SLA)
Each function operates at one level of abstraction, making the code easier to read and understand:
- Main handler functions focus on high-level flow
- Helper functions handle specific concerns (parsing, validation, serialization)
- Business logic is separated from HTTP/JSON concerns

### DRY (Don't Repeat Yourself)
Common patterns are extracted into reusable utilities:
- Authentication props setup
- User ID parsing
- User data serialization
- Error handling patterns

### Clear Function Naming
Function names clearly indicate their purpose and level:
- `handle_valid_user_request()` - business logic level
- `decode_user_request()` - data transformation level
- `parse_user_id()` - utility level
- `render_user_page()` - presentation level

## Conventions Followed

- Handler functions take `wisp.Request` as first parameter
- Handler functions return `wisp.Response`
- Module names use snake_case
- File organization follows domain-driven design principles
- Shared functionality is extracted into dedicated modules
- Each function has a single, well-defined responsibility
- Type annotations are used for clarity and compiler assistance

This structure can serve as a template for organizing other resource handlers (e.g., posts, comments, etc.) in larger Gleam/Wisp applications.