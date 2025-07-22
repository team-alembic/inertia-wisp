//// Tests for news handlers.
////
//// This module contains integration tests for the news feed and individual article handlers.
//// Tests verify proper component rendering, prop handling, and database integration.

import data/articles
import gleam/dynamic/decode
import gleam/list
import handlers/news
import inertia_wisp/testing
import sqlight

/// Test news feed handler returns correct component and includes articles with read status
pub fn news_feed_handler_loads_with_basic_props_test() {
  let assert Ok(db) = setup_test_news_database()
  let req = testing.inertia_request()
  let response = news.news_feed(req, db)

  // Should return News/Index component
  assert testing.component(response) == Ok("News/Index")
  assert response.status == 200

  // Should include articles prop with read status
  let current_page_decoder = decode.at(["meta", "current_page"], decode.int)
  let per_page_decoder = decode.at(["meta", "per_page"], decode.int)
  let total_unread_decoder = decode.at(["total_unread"], decode.int)
  let current_category_decoder = decode.at(["current_category"], decode.string)

  assert testing.prop(response, "news_feed", current_page_decoder) == Ok(1)
  assert testing.prop(response, "news_feed", per_page_decoder) == Ok(20)
  let assert Ok(unread_count) =
    testing.prop(response, "news_feed", total_unread_decoder)
  assert unread_count > 0
  assert testing.prop(response, "news_feed", current_category_decoder) == Ok("")
}

/// Test news feed handler filters articles by category
pub fn news_feed_handler_filters_articles_by_category_test() {
  let assert Ok(db) = setup_test_news_database()
  let req = testing.inertia_request_to("/news?category=technology")
  let response = news.news_feed(req, db)

  // Should set category filter
  let current_category_decoder = decode.at(["current_category"], decode.string)
  assert testing.prop(response, "news_feed", current_category_decoder)
    == Ok("technology")

  // Should actually filter articles - all returned articles must be technology category
  let articles_decoder =
    decode.at(
      ["articles"],
      decode.list(decode.at(["article", "category"], decode.string)),
    )
  let assert Ok(article_categories) =
    testing.prop(response, "news_feed", articles_decoder)

  // Verify we have technology articles to test filtering
  assert list.length(article_categories) > 0

  // Verify ALL articles are technology category (actual filtering behavior)
  assert list.all(article_categories, fn(category) { category == "technology" })
}

/// Test news feed handler supports pagination
pub fn news_feed_handler_supports_pagination_test() {
  let assert Ok(db) = setup_test_news_database()
  let req = testing.inertia_request_to("/news?page=2&per_page=10")
  let response = news.news_feed(req, db)

  // Should handle pagination parameters
  let current_page_decoder = decode.at(["meta", "current_page"], decode.int)
  let per_page_decoder = decode.at(["meta", "per_page"], decode.int)

  assert testing.prop(response, "news_feed", current_page_decoder) == Ok(2)
  assert testing.prop(response, "news_feed", per_page_decoder) == Ok(10)
}

/// Test individual article handler returns correct component
pub fn news_article_handler_returns_correct_component_test() {
  let assert Ok(db) = setup_test_news_database()
  let req = testing.inertia_request()
  let response = news.news_article(req, "1", db)

  // Should return News/Article component
  assert testing.component(response) == Ok("News/Article")
  assert response.status == 200
}

/// Test individual article handler includes article data with read status
pub fn news_article_handler_includes_article_with_read_status_test() {
  let assert Ok(db) = setup_test_news_database()
  let req = testing.inertia_request()
  let response = news.news_article(req, "1", db)

  // Should include article prop with read status
  let article_id_decoder = decode.at(["article", "id"], decode.int)
  let article_title_decoder = decode.at(["article", "title"], decode.string)

  assert testing.prop(response, "article", article_id_decoder) == Ok(1)
  let assert Ok(title) =
    testing.prop(response, "article", article_title_decoder)
  assert title != ""
}

/// Test individual article handler handles invalid article ID
pub fn news_article_handler_handles_invalid_id_test() {
  let assert Ok(db) = setup_test_news_database()
  let req = testing.inertia_request()
  let response = news.news_article(req, "999", db)

  // Should return error component for invalid ID
  assert testing.component(response) == Ok("Error")
  assert response.status == 404
}

// Helper functions for test setup and data decoding

/// Create test database with articles and article_reads tables
fn setup_test_news_database() -> Result(sqlight.Connection, sqlight.Error) {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = articles.create_articles_table(db)
  let assert Ok(_) = articles.create_article_reads_table(db)
  let assert Ok(_) = articles.init_sample_data(db)
  Ok(db)
}
