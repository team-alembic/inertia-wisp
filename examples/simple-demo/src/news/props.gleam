//// News page prop types and factory functions.
////
//// This module defines the prop types and factory functions for news-related
//// components, following the patterns established in user_props.gleam.
//// Supports multi-user read tracking and different prop types (Default, Optional, Defer).

import data/articles
import gleam/dict
import gleam/json
import gleam/option
import gleam/result
import inertia_wisp/internal/types

/// Represents the different types of props that can be sent to news pages
pub type NewsProp {
  NewsFeed(articles.NewsFeed)
  ArticleList(List(articles.ArticleWithReadStatus))
  ArticleData(articles.ArticleWithReadStatus)
  PaginationMeta(articles.PaginationMeta)
  CategoryFilter(String)
  UnreadCount(Int)
  LoadingState(Bool)
}

// Factory functions for creating Prop(NewsProp) instances

/// Create a news feed prop (MergeProp for infinite scroll)
pub fn news_feed(feed: articles.NewsFeed) -> types.Prop(NewsProp) {
  types.MergeProp(
    prop: types.DefaultProp("news_feed", NewsFeed(feed)),
    match_on: option.None,
    deep: False,
  )
}

/// Create an article list prop (OptionalProp for expensive operations)
pub fn article_list(
  articles_fn: fn() ->
    Result(List(articles.ArticleWithReadStatus), dict.Dict(String, String)),
) -> types.Prop(NewsProp) {
  types.OptionalProp("articles", fn() { result.map(articles_fn(), ArticleList) })
}

/// Create pagination metadata prop (DefaultProp)
pub fn pagination_meta(meta: articles.PaginationMeta) -> types.Prop(NewsProp) {
  types.DefaultProp("pagination", PaginationMeta(meta))
}

/// Create a single article prop (DefaultProp)
pub fn article_data(
  article: articles.ArticleWithReadStatus,
) -> types.Prop(NewsProp) {
  types.DefaultProp("article", ArticleData(article))
}

/// Create a category filter prop (DefaultProp)
pub fn category_filter(category: String) -> types.Prop(NewsProp) {
  types.DefaultProp("category", CategoryFilter(category))
}

/// Create unread count prop (DeferProp for expensive calculation)
pub fn unread_count(
  count_fn: fn() -> Result(Int, dict.Dict(String, String)),
) -> types.Prop(NewsProp) {
  types.DeferProp(name: "unread_count", group: option.None, resolver: fn() {
    result.map(count_fn(), UnreadCount)
  })
}

/// Helper function to encode article category to JSON
fn encode_article_category(category: articles.ArticleCategory) -> json.Json {
  case category {
    articles.Technology -> json.string("technology")
    articles.Business -> json.string("business")
    articles.Science -> json.string("science")
    articles.Sports -> json.string("sports")
    articles.Entertainment -> json.string("entertainment")
  }
}

/// Helper function to encode a single article to JSON
fn encode_article(article: articles.Article) -> json.Json {
  json.object([
    #("id", json.int(article.id)),
    #("title", json.string(article.title)),
    #("summary", json.string(article.summary)),
    #("author", json.string(article.author)),
    #("published_at", json.string(article.published_at)),
    #("category", encode_article_category(article.category)),
    #("read_time", json.int(article.read_time)),
    #("image_url", json.string(article.image_url)),
  ])
}

/// Helper function to encode article with read status to JSON
fn encode_article_with_read_status(
  article: articles.ArticleWithReadStatus,
) -> json.Json {
  json.object([
    #("article", encode_article(article.article)),
    #("is_read", json.bool(article.is_read)),
    #("read_at", json.string(article.read_at)),
  ])
}

/// Helper function to encode article list to JSON
fn encode_article_list(
  articles: List(articles.ArticleWithReadStatus),
) -> json.Json {
  json.array(articles, encode_article_with_read_status)
}

/// Helper function to encode pagination metadata
fn encode_pagination_meta(meta: articles.PaginationMeta) -> json.Json {
  json.object([
    #("current_page", json.int(meta.current_page)),
    #("per_page", json.int(meta.per_page)),
    #("total_count", json.int(meta.total_count)),
    #("last_page", json.int(meta.last_page)),
  ])
}

/// Helper function to encode news feed to JSON
fn encode_news_feed(feed: articles.NewsFeed) -> json.Json {
  json.object([
    #("articles", encode_article_list(feed.articles)),
    #("meta", encode_pagination_meta(feed.meta)),
    #("has_more", json.bool(feed.has_more)),
    #("total_unread", json.int(feed.total_unread)),
    #("current_category", json.string(feed.current_category)),
  ])
}

/// Encode a NewsProp to JSON (for Response Builder API)
pub fn news_prop_to_json(prop: NewsProp) -> json.Json {
  case prop {
    NewsFeed(feed) -> encode_news_feed(feed)
    ArticleList(articles) -> encode_article_list(articles)
    ArticleData(article) -> encode_article_with_read_status(article)
    PaginationMeta(meta) -> encode_pagination_meta(meta)
    CategoryFilter(category) -> json.string(category)
    UnreadCount(count) -> json.int(count)
    LoadingState(is_loading) -> json.bool(is_loading)
  }
}
