import data/articles
import gleam/list
import sqlight

// Test user IDs for multi-user scenarios
const test_user_1 = 1

const test_user_2 = 2

pub fn get_articles_paginated_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = articles.create_articles_table(db)
  let assert Ok(_) = articles.create_article_reads_table(db)
  let assert Ok(_) = articles.init_sample_data(db)

  let assert Ok(page1_articles) =
    articles.get_articles_paginated(db, test_user_1, 1, 5, "all")
  assert list.length(page1_articles) == 5

  let assert Ok(tech_articles) =
    articles.get_articles_paginated(db, test_user_1, 1, 10, "technology")
  assert tech_articles != []

  sqlight.close(db)
}

pub fn get_total_article_count_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = articles.create_articles_table(db)
  let assert Ok(_) = articles.create_article_reads_table(db)
  let assert Ok(_) = articles.init_sample_data(db)

  let assert Ok(total_count) = articles.get_total_article_count(db, "all")
  assert total_count == 65

  let assert Ok(tech_count) = articles.get_total_article_count(db, "technology")
  assert tech_count > 0

  sqlight.close(db)
}

pub fn mark_article_read_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = articles.create_articles_table(db)
  let assert Ok(_) = articles.create_article_reads_table(db)
  let assert Ok(_) = articles.init_sample_data(db)

  let assert Ok(_) = articles.mark_article_read(db, test_user_1, 1)
  let assert Ok(article) = articles.find_article_by_id(db, test_user_1, 1)
  assert article.is_read == True

  sqlight.close(db)
}

pub fn find_article_by_id_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = articles.create_articles_table(db)
  let assert Ok(_) = articles.create_article_reads_table(db)
  let assert Ok(_) = articles.init_sample_data(db)

  let assert Ok(article) = articles.find_article_by_id(db, test_user_1, 1)
  assert article.article.id == 1
  assert article.article.title != ""
  assert article.is_read == False

  sqlight.close(db)
}

pub fn get_unread_count_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = articles.create_articles_table(db)
  let assert Ok(_) = articles.create_article_reads_table(db)
  let assert Ok(_) = articles.init_sample_data(db)

  let assert Ok(unread_count) =
    articles.get_unread_count_for_user(db, test_user_1)
  assert unread_count == 65

  let assert Ok(_) = articles.mark_article_read(db, test_user_1, 1)
  let assert Ok(unread_count_after) =
    articles.get_unread_count_for_user(db, test_user_1)
  assert unread_count_after == 64

  sqlight.close(db)
}

pub fn multi_user_read_tracking_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = articles.create_articles_table(db)
  let assert Ok(_) = articles.create_article_reads_table(db)
  let assert Ok(_) = articles.init_sample_data(db)

  // User 1 marks article 1 as read
  let assert Ok(_) = articles.mark_article_read(db, test_user_1, 1)

  // User 1 should see article 1 as read
  let assert Ok(article_user1) = articles.find_article_by_id(db, test_user_1, 1)
  assert article_user1.is_read == True

  // User 2 should see article 1 as unread
  let assert Ok(article_user2) = articles.find_article_by_id(db, test_user_2, 1)
  assert article_user2.is_read == False

  // Verify unread counts are independent
  let assert Ok(unread_user1) =
    articles.get_unread_count_for_user(db, test_user_1)
  let assert Ok(unread_user2) =
    articles.get_unread_count_for_user(db, test_user_2)
  assert unread_user1 == 64
  assert unread_user2 == 65

  sqlight.close(db)
}

pub fn get_user_read_status_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = articles.create_articles_table(db)
  let assert Ok(_) = articles.create_article_reads_table(db)
  let assert Ok(_) = articles.init_sample_data(db)

  // Initially, article should be unread
  let assert Ok(is_read_before) =
    articles.get_user_read_status(db, test_user_1, 1)
  assert is_read_before == False

  // Mark article as read
  let assert Ok(_) = articles.mark_article_read(db, test_user_1, 1)

  // Now article should be read
  let assert Ok(is_read_after) =
    articles.get_user_read_status(db, test_user_1, 1)
  assert is_read_after == True

  // Different user should still see it as unread
  let assert Ok(is_read_other_user) =
    articles.get_user_read_status(db, test_user_2, 1)
  assert is_read_other_user == False

  sqlight.close(db)
}
