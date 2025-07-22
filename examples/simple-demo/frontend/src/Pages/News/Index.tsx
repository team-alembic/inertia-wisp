import React, { useState, useEffect, useRef, useCallback } from "react";
import { Head, Link, router } from "@inertiajs/react";
import { NewsFeedProps } from "../../types";
import ArticleCard from "../../components/ArticleCard";

export default function Index({ news_feed }: NewsFeedProps) {
  const { articles, meta, has_more, total_unread, current_category } =
    news_feed;

  // Container state for infinite scroll
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const sentinelRef = useRef<HTMLDivElement>(null);
  const loadingRef = useRef(false);

  // Handle infinite scroll loading
  const loadMoreArticles = useCallback(() => {
    if (loadingRef.current || !has_more || isLoadingMore) {
      return;
    }

    loadingRef.current = true;
    setIsLoadingMore(true);
    setError(null);

    const nextPage = meta.current_page + 1;
    const url = current_category
      ? `/news?page=${nextPage}&category=${current_category}`
      : `/news?page=${nextPage}`;

    router.get(
      url,
      {},
      {
        preserveState: true,
        only: ["news_feed"],
        onSuccess: () => {
          loadingRef.current = false;
          setIsLoadingMore(false);
        },
        onError: (errors) => {
          loadingRef.current = false;
          setIsLoadingMore(false);
          setError("Failed to load more articles. Please try again.");
          console.error("Error loading more articles:", errors);
        },
      },
    );
  }, [has_more, meta.current_page, current_category, isLoadingMore]);

  // Intersection Observer for infinite scroll
  useEffect(() => {
    const sentinel = sentinelRef.current;
    if (!sentinel) return;

    const observer = new IntersectionObserver(
      (entries) => {
        const [entry] = entries;
        if (entry.isIntersecting) {
          loadMoreArticles();
        }
      },
      {
        rootMargin: "100px", // Start loading 100px before reaching the bottom
      },
    );

    observer.observe(sentinel);

    return () => {
      observer.disconnect();
    };
  }, [loadMoreArticles]);

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
              <p className="stat-number">
                {meta.current_page} of {meta.last_page}
              </p>
              <small>Showing {articles.length} articles</small>
            </div>
          </div>
        </section>

        {/* Category Filter Info */}
        {current_category && current_category !== "" && (
          <section className="section">
            <div className="filter-info">
              <p>
                Showing articles in category:{" "}
                <strong>{current_category}</strong>
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
            <>
              <div className="articles-list">
                {articles.map((article) => (
                  <ArticleCard
                    key={article.article.id}
                    article={article}
                    onClick={handleArticleClick}
                  />
                ))}
              </div>

              {/* Infinite Scroll Sentinel */}
              {has_more && (
                <div ref={sentinelRef} className="scroll-sentinel">
                  {isLoadingMore && (
                    <div className="infinite-scroll-loader">
                      <div className="loading-spinner"></div>
                      <p>Loading more articles...</p>
                    </div>
                  )}
                  {error && (
                    <div className="infinite-scroll-error">
                      <p>{error}</p>
                      <button
                        onClick={loadMoreArticles}
                        className="action-button secondary"
                        disabled={isLoadingMore}
                      >
                        Try Again
                      </button>
                    </div>
                  )}
                </div>
              )}
            </>
          )}
        </section>

        {/* Status Info */}
        {articles.length > 0 && (
          <section className="section pagination-section">
            <div className="pagination-info">
              <p>
                Showing {articles.length} of {meta.total_count} articles
                {has_more && " • Scroll down for more"}
              </p>
              {!has_more && meta.total_count > articles.length && (
                <p className="pagination-note">
                  <strong>All articles loaded!</strong> You've reached the end
                  of the feed.
                </p>
              )}
            </div>
          </section>
        )}

        {/* API Demo Info */}
        <section className="section api-demo-section">
          <h2 className="section-title">Infinite Scroll Container</h2>
          <div className="api-demo-content">
            <p>
              This page demonstrates <strong>infinite scroll container</strong>{" "}
              functionality:
            </p>
            <ul>
              <li>
                <strong>MergeProp Integration:</strong> New articles
                automatically merge with existing feed
              </li>
              <li>
                <strong>Scroll Detection:</strong> Loads more content when
                approaching bottom of page
              </li>
              <li>
                <strong>Error Handling:</strong> Graceful handling of network
                errors with retry
              </li>
              <li>
                <strong>Loading States:</strong> Visual feedback during content
                loading
              </li>
            </ul>
            <p>
              <strong>How it works:</strong> Scroll down through the articles
              and watch as new content loads automatically. The container
              manages scroll position, loading states, and error handling.
            </p>
            <p>
              Try scrolling to see infinite scroll in action, or click article
              titles to mark them as read.
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
