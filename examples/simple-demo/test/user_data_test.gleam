//// Tests for user data operations using TDD approach for Phase 2.
////
//// This test module follows TDD principles and tests the user data layer
//// to ensure it correctly demonstrates:
//// - Database integration with SQLite
//// - CRUD operations for users
//// - LazyProp evaluation with expensive operations
//// - Validation handling
//// - Error cases and edge conditions

import data/users
import gleam/list
import gleam/option

import gleam/string
import sqlight

/// Test database creation and table setup
pub fn create_users_table_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let result = users.create_users_table(db)

  assert result == Ok(Nil)
}

/// Test sample data initialization
pub fn init_sample_data_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let result = users.init_sample_data(db)

  assert result == Ok(Nil)

  // Should have inserted some sample users
  let assert Ok(all_users) = users.get_all_users(db)
  assert list.length(all_users) > 0
}

/// Test getting all users from database
pub fn get_all_users_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let result = users.get_all_users(db)
  let assert Ok(user_list) = result

  // Should return a list of users
  assert list.length(user_list) >= 3

  // First user should have expected structure
  let assert Ok(users.User(
    id: id,
    name: name,
    email: email,
    created_at: created_at,
  )) = list.first(user_list)
  assert id > 0
  assert name != ""
  assert email != ""
  assert created_at != ""
}

/// Test getting user by ID
pub fn get_user_by_id_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  // Should find existing user
  let result = users.get_user_by_id(db, 1)
  let assert Ok(option.Some(user)) = result
  assert user.id == 1
  assert user.name != ""
  assert user.email != ""

  // Should return None for non-existent user
  let result = users.get_user_by_id(db, 999)
  assert result == Ok(option.None)
}

/// Test creating a new user
pub fn create_user_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  let request = users.CreateUserRequest("John Doe", "john@example.com")
  let result = users.create_user(db, request)

  let assert Ok(user) = result
  assert user.id > 0
  assert user.name == "John Doe"
  assert user.email == "john@example.com"
  assert user.created_at != ""

  // Should be able to retrieve the created user
  let assert Ok(option.Some(retrieved_user)) = users.get_user_by_id(db, user.id)
  assert retrieved_user.name == "John Doe"
  assert retrieved_user.email == "john@example.com"
}

/// Test updating an existing user
pub fn update_user_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let request =
    users.UpdateUserRequest(1, "Updated Name", "updated@example.com")
  let result = users.update_user(db, request)

  let assert Ok(user) = result
  assert user.id == 1
  assert user.name == "Updated Name"
  assert user.email == "updated@example.com"

  // Should be able to retrieve the updated user
  let assert Ok(option.Some(retrieved_user)) = users.get_user_by_id(db, 1)
  assert retrieved_user.name == "Updated Name"
  assert retrieved_user.email == "updated@example.com"
}

/// Test deleting a user
pub fn delete_user_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  // User should exist before deletion
  let assert Ok(option.Some(_)) = users.get_user_by_id(db, 1)

  let result = users.delete_user(db, 1)
  assert result == Ok(Nil)

  // User should not exist after deletion
  let assert Ok(option.None) = users.get_user_by_id(db, 1)
}

/// Test searching users by name
pub fn search_users_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  // Search for users with specific term
  let result = users.search_users(db, "Demo")
  let assert Ok(found_users) = result

  // Should find users with "Demo" in their name
  assert list.length(found_users) > 0

  // All found users should contain the search term
  list.each(found_users, fn(user) {
    // Name should contain "Demo" (case-insensitive)
    let name_lower = user.name |> string.lowercase
    let query_lower = "demo"
    assert string.contains(name_lower, query_lower)
  })

  // Empty search should return all users
  let assert Ok(all_users) = users.search_users(db, "")
  let assert Ok(expected_all) = users.get_all_users(db)
  assert list.length(all_users) == list.length(expected_all)
}

/// Test getting user count (expensive operation for LazyProp demo)
pub fn get_user_count_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  let result = users.get_user_count(db)
  let assert Ok(count) = result

  assert count > 0

  // Count should match the actual number of users
  let assert Ok(all_users) = users.get_all_users(db)
  assert count == list.length(all_users)
}

/// Test user creation validation
pub fn validate_create_user_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  // Valid request should pass
  let valid_request = users.CreateUserRequest("John Doe", "john@example.com")
  let result = users.validate_create_user(db, valid_request)
  assert result == Ok(valid_request)

  // Invalid name (too short) should fail
  let invalid_name = users.CreateUserRequest("A", "valid@example.com")
  let assert Error(errors) = users.validate_create_user(db, invalid_name)
  assert list.contains(errors, users.NameTooShort)

  // Invalid name (too long) should fail
  let long_name =
    "A very very very very very very long name that exceeds the maximum allowed length"
  let invalid_long_name =
    users.CreateUserRequest(long_name, "valid@example.com")
  let assert Error(errors) = users.validate_create_user(db, invalid_long_name)
  assert list.contains(errors, users.NameTooLong)

  // Invalid email should fail
  let invalid_email = users.CreateUserRequest("John Doe", "invalid-email")
  let assert Error(errors) = users.validate_create_user(db, invalid_email)
  assert list.contains(errors, users.EmailInvalid)
}

/// Test user update validation
pub fn validate_update_user_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = users.init_sample_data(db)

  // Valid request should pass
  let valid_request =
    users.UpdateUserRequest(1, "Updated Name", "updated@example.com")
  let result = users.validate_update_user(db, valid_request)
  assert result == Ok(valid_request)

  // Non-existent user should fail
  let invalid_user =
    users.UpdateUserRequest(999, "Valid Name", "valid@example.com")
  let assert Error(errors) = users.validate_update_user(db, invalid_user)
  assert list.contains(errors, users.UserNotFound)

  // Invalid data should fail with appropriate errors
  let invalid_data = users.UpdateUserRequest(1, "A", "invalid-email")
  let assert Error(errors) = users.validate_update_user(db, invalid_data)
  assert list.contains(errors, users.NameTooShort)
  assert list.contains(errors, users.EmailInvalid)
}

/// Test email uniqueness validation
pub fn email_uniqueness_validation_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  // Create first user
  let first_user = users.CreateUserRequest("First User", "test@example.com")
  let assert Ok(_) = users.create_user(db, first_user)

  // Try to create second user with same email
  let duplicate_email =
    users.CreateUserRequest("Second User", "test@example.com")
  let assert Error(errors) = users.validate_create_user(db, duplicate_email)
  assert list.contains(errors, users.EmailAlreadyExists)
}

/// Test database error handling
pub fn database_error_handling_test() {
  // Test with invalid database connection
  let assert Ok(db) = sqlight.open(":memory:")
  // Don't create tables - this should cause errors

  let result = users.get_all_users(db)
  // Should return an error (table doesn't exist)
  let assert Error(_) = result
}

/// Test edge cases and boundary conditions
pub fn edge_cases_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  // Empty database should return empty list
  let assert Ok(users_list) = users.get_all_users(db)
  assert users_list == []

  // Count should be zero
  let assert Ok(count) = users.get_user_count(db)
  assert count == 0

  // Search should return empty list
  let assert Ok(search_results) = users.search_users(db, "anything")
  assert search_results == []
}
