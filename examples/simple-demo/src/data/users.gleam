//// User data types and database operations for the simple demo application.
////
//// This module demonstrates dynamic data handling with SQLite integration
//// and LazyProp evaluation. It provides CRUD operations for user management
//// to showcase the new inertia.eval API with real database interactions.

import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/string
import sqlight.{type Connection}

/// Search filters for advanced search functionality
pub type SearchFilters {
  SearchFilters(
    query: String,
    category: Option(String),
    date_range: Option(DateRange),
    sort_by: SortOption,
  )
}

/// Date range for filtering
pub type DateRange {
  DateRange(start: String, end: String)
}

/// Sort options for search results
pub type SortOption {
  SortByName
  SortByEmail
  SortByDate
}

/// Search analytics for filtered results (OptionalProp)
pub type SearchAnalytics {
  SearchAnalytics(
    total_filtered: Int,
    matching_percentage: Float,
    filter_performance_ms: Int,
  )
}

/// User analytics data (expensive to compute)
pub type UserAnalytics {
  UserAnalytics(
    total_users: Int,
    active_users: Int,
    growth_rate: Float,
    new_users_this_month: Int,
    average_session_duration: Float,
  )
}

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

/// Compute user analytics (expensive operation for OptionalProp demo)
/// This simulates expensive calculations that should only be done when needed
pub fn compute_user_analytics(
  db: Connection,
) -> Result(UserAnalytics, sqlight.Error) {
  // Get total users
  let total_result = get_user_count(db)

  // Simulate expensive calculations
  case total_result {
    Ok(total) -> {
      let active_users = total * 80 / 100
      // 80% active rate
      let growth_rate = 15.5
      // 15.5% growth
      let new_users_this_month = total * 12 / 100
      // 12% new this month
      let avg_session = 8.5
      // 8.5 minutes average session

      Ok(UserAnalytics(
        total_users: total,
        active_users: active_users,
        growth_rate: growth_rate,
        new_users_this_month: new_users_this_month,
        average_session_duration: avg_session,
      ))
    }
    Error(err) -> Error(err)
  }
}

/// User report data structure for deferred loading
pub type UserReport {
  UserReport(
    total_users: Int,
    active_users: Int,
    inactive_users: Int,
    recent_signups: List(User),
    top_domains: List(#(String, Int)),
    activity_summary: String,
  )
}

/// Generate comprehensive user report (expensive operation for DeferProp demo)
/// This simulates a very expensive operation that should be deferred
pub fn generate_user_report(db: Connection) -> Result(UserReport, sqlight.Error) {
  // Get all users for comprehensive analysis
  let users_result = get_all_users(db)

  case users_result {
    Ok(users) -> {
      let total_users = list.length(users)
      let active_users = total_users * 85 / 100
      // 85% active rate
      let inactive_users = total_users - active_users

      // Get recent signups (last 10 users)
      let recent_signups = list.take(users, 10)

      // Analyze email domains
      let top_domains = analyze_email_domains(users)

      // Generate activity summary
      let activity_summary = case total_users {
        0 -> "No users found"
        n if n < 10 -> "Small user base - growing"
        n if n < 100 -> "Medium user base - active"
        _ -> "Large user base - very active"
      }

      Ok(UserReport(
        total_users: total_users,
        active_users: active_users,
        inactive_users: inactive_users,
        recent_signups: recent_signups,
        top_domains: top_domains,
        activity_summary: activity_summary,
      ))
    }
    Error(err) -> Error(err)
  }
}

/// Analyze email domains from user list
fn analyze_email_domains(users: List(User)) -> List(#(String, Int)) {
  users
  |> list.map(fn(user) {
    case string.split_once(user.email, "@") {
      Ok(#(_, domain)) -> domain
      Error(_) -> "unknown"
    }
  })
  |> list.group(fn(domain) { domain })
  |> dict.to_list()
  |> list.map(fn(pair) { #(pair.0, list.length(pair.1)) })
  |> list.sort(fn(a, b) { int.compare(b.1, a.1) })
  |> list.take(5)
  // Top 5 domains
}

/// Activity feed data structure for deferred loading
pub type ActivityFeed {
  ActivityFeed(
    recent_activities: List(Activity),
    total_activities: Int,
    last_updated: String,
  )
}

/// Individual activity item
pub type Activity {
  Activity(id: Int, user_name: String, action: String, timestamp: String)
}

/// Decoder for UserAnalytics
pub fn decode_user_analytics(
  json_data: dynamic.Dynamic,
) -> Result(UserAnalytics, List(decode.DecodeError)) {
  let decoder = {
    use total_users <- decode.field("total_users", decode.int)
    use active_users <- decode.field("active_users", decode.int)
    use growth_rate <- decode.field("growth_rate", decode.float)
    use new_users_this_month <- decode.field("new_users_this_month", decode.int)
    use average_session_duration <- decode.field(
      "average_session_duration",
      decode.float,
    )
    decode.success(UserAnalytics(
      total_users: total_users,
      active_users: active_users,
      growth_rate: growth_rate,
      new_users_this_month: new_users_this_month,
      average_session_duration: average_session_duration,
    ))
  }
  decode.run(json_data, decoder)
}

/// Decoder for ActivityFeed
pub fn decode_activity_feed(
  json_data: dynamic.Dynamic,
) -> Result(ActivityFeed, List(decode.DecodeError)) {
  let activity_decoder = {
    use id <- decode.field("id", decode.int)
    use user_name <- decode.field("user_name", decode.string)
    use action <- decode.field("action", decode.string)
    use timestamp <- decode.field("timestamp", decode.string)
    decode.success(Activity(
      id: id,
      user_name: user_name,
      action: action,
      timestamp: timestamp,
    ))
  }

  let decoder = {
    use recent_activities <- decode.field(
      "recent_activities",
      decode.list(activity_decoder),
    )
    use total_activities <- decode.field("total_activities", decode.int)
    use last_updated <- decode.field("last_updated", decode.string)
    decode.success(ActivityFeed(
      recent_activities: recent_activities,
      total_activities: total_activities,
      last_updated: last_updated,
    ))
  }
  decode.run(json_data, decoder)
}

/// Parse search filters from query parameters
pub fn parse_search_filters(
  query_params: List(#(String, String)),
) -> SearchFilters {
  let query = case list.key_find(query_params, "query") {
    Ok(value) -> value
    Error(_) -> ""
  }

  let category =
    list.key_find(query_params, "category")
    |> option.from_result

  let sort_by = case list.key_find(query_params, "sort_by") {
    Ok("name") -> SortByName
    Ok("email") -> SortByEmail
    Ok("date") -> SortByDate
    Ok(_) -> SortByName
    Error(_) -> SortByName
  }

  SearchFilters(
    query: query,
    category: category,
    date_range: option.None,
    sort_by: sort_by,
  )
}
