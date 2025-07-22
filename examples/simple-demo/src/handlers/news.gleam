//// News handlers for the simple demo application.
////
//// This module handles requests for the news feed and individual articles.
//// Demonstrates MergeProp for infinite scroll and category filtering functionality.

import data/articles
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/uri
import inertia_wisp/inertia
import news/props
import sqlight.{type Connection}
import wisp.{type Request, type Response}

/// Handle news feed requests (GET /news)
///
/// This demonstrates MergeProp for infinite scroll functionality:
/// 1. Parse pagination and filter parameters from request
/// 2. Load articles with user-specific read status
/// 3. Use MergeProp to enable infinite scroll merging
/// 4. Support category filtering
pub fn news_feed(req: Request, db: Connection) -> Response {
  // Get current user ID (hardcoded for now)
  let user_id = get_current_user_id(req)

  // Get pagination parameters
  let #(page, per_page) = get_pagination_params(req)

  // Get category filter
  let category = get_category_filter(req)


  // Load articles with pagination and user read status
  case articles.get_articles_paginated(db, user_id, page, per_page, category) {
    Ok(articles_list) -> {
      // Get total count for pagination
      let total_count = case articles.get_total_article_count(db, category) {
        Ok(count) -> count
        Error(_) -> 0
      }


      // Get unread count
      let total_unread = case articles.get_unread_count_for_user(db, user_id) {
        Ok(count) -> count
        Error(_) -> 0
      }

      // Calculate pagination metadata
      let last_page = case per_page {
        0 -> 1
        _ -> { total_count + per_page - 1 } / per_page
      }

      let meta =
        articles.PaginationMeta(
          current_page: page,
          per_page: per_page,
          total_count: total_count,
          last_page: last_page,
        )

      build_feed_response(req, articles_list, meta, category, total_unread)
    }
    Error(_) -> {
      // Database error loading articles - return Error component with 500 status
      req
      |> inertia.response_builder("Error")
      |> inertia.response(500)
    }
  }
}

/// Handle individual article requests (GET /news/article/:id)
///
/// This demonstrates basic article viewing:
/// 1. Parse article ID from request
/// 2. Load article with user read status
/// 3. Mark article as read for current user
/// 4. Return article data with related articles
pub fn news_article(req: Request, id: String, db: Connection) -> Response {
  use article_id <- parse_article_id_or_404(req, id)
  use article_with_read_status <- get_article_or_404(req, db, article_id)

  // Mark article as read for current user
  let user_id = get_current_user_id(req)
  let _ = articles.mark_article_read(db, user_id, article_id)

  build_article_response(req, article_with_read_status)
}

// Helper functions for parameter parsing and data processing

/// Extract pagination parameters from request query string
fn get_pagination_params(req: Request) -> #(Int, Int) {
  let page = case req.query {
    option.Some(query_string) ->
      {
        use params <- result.try(uri.parse_query(query_string))
        use page_str <- result.try(list.key_find(params, "page"))
        use page_num <- result.try(int.parse(page_str))
        case page_num > 0 {
          True -> Ok(page_num)
          False -> Error(Nil)
        }
      }
      |> result.unwrap(1)
    option.None -> 1
  }

  let per_page = case req.query {
    option.Some(query_string) ->
      {
        use params <- result.try(uri.parse_query(query_string))
        use per_page_str <- result.try(list.key_find(params, "per_page"))
        use per_page_num <- result.try(int.parse(per_page_str))
        case per_page_num > 0 && per_page_num <= 100 {
          True -> Ok(per_page_num)
          False -> Error(Nil)
        }
      }
      |> result.unwrap(20)
    option.None -> 20
  }
  #(page, per_page)
}

/// Extract category filter from request query string
fn get_category_filter(req: Request) -> String {
  case req.query {
    option.Some(query_string) ->
      {
        use params <- result.try(uri.parse_query(query_string))
        use category <- result.try(list.key_find(params, "category"))
        Ok(category)
      }
      |> result.unwrap("")
    option.None -> ""
  }
}

/// Get current user ID from request (placeholder for auth integration)
fn get_current_user_id(_req: Request) -> Int {
  // Demo user ID for now - in real app would extract from auth session
  42
}

/// Build news feed response with proper props
fn build_feed_response(
  req: Request,
  articles_list: List(articles.ArticleWithReadStatus),
  meta: articles.PaginationMeta,
  category: String,
  total_unread: Int,
) -> Response {
  let feed =
    articles.NewsFeed(
      articles: articles_list,
      meta: meta,
      has_more: meta.current_page < meta.last_page,
      total_unread: total_unread,
      current_category: category,
    )

  let available_categories = articles.get_all_categories()
  let props = [
    props.news_feed(feed),
    props.available_categories(available_categories),
  ]

  req
  |> inertia.response_builder("News/Index")
  |> inertia.props(props, props.news_prop_to_json)
  |> inertia.response(200)
}

/// Build individual article response with proper props
fn build_article_response(
  req: Request,
  article: articles.ArticleWithReadStatus,
) -> Response {
  let props = [props.article_data(article)]

  req
  |> inertia.response_builder("News/Article")
  |> inertia.props(props, props.news_prop_to_json)
  |> inertia.response(200)
}

/// Parse article ID or return 404 error
fn parse_article_id_or_404(
  req: Request,
  id: String,
  cont: fn(Int) -> Response,
) -> Response {
  case int.parse(id) {
    Ok(article_id) -> cont(article_id)
    Error(_) -> {
      req
      |> inertia.response_builder("Error")
      |> inertia.response(404)
    }
  }
}

/// Get article by ID or return 404 error
fn get_article_or_404(
  req: Request,
  db: Connection,
  article_id: Int,
  cont: fn(articles.ArticleWithReadStatus) -> Response,
) -> Response {
  let user_id = get_current_user_id(req)
  case articles.find_article_by_id(db, user_id, article_id) {
    Ok(article_with_read_status) -> cont(article_with_read_status)
    Error(_) -> {
      req
      |> inertia.response_builder("Error")
      |> inertia.response(404)
    }
  }
}
