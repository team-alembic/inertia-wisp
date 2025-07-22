//// Tests for news handlers.
////
//// This module contains integration tests for the news feed and individual article handlers.
//// Tests verify proper component rendering, prop handling, and database integration.

import data/articles

import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/result
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

/// Test news feed handler includes available categories
pub fn news_feed_handler_includes_available_categories_test() {
  let assert Ok(db) = setup_test_news_database()
  let req = testing.inertia_request()
  let response = news.news_feed(req, db)

  // Should include available_categories prop with all 5 categories
  let categories_decoder = decode.list(decode.string)
  let assert Ok(categories) =
    testing.prop(response, "available_categories", categories_decoder)

  assert list.length(categories) == 5
  assert list.contains(categories, "technology")
  assert list.contains(categories, "business")
  assert list.contains(categories, "science")
  assert list.contains(categories, "sports")
  assert list.contains(categories, "entertainment")
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

/// Test news feed container handles empty results gracefully
pub fn news_feed_container_handles_empty_results_test() {
  let assert Ok(db) = setup_test_news_database()

  // Request with category that has no articles
  let req = testing.inertia_request_to("/news?category=nonexistent")
  let response = news.news_feed(req, db)

  // Should still return valid component and props
  assert testing.component(response) == Ok("News/Index")
  assert response.status == 200

  // Should have empty articles array but valid metadata
  let articles_decoder = decode.at(["articles"], decode.list(decode.dynamic))
  let total_count_decoder = decode.at(["meta", "total_count"], decode.int)
  let has_more_decoder = decode.at(["has_more"], decode.bool)

  let assert Ok(articles) = testing.prop(response, "news_feed", articles_decoder)
  assert articles == []
  assert testing.prop(response, "news_feed", total_count_decoder) == Ok(0)
  assert testing.prop(response, "news_feed", has_more_decoder) == Ok(False)
}

/// Test news feed container handles pagination with exactly 25 articles
pub fn news_feed_container_handles_pagination_with_25_articles_test() {
  let assert Ok(db) = setup_test_database_with_exact_articles(25)

  // Test page 1 - should show 20 articles with more available
  let req = testing.inertia_request_to("/news?page=1&per_page=20")
  let response = news.news_feed(req, db)

  assert testing.component(response) == Ok("News/Index")
  assert response.status == 200

  let current_page_decoder = decode.at(["meta", "current_page"], decode.int)
  let per_page_decoder = decode.at(["meta", "per_page"], decode.int)
  let total_count_decoder = decode.at(["meta", "total_count"], decode.int)
  let last_page_decoder = decode.at(["meta", "last_page"], decode.int)
  let has_more_decoder = decode.at(["has_more"], decode.bool)

  // Should have exact pagination values for 25 articles (2 pages)
  assert testing.prop(response, "news_feed", current_page_decoder) == Ok(1)
  assert testing.prop(response, "news_feed", per_page_decoder) == Ok(20)
  assert testing.prop(response, "news_feed", total_count_decoder) == Ok(25)
  assert testing.prop(response, "news_feed", last_page_decoder) == Ok(2)
  assert testing.prop(response, "news_feed", has_more_decoder) == Ok(True)
}

/// Test news feed container handles pagination with exactly 15 articles
pub fn news_feed_container_handles_pagination_with_15_articles_test() {
  let assert Ok(db) = setup_test_database_with_exact_articles(15)

  // Test page 1 - should show all 15 articles with no more available
  let req = testing.inertia_request_to("/news?page=1&per_page=20")
  let response = news.news_feed(req, db)

  assert testing.component(response) == Ok("News/Index")
  assert response.status == 200

  let current_page_decoder = decode.at(["meta", "current_page"], decode.int)
  let total_count_decoder = decode.at(["meta", "total_count"], decode.int)
  let last_page_decoder = decode.at(["meta", "last_page"], decode.int)
  let has_more_decoder = decode.at(["has_more"], decode.bool)

  // Should have exact pagination values for 15 articles (1 page)
  assert testing.prop(response, "news_feed", current_page_decoder) == Ok(1)
  assert testing.prop(response, "news_feed", total_count_decoder) == Ok(15)
  assert testing.prop(response, "news_feed", last_page_decoder) == Ok(1)
  assert testing.prop(response, "news_feed", has_more_decoder) == Ok(False)
}

/// Test simple article insertion works
pub fn simple_article_insertion_works_test() {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = articles.create_articles_table(db)
  let assert Ok(_) = articles.create_article_reads_table(db)

  // Insert one article manually
  let sql = "INSERT INTO articles (title, summary, author, published_at, category, read_time, image_url) VALUES ('Test', 'Test Summary', 'Test Author', '2024-01-15T10:30:00Z', 'technology', 5, 'https://example.com/test.jpg')"
  let assert Ok(_) = sqlight.exec(sql, db)

  // Check if it was inserted
  let count_sql = "SELECT COUNT(*) FROM articles"
  let decoder = decode.at([0], decode.int)
  let assert Ok(rows) = sqlight.query(count_sql, on: db, with: [], expecting: decoder)
  let assert [count] = rows
  assert count == 1
}

/// Test news feed container provides proper infinite scroll coordination data
pub fn news_feed_container_provides_scroll_coordination_data_test() {
  let assert Ok(db) = setup_test_news_database()
  let req = testing.inertia_request()
  let response = news.news_feed(req, db)

  // Container backend should provide all data needed for frontend infinite scroll coordination
  let has_more_decoder = decode.at(["has_more"], decode.bool)
  let current_page_decoder = decode.at(["meta", "current_page"], decode.int)
  let per_page_decoder = decode.at(["meta", "per_page"], decode.int)

  // These props enable frontend container to manage infinite scroll state
  assert testing.prop(response, "news_feed", has_more_decoder) |> result.is_ok
  assert testing.prop(response, "news_feed", current_page_decoder) |> result.is_ok
  assert testing.prop(response, "news_feed", per_page_decoder) |> result.is_ok
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
  // Sample data initialization - errors will be caught by individual tests
  let _ = articles.init_sample_data(db)
  Ok(db)
}

/// Create test database with exact number of articles for deterministic testing
fn setup_test_database_with_exact_articles(count: Int) -> Result(sqlight.Connection, sqlight.Error) {
  let assert Ok(db) = sqlight.open(":memory:")
  let assert Ok(_) = articles.create_articles_table(db)
  let assert Ok(_) = articles.create_article_reads_table(db)

  // Insert exact number of test articles
  let assert Ok(_) = insert_test_articles(db, count)
  Ok(db)
}

/// Insert exactly N test articles into database
fn insert_test_articles(db: sqlight.Connection, count: Int) -> Result(Nil, sqlight.Error) {
  case count {
    15 -> {
      let sql =
        "
        INSERT INTO articles (title, summary, author, published_at, category, read_time, image_url) VALUES
        ('Test Article 1', 'Test Summary 1', 'Test Author 1', '2024-01-15T10:30:00Z', 'technology', 5, 'https://example.com/image1.jpg'),
        ('Test Article 2', 'Test Summary 2', 'Test Author 2', '2024-01-15T09:30:00Z', 'technology', 4, 'https://example.com/image2.jpg'),
        ('Test Article 3', 'Test Summary 3', 'Test Author 3', '2024-01-15T08:30:00Z', 'technology', 6, 'https://example.com/image3.jpg'),
        ('Test Article 4', 'Test Summary 4', 'Test Author 4', '2024-01-15T07:30:00Z', 'technology', 3, 'https://example.com/image4.jpg'),
        ('Test Article 5', 'Test Summary 5', 'Test Author 5', '2024-01-15T06:30:00Z', 'technology', 7, 'https://example.com/image5.jpg'),
        ('Test Article 6', 'Test Summary 6', 'Test Author 6', '2024-01-15T05:30:00Z', 'technology', 5, 'https://example.com/image6.jpg'),
        ('Test Article 7', 'Test Summary 7', 'Test Author 7', '2024-01-15T04:30:00Z', 'technology', 4, 'https://example.com/image7.jpg'),
        ('Test Article 8', 'Test Summary 8', 'Test Author 8', '2024-01-15T03:30:00Z', 'technology', 6, 'https://example.com/image8.jpg'),
        ('Test Article 9', 'Test Summary 9', 'Test Author 9', '2024-01-15T02:30:00Z', 'technology', 3, 'https://example.com/image9.jpg'),
        ('Test Article 10', 'Test Summary 10', 'Test Author 10', '2024-01-15T01:30:00Z', 'technology', 7, 'https://example.com/image10.jpg'),
        ('Test Article 11', 'Test Summary 11', 'Test Author 11', '2024-01-14T23:30:00Z', 'technology', 5, 'https://example.com/image11.jpg'),
        ('Test Article 12', 'Test Summary 12', 'Test Author 12', '2024-01-14T22:30:00Z', 'technology', 4, 'https://example.com/image12.jpg'),
        ('Test Article 13', 'Test Summary 13', 'Test Author 13', '2024-01-14T21:30:00Z', 'technology', 6, 'https://example.com/image13.jpg'),
        ('Test Article 14', 'Test Summary 14', 'Test Author 14', '2024-01-14T20:30:00Z', 'technology', 3, 'https://example.com/image14.jpg'),
        ('Test Article 15', 'Test Summary 15', 'Test Author 15', '2024-01-14T19:30:00Z', 'technology', 7, 'https://example.com/image15.jpg')
        "

      sqlight.exec(sql, db)
    }
    25 -> {
      let sql =
        "
        INSERT INTO articles (title, summary, author, published_at, category, read_time, image_url) VALUES
        ('Test Article 1', 'Test Summary 1', 'Test Author 1', '2024-01-15T10:30:00Z', 'technology', 5, 'https://example.com/image1.jpg'),
        ('Test Article 2', 'Test Summary 2', 'Test Author 2', '2024-01-15T09:30:00Z', 'technology', 4, 'https://example.com/image2.jpg'),
        ('Test Article 3', 'Test Summary 3', 'Test Author 3', '2024-01-15T08:30:00Z', 'technology', 6, 'https://example.com/image3.jpg'),
        ('Test Article 4', 'Test Summary 4', 'Test Author 4', '2024-01-15T07:30:00Z', 'technology', 3, 'https://example.com/image4.jpg'),
        ('Test Article 5', 'Test Summary 5', 'Test Author 5', '2024-01-15T06:30:00Z', 'technology', 7, 'https://example.com/image5.jpg'),
        ('Test Article 6', 'Test Summary 6', 'Test Author 6', '2024-01-15T05:30:00Z', 'technology', 5, 'https://example.com/image6.jpg'),
        ('Test Article 7', 'Test Summary 7', 'Test Author 7', '2024-01-15T04:30:00Z', 'technology', 4, 'https://example.com/image7.jpg'),
        ('Test Article 8', 'Test Summary 8', 'Test Author 8', '2024-01-15T03:30:00Z', 'technology', 6, 'https://example.com/image8.jpg'),
        ('Test Article 9', 'Test Summary 9', 'Test Author 9', '2024-01-15T02:30:00Z', 'technology', 3, 'https://example.com/image9.jpg'),
        ('Test Article 10', 'Test Summary 10', 'Test Author 10', '2024-01-15T01:30:00Z', 'technology', 7, 'https://example.com/image10.jpg'),
        ('Test Article 11', 'Test Summary 11', 'Test Author 11', '2024-01-14T23:30:00Z', 'technology', 5, 'https://example.com/image11.jpg'),
        ('Test Article 12', 'Test Summary 12', 'Test Author 12', '2024-01-14T22:30:00Z', 'technology', 4, 'https://example.com/image12.jpg'),
        ('Test Article 13', 'Test Summary 13', 'Test Author 13', '2024-01-14T21:30:00Z', 'technology', 6, 'https://example.com/image13.jpg'),
        ('Test Article 14', 'Test Summary 14', 'Test Author 14', '2024-01-14T20:30:00Z', 'technology', 3, 'https://example.com/image14.jpg'),
        ('Test Article 15', 'Test Summary 15', 'Test Author 15', '2024-01-14T19:30:00Z', 'technology', 7, 'https://example.com/image15.jpg'),
        ('Test Article 16', 'Test Summary 16', 'Test Author 16', '2024-01-14T18:30:00Z', 'technology', 5, 'https://example.com/image16.jpg'),
        ('Test Article 17', 'Test Summary 17', 'Test Author 17', '2024-01-14T17:30:00Z', 'technology', 4, 'https://example.com/image17.jpg'),
        ('Test Article 18', 'Test Summary 18', 'Test Author 18', '2024-01-14T16:30:00Z', 'technology', 6, 'https://example.com/image18.jpg'),
        ('Test Article 19', 'Test Summary 19', 'Test Author 19', '2024-01-14T15:30:00Z', 'technology', 3, 'https://example.com/image19.jpg'),
        ('Test Article 20', 'Test Summary 20', 'Test Author 20', '2024-01-14T14:30:00Z', 'technology', 7, 'https://example.com/image20.jpg'),
        ('Test Article 21', 'Test Summary 21', 'Test Author 21', '2024-01-14T13:30:00Z', 'technology', 5, 'https://example.com/image21.jpg'),
        ('Test Article 22', 'Test Summary 22', 'Test Author 22', '2024-01-14T12:30:00Z', 'technology', 4, 'https://example.com/image22.jpg'),
        ('Test Article 23', 'Test Summary 23', 'Test Author 23', '2024-01-14T11:30:00Z', 'technology', 6, 'https://example.com/image23.jpg'),
        ('Test Article 24', 'Test Summary 24', 'Test Author 24', '2024-01-14T10:30:00Z', 'technology', 3, 'https://example.com/image24.jpg'),
        ('Test Article 25', 'Test Summary 25', 'Test Author 25', '2024-01-14T09:30:00Z', 'technology', 7, 'https://example.com/image25.jpg')
        "

      sqlight.exec(sql, db)
    }
    _ -> Error(sqlight.SqlightError(
      code: sqlight.GenericError,
      message: "Unsupported article count for test: " <> int.to_string(count),
      offset: -1,
    ))
  }
}
