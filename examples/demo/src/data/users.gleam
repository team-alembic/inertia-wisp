import gleam/dynamic/decode
import gleam/result
import shared_types/users.{type User, User}
import sqlight

fn user_row_decoder() {
  use user_id <- decode.field(0, decode.int)
  use name <- decode.field(1, decode.string)
  use email <- decode.field(2, decode.string)
  decode.success(User(id: user_id, name: name, email: email))
}

// Initialize database with sample data
pub fn init_sample_data(db: sqlight.Connection) -> Result(Nil, sqlight.Error) {
  use _ <- result.try(sqlight.exec(
    "INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com')",
    db,
  ))
  sqlight.exec(
    "INSERT INTO users (name, email) VALUES ('Bob', 'bob@example.com')",
    db,
  )
}

pub fn find_user_by_id(
  db: sqlight.Connection,
  id: Int,
) -> Result(User, sqlight.Error) {
  let sql = "SELECT id, name, email FROM users WHERE id = ?"

  use rows <- result.try(sqlight.query(
    sql,
    on: db,
    with: [sqlight.int(id)],
    expecting: user_row_decoder(),
  ))
  case rows {
    [user] -> Ok(user)
    [] ->
      Error(sqlight.SqlightError(
        code: sqlight.GenericError,
        message: "User not found",
        offset: -1,
      ))
    _ ->
      Error(sqlight.SqlightError(
        code: sqlight.GenericError,
        message: "Multiple users found",
        offset: -1,
      ))
  }
}

pub fn get_all_users(
  db: sqlight.Connection,
) -> Result(List(User), sqlight.Error) {
  let sql = "SELECT id, name, email FROM users ORDER BY id"
  sqlight.query(sql, on: db, with: [], expecting: user_row_decoder())
}

pub fn create_user(
  db: sqlight.Connection,
  name: String,
  email: String,
) -> Result(Int, sqlight.Error) {
  let sql = "INSERT INTO users (name, email) VALUES (?, ?) RETURNING id"
  let decoder = decode.at([0], decode.int)

  use rows <- result.try(sqlight.query(
    sql,
    on: db,
    with: [sqlight.text(name), sqlight.text(email)],
    expecting: decoder,
  ))
  case rows {
    [id] -> Ok(id)
    _err -> {
      Error(sqlight.SqlightError(
        code: sqlight.GenericError,
        message: "Failed to get inserted ID",
        offset: -1,
      ))
    }
  }
}

pub fn update_user(
  db: sqlight.Connection,
  id: Int,
  name: String,
  email: String,
) -> Result(Nil, sqlight.Error) {
  let sql = "UPDATE users SET name = ?, email = ? WHERE id = ?"
  let decoder = decode.success(Nil)
  use _ <- result.try(sqlight.query(
    sql,
    on: db,
    with: [sqlight.text(name), sqlight.text(email), sqlight.int(id)],
    expecting: decoder,
  ))
  Ok(Nil)
}

pub fn delete_user(
  db: sqlight.Connection,
  id: Int,
) -> Result(Nil, sqlight.Error) {
  let sql = "DELETE FROM users WHERE id = ?"
  let decoder = decode.success(Nil)
  use _ <- result.try(sqlight.query(
    sql,
    on: db,
    with: [sqlight.int(id)],
    expecting: decoder,
  ))
  Ok(Nil)
}
