import data/articles

import gleam/json
import gleam/list
import gleam/option

import gleam/string
import inertia_wisp/internal/types
import news/props

// Test data for prop factories
const test_article = articles.Article(
  id: 1,
  title: "Test Article",
  summary: "This is a test article summary",
  author: "Test Author",
  published_at: "2024-01-15T10:30:00Z",
  category: articles.Technology,
  read_time: 5,
  image_url: "https://example.com/image.jpg",
)

const test_article_with_read_status = articles.ArticleWithReadStatus(
  article: test_article,
  is_read: False,
  read_at: "",
)

const test_pagination_meta = articles.PaginationMeta(
  current_page: 1,
  per_page: 20,
  total_count: 65,
  last_page: 4,
)

const test_news_feed = articles.NewsFeed(
  articles: [test_article_with_read_status],
  meta: test_pagination_meta,
  has_more: True,
  total_unread: 64,
  current_category: "technology",
)

pub fn news_feed_factory_test() {
  let prop = props.news_feed(test_news_feed)

  // Verify it creates a MergeProp wrapping a DefaultProp
  let assert types.MergeProp(inner_prop, match_on, deep) = prop
  assert match_on == option.None
  assert deep == True
  let assert types.DefaultProp(key, props.NewsFeed(feed)) = inner_prop
  assert key == "news_feed"
  assert feed.meta.current_page == 1
  assert feed.total_unread == 64
  assert feed.current_category == "technology"
}

pub fn article_list_factory_test() {
  let articles_fn = fn() { Ok([test_article_with_read_status]) }
  let prop = props.article_list(articles_fn)

  // Verify it creates an OptionalProp with correct key and callable function
  let assert types.OptionalProp(key, compute_fn) = prop
  assert key == "articles"
  let assert Ok(props.ArticleList(article_list)) = compute_fn()
  assert list.length(article_list) == 1
  let assert [article] = article_list
  assert article.article.title == "Test Article"
  assert article.is_read == False
}

pub fn pagination_meta_factory_test() {
  let prop = props.pagination_meta(test_pagination_meta)

  // Verify it creates a DefaultProp with correct key and data
  let assert types.DefaultProp(key, props.PaginationMeta(meta)) = prop
  assert key == "pagination"
  assert meta.current_page == 1
  assert meta.per_page == 20
  assert meta.total_count == 65
  assert meta.last_page == 4
}

pub fn article_data_factory_test() {
  let prop = props.article_data(test_article_with_read_status)

  // Verify it creates a DefaultProp with correct key and data
  let assert types.DefaultProp(key, props.ArticleData(article)) = prop
  assert key == "article"
  assert article.article.id == 1
  assert article.article.title == "Test Article"
  assert article.is_read == False
}

pub fn category_filter_factory_test() {
  let prop = props.category_filter("technology")

  // Verify it creates a DefaultProp with correct key and data
  let assert types.DefaultProp(key, props.CategoryFilter(category)) = prop
  assert key == "category"
  assert category == "technology"
}

pub fn unread_count_factory_test() {
  let count_fn = fn() { Ok(42) }
  let prop = props.unread_count(count_fn)

  // Verify it creates a DeferProp with correct key and callable function
  let assert types.DeferProp(key, partial_key, compute_fn) = prop
  assert key == "unread_count"
  assert partial_key == option.None
  let assert Ok(props.UnreadCount(count)) = compute_fn()
  assert count == 42
}

pub fn news_prop_to_json_article_test() {
  let json_result =
    props.news_prop_to_json(props.ArticleData(test_article_with_read_status))
  let json_string = json.to_string(json_result)

  // Verify JSON contains all required article fields
  assert string.contains(json_string, "\"article\"")
  assert string.contains(json_string, "\"is_read\":false")
  assert string.contains(json_string, "\"read_at\":\"\"")
  assert string.contains(json_string, "\"id\":1")
  assert string.contains(json_string, "\"title\":\"Test Article\"")
  assert string.contains(json_string, "\"category\":\"technology\"")
}

pub fn news_prop_to_json_news_feed_test() {
  let json_result = props.news_prop_to_json(props.NewsFeed(test_news_feed))
  let json_string = json.to_string(json_result)

  // Verify JSON contains all required news feed fields
  assert string.contains(json_string, "\"articles\":[")
  assert string.contains(json_string, "\"meta\":")
  assert string.contains(json_string, "\"has_more\":true")
  assert string.contains(json_string, "\"total_unread\":64")
  assert string.contains(json_string, "\"current_category\":\"technology\"")
  assert string.contains(json_string, "\"current_page\":1")
  assert string.contains(json_string, "\"total_count\":65")
}

pub fn available_categories_factory_test() {
  let categories = [articles.Technology, articles.Business, articles.Science]
  let prop = props.available_categories(categories)

  // Verify it creates a DefaultProp with correct key and data
  let assert types.DefaultProp(key, props.AvailableCategories(returned_categories)) = prop
  assert key == "available_categories"
  assert list.length(returned_categories) == 3
  assert list.contains(returned_categories, articles.Technology)
  assert list.contains(returned_categories, articles.Business)
  assert list.contains(returned_categories, articles.Science)
}

pub fn news_prop_to_json_available_categories_test() {
  let categories = [articles.Technology, articles.Business, articles.Science]
  let json_result = props.news_prop_to_json(props.AvailableCategories(categories))
  let json_string = json.to_string(json_result)

  // Verify JSON contains all categories as array
  assert string.contains(json_string, "[")
  assert string.contains(json_string, "\"technology\"")
  assert string.contains(json_string, "\"business\"")
  assert string.contains(json_string, "\"science\"")
}

pub fn get_all_categories_returns_all_categories_test() {
  let categories = articles.get_all_categories()

  // Verify all 5 categories are returned
  assert list.length(categories) == 5
  assert list.contains(categories, articles.Technology)
  assert list.contains(categories, articles.Business)
  assert list.contains(categories, articles.Science)
  assert list.contains(categories, articles.Sports)
  assert list.contains(categories, articles.Entertainment)
}

pub fn news_prop_to_json_pagination_test() {
  let json_result =
    props.news_prop_to_json(props.PaginationMeta(test_pagination_meta))
  let json_string = json.to_string(json_result)

  // Verify JSON contains all required pagination fields
  assert string.contains(json_string, "\"current_page\":1")
  assert string.contains(json_string, "\"per_page\":20")
  assert string.contains(json_string, "\"total_count\":65")
  assert string.contains(json_string, "\"last_page\":4")
}
