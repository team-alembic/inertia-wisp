//// Tests for users_table handler

import gleam/list
import gleam/string
import handlers/users_table.{generate_users, paginate}

// Test user generation

pub fn generate_users_creates_correct_count_test() {
  let users = generate_users(50)
  let assert True = list.length(users) == 50
}

pub fn generate_users_have_sequential_ids_test() {
  let users = generate_users(10)
  let assert [first, ..] = users
  let assert Ok(last) = list.last(users)

  let assert True = first.id == 1
  let assert True = last.id == 10
}

pub fn generate_users_have_valid_data_test() {
  let users = generate_users(5)
  let assert [user, ..] = users

  // Should have non-empty name and email
  let assert True = user.name != ""
  let assert True = user.email != ""
  let assert True = string.contains(user.email, "@")
}

// Test pagination

pub fn paginate_returns_first_page_test() {
  let users = generate_users(25)
  let page_1 = paginate(users, 1, 10)

  let assert True = list.length(page_1) == 10

  let assert [first, ..] = page_1
  let assert True = first.id == 1
}

pub fn paginate_returns_second_page_test() {
  let users = generate_users(25)
  let page_2 = paginate(users, 2, 10)

  let assert True = list.length(page_2) == 10

  let assert [first, ..] = page_2
  let assert True = first.id == 11
}

pub fn paginate_returns_partial_last_page_test() {
  let users = generate_users(25)
  let page_3 = paginate(users, 3, 10)

  // Only 5 users left on page 3 (25 total, 10 per page)
  let assert True = list.length(page_3) == 5

  let assert [first, ..] = page_3
  let assert True = first.id == 21
}

pub fn paginate_returns_empty_for_page_beyond_end_test() {
  let users = generate_users(25)
  let page_4 = paginate(users, 4, 10)

  let assert True = list.is_empty(page_4)
}

pub fn paginate_returns_empty_for_page_zero_test() {
  let users = generate_users(25)
  let page_0 = paginate(users, 0, 10)

  let assert True = list.is_empty(page_0)
}
