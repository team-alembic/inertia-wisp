import React from "react";
import { Head, Link } from "@inertiajs/react";
import { NewsFeedProps } from "../../types";
import ArticleCard from "../../components/ArticleCard";

export default function Index({ news_feed }: NewsFeedProps) {
  const { articles, meta, has_more, total_unread, current_category } = news_feed;

  const handleArticleClick = (articleId: number) => {
    // Optional: Add analytics tracking here
    console.log(`Article ${articleId} clicked`);
  };

  return (
    <>
      <Head title="News Feed" />

      <div className="container">
        {/* Header */}
        <header className="header">
          <h1>News Feed</h1>
          <p>Stay updated with the latest articles across all categories</p>
        </header>

        {/* Navigation */}
        <nav className="nav-section">
          <Link href="/" className="nav-link">
            ← Back to Home
          </Link>
          <Link href="/dashboard" className="nav-link">
            📊 Dashboard
          </Link>
        </nav>

        {/* Stats Section */}
        <section className="section stats-section">
          <h2 className="section-title">Feed Statistics</h2>
          <div className="stats-grid">
            <div className="stat-card">
              <h3>Total Articles</h3>
              <p className="stat-number">{meta.total_count}</p>
              <small>Available in all categories</small>
            </div>
            <div className="stat-card">
              <h3>Unread Articles</h3>
              <p className="stat-number">{total_unread}</p>
              <small>Articles you haven't read yet</small>
            </div>
            <div className="stat-card">
              <h3>Current Page</h3>
              <p className="stat-number">{meta.current_page} of {meta.last_page}</p>
              <small>Showing {articles.length} articles</small>
            </div>
          </div>
        </section>

        {/* Category Filter Info */}
        {current_category && current_category !== "" && (
          <section className="section">
            <div className="filter-info">
              <p>
                Showing articles in category: <strong>{current_category}</strong>
                <Link href="/news" className="clear-filter">
                  Clear filter
                </Link>
              </p>
            </div>
          </section>
        )}

        {/* Articles List */}
        <section className="section">
          <h2 className="section-title">
            Articles {current_category ? `(${current_category})` : ""}
          </h2>

          {articles.length === 0 ? (
            <div className="empty-state">
              <p>No articles found.</p>
              {current_category ? (
                <p>Try a different category or clear the filter.</p>
              ) : (
                <p>Check back later for new content.</p>
              )}
            </div>
          ) : (
            <div className="articles-list">
              {articles.map((article) => (
                <ArticleCard
                  key={article.article.id}
                  article={article}
                  onClick={handleArticleClick}
                />
              ))}
            </div>
          )}
        </section>

        {/* Pagination Info */}
        {articles.length > 0 && (
          <section className="section pagination-section">
            <div className="pagination-info">
              <p>
                Showing {articles.length} of {meta.total_count} articles
                {has_more && " • More articles available"}
              </p>
              {has_more && (
                <p className="pagination-note">
                  <strong>Note:</strong> Infinite scroll will be implemented in the next task.
                  For now, you can manually navigate to page {meta.current_page + 1} by adding
                  <code>?page={meta.current_page + 1}</code> to the URL.
                </p>
              )}
            </div>
          </section>
        )}

        {/* API Demo Info */}
        <section className="section api-demo-section">
          <h2 className="section-title">MergeProp Demonstration</h2>
          <div className="api-demo-content">
            <p>
              This page demonstrates <strong>MergeProp</strong> usage for infinite scroll:
            </p>
            <ul>
              <li>
                <strong>Articles List:</strong> Uses MergeProp to merge new articles with existing ones
              </li>
              <li>
                <strong>Pagination Meta:</strong> Updates with each new page load
              </li>
              <li>
                <strong>Read Status:</strong> Per-user tracking of read/unread articles
              </li>
            </ul>
            <p>
              <strong>Current Implementation:</strong> Basic page display with pagination support.
              Infinite scroll functionality will be added in the next implementation task.
            </p>
            <p>
              Try clicking on article titles to mark them as read, then return to see
              the visual changes in the read/unread status.
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
