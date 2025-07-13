//// User data types and database operations for the simple demo application.
////
//// This module demonstrates dynamic data handling with SQLite integration
//// and LazyProp evaluation. It provides CRUD operations for user management
//// to showcase the new inertia.eval API with real database interactions.

import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option}
import gleam/string
import sqlight.{type Connection}

/// User data structure
pub type User {
  User(id: Int, name: String, email: String, created_at: String)
}

/// User creation request (without ID)
pub type CreateUserRequest {
  CreateUserRequest(name: String, email: String)
}

/// Decoder for CreateUserRequest from JSON
pub fn decode_create_user_request(
  json_data: dynamic.Dynamic,
) -> Result(CreateUserRequest, List(decode.DecodeError)) {
  let decoder = {
    use name <- decode.field("name", decode.string)
    use email <- decode.field("email", decode.string)
    decode.success(CreateUserRequest(name, email))
  }

  decode.run(json_data, decoder)
}

/// User update request
pub type UpdateUserRequest {
  UpdateUserRequest(id: Int, name: String, email: String)
}

/// Validation errors for user operations
pub type UserValidationError {
  NameEmpty
  NameTooShort
  NameTooLong
  EmailInvalid
  EmailAlreadyExists
  UserNotFound
}

/// Create the users table in the database
pub fn create_users_table(db: Connection) -> Result(Nil, sqlight.Error) {
  let sql =
    "
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  "
  sqlight.exec(sql, db)
}

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

/// Get all users from the database (potentially expensive operation)
pub fn get_all_users(db: Connection) -> Result(List(User), sqlight.Error) {
  let sql = "SELECT id, name, email, created_at FROM users ORDER BY id"
  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    use created_at <- decode.field(3, decode.string)
    decode.success(User(
      id: id,
      name: name,
      email: email,
      created_at: created_at,
    ))
  }

  sqlight.query(sql, on: db, with: [], expecting: decoder)
}

/// Get a single user by ID
pub fn get_user_by_id(
  db: Connection,
  id: Int,
) -> Result(Option(User), sqlight.Error) {
  let sql = "SELECT id, name, email, created_at FROM users WHERE id = ? LIMIT 1"
  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    use created_at <- decode.field(3, decode.string)
    decode.success(User(
      id: id,
      name: name,
      email: email,
      created_at: created_at,
    ))
  }

  case sqlight.query(sql, on: db, with: [sqlight.int(id)], expecting: decoder) {
    Ok([user]) -> Ok(option.Some(user))
    Ok([]) -> Ok(option.None)
    Ok(_) -> Ok(option.None)
    Error(err) -> Error(err)
  }
}

/// Create a new user
pub fn create_user(
  db: Connection,
  request: CreateUserRequest,
) -> Result(User, sqlight.Error) {
  let sql =
    "INSERT INTO users (name, email) VALUES (?, ?) RETURNING id, name, email, created_at"

  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    use created_at <- decode.field(3, decode.string)
    decode.success(User(
      id: id,
      name: name,
      email: email,
      created_at: created_at,
    ))
  }

  case
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.text(request.name), sqlight.text(request.email)],
      expecting: decoder,
    )
  {
    Ok([user]) -> Ok(user)
    Ok([]) ->
      Error(sqlight.SqlightError(
        code: sqlight.ConstraintForeignkey,
        message: "Failed to create user",
        offset: 0,
      ))
    Ok(_) ->
      Error(sqlight.SqlightError(
        code: sqlight.ConstraintForeignkey,
        message: "Unexpected result",
        offset: 0,
      ))
    Error(err) -> Error(err)
  }
}

/// Update an existing user
pub fn update_user(
  db: Connection,
  request: UpdateUserRequest,
) -> Result(User, sqlight.Error) {
  let sql =
    "UPDATE users SET name = ?, email = ? WHERE id = ? RETURNING id, name, email, created_at"

  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    use created_at <- decode.field(3, decode.string)
    decode.success(User(
      id: id,
      name: name,
      email: email,
      created_at: created_at,
    ))
  }

  case
    sqlight.query(
      sql,
      on: db,
      with: [
        sqlight.text(request.name),
        sqlight.text(request.email),
        sqlight.int(request.id),
      ],
      expecting: decoder,
    )
  {
    Ok([user]) -> Ok(user)
    Ok([]) ->
      Error(sqlight.SqlightError(
        code: sqlight.ConstraintForeignkey,
        message: "User not found",
        offset: 0,
      ))
    Ok(_) ->
      Error(sqlight.SqlightError(
        code: sqlight.ConstraintForeignkey,
        message: "Unexpected result",
        offset: 0,
      ))
    Error(err) -> Error(err)
  }
}

/// Delete a user by ID
pub fn delete_user(db: Connection, id: Int) -> Result(Nil, sqlight.Error) {
  let sql = "DELETE FROM users WHERE id = ?"

  case
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.int(id)],
      expecting: decode.success(Nil),
    )
  {
    Ok(_) -> Ok(Nil)
    Error(err) -> Error(err)
  }
}

/// Search users by name (for filtering demonstrations)
pub fn search_users(
  db: Connection,
  query: String,
) -> Result(List(User), sqlight.Error) {
  let sql = case query {
    "" -> "SELECT id, name, email, created_at FROM users ORDER BY id"
    _ ->
      "SELECT id, name, email, created_at FROM users WHERE LOWER(name) LIKE LOWER(?) ORDER BY id"
  }

  let params = case query {
    "" -> []
    _ -> [sqlight.text("%" <> query <> "%")]
  }

  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    use created_at <- decode.field(3, decode.string)
    decode.success(User(
      id: id,
      name: name,
      email: email,
      created_at: created_at,
    ))
  }

  sqlight.query(sql, on: db, with: params, expecting: decoder)
}

/// Get user count (expensive operation for LazyProp demo)
pub fn get_user_count(db: Connection) -> Result(Int, sqlight.Error) {
  let sql = "SELECT COUNT(*) FROM users"

  case
    sqlight.query(sql, on: db, with: [], expecting: {
      use count <- decode.field(0, decode.int)
      decode.success(count)
    })
  {
    Ok([count]) -> Ok(count)
    Ok([]) -> Ok(0)
    Ok(_) ->
      Error(sqlight.SqlightError(
        code: sqlight.GenericError,
        message: "Unexpected result",
        offset: 0,
      ))
    Error(err) -> Error(err)
  }
}

/// Validate user creation request
pub fn validate_create_user(
  db: Connection,
  request: CreateUserRequest,
) -> Result(CreateUserRequest, List(UserValidationError)) {
  let mut_errors = []

  // Validate name length
  let name_len = string.length(request.name)
  let mut_errors = case
    name_len == 0,
    name_len > 0 && name_len < 2,
    name_len > 50
  {
    True, _, _ -> [NameEmpty, ..mut_errors]
    _, True, _ -> [NameTooShort, ..mut_errors]
    _, _, True -> [NameTooLong, ..mut_errors]
    False, False, False -> mut_errors
  }

  // Validate email format (simple check for @ symbol)
  let mut_errors = case string.contains(request.email, "@") {
    False -> [EmailInvalid, ..mut_errors]
    True -> mut_errors
  }

  // Check email uniqueness
  let mut_errors = case check_email_exists(db, request.email) {
    Ok(True) -> [EmailAlreadyExists, ..mut_errors]
    Ok(False) -> mut_errors
    Error(_) -> mut_errors
  }

  case mut_errors {
    [] -> Ok(request)
    errors -> Error(list.reverse(errors))
  }
}

/// Validate user update request
pub fn validate_update_user(
  db: Connection,
  request: UpdateUserRequest,
) -> Result(UpdateUserRequest, List(UserValidationError)) {
  let mut_errors = []

  // Check if user exists
  let mut_errors = case get_user_by_id(db, request.id) {
    Ok(option.None) -> [UserNotFound, ..mut_errors]
    Ok(option.Some(_)) -> mut_errors
    Error(_) -> [UserNotFound, ..mut_errors]
  }

  // Validate name length
  let name_len = string.length(request.name)
  let mut_errors = case
    name_len == 0,
    name_len > 0 && name_len < 2,
    name_len > 50
  {
    True, _, _ -> [NameEmpty, ..mut_errors]
    _, True, _ -> [NameTooShort, ..mut_errors]
    _, _, True -> [NameTooLong, ..mut_errors]
    False, False, False -> mut_errors
  }

  // Validate email format (simple check for @ symbol)
  let mut_errors = case string.contains(request.email, "@") {
    False -> [EmailInvalid, ..mut_errors]
    True -> mut_errors
  }

  // Check email uniqueness (excluding current user)
  let mut_errors = case
    check_email_exists_excluding_user(db, request.email, request.id)
  {
    Ok(True) -> [EmailAlreadyExists, ..mut_errors]
    Ok(False) -> mut_errors
    Error(_) -> mut_errors
  }

  case mut_errors {
    [] -> Ok(request)
    errors -> Error(list.reverse(errors))
  }
}

/// Helper function to check if email exists
fn check_email_exists(
  db: Connection,
  email: String,
) -> Result(Bool, sqlight.Error) {
  let sql = "SELECT COUNT(*) FROM users WHERE email = ?"

  case
    sqlight.query(sql, on: db, with: [sqlight.text(email)], expecting: {
      use count <- decode.field(0, decode.int)
      decode.success(count)
    })
  {
    Ok([count]) -> Ok(count > 0)
    Ok(_) -> Ok(False)
    Error(err) -> Error(err)
  }
}

/// Helper function to check if email exists excluding a specific user
fn check_email_exists_excluding_user(
  db: Connection,
  email: String,
  user_id: Int,
) -> Result(Bool, sqlight.Error) {
  let sql = "SELECT COUNT(*) FROM users WHERE email = ? AND id != ?"

  case
    sqlight.query(
      sql,
      on: db,
      with: [sqlight.text(email), sqlight.int(user_id)],
      expecting: {
        use count <- decode.field(0, decode.int)
        decode.success(count)
      },
    )
  {
    Ok([count]) -> Ok(count > 0)
    Ok(_) -> Ok(False)
    Error(err) -> Error(err)
  }
}
