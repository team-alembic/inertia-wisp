//// Test database utilities for the simple demo application.
////
//// This module contains test-specific functions for setting up and managing
//// test databases. These functions should NOT be in production code modules.

import data/users
import sqlight.{type Connection}

/// Initialize sample data for testing
pub fn init_sample_data(db: Connection) -> Result(Nil, sqlight.Error) {
  let sql =
    "
    INSERT INTO users (name, email) VALUES
    ('Demo User 1', 'demo1@example.com'),
    ('Demo User 2', 'demo2@example.com'),
    ('Demo User 3', 'demo3@example.com')
  "
  sqlight.exec(sql, db)
}

/// Create a test database with users table and sample data
pub fn setup_test_database() -> Result(Connection, sqlight.Error) {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  let assert Ok(_) = init_sample_data(db)
  Ok(db)
}

/// Create an empty test database with users table but no data
pub fn setup_empty_test_database() -> Result(Connection, sqlight.Error) {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)
  Ok(db)
}

/// Helper to create test database fixture for advanced props testing
pub fn setup_advanced_test_database() -> Result(Connection, sqlight.Error) {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = users.create_users_table(db)

  // Add more diverse test data for advanced filtering tests
  let sql =
    "
    INSERT INTO users (name, email) VALUES
    ('Demo User 1', 'demo1@example.com'),
    ('Demo User 2', 'demo2@example.com'),
    ('Demo User 3', 'demo3@example.com'),
    ('Admin User', 'admin@company.com'),
    ('Test Manager', 'manager@company.com'),
    ('Alice Smith', 'alice@users.com'),
    ('Bob Johnson', 'bob@users.com')
  "
  case sqlight.exec(sql, db) {
    Ok(_) -> Ok(db)
    Error(err) -> Error(err)
  }
}
