import React from "react";
import { Head, Link } from "@inertiajs/react";
import { ArticleProps } from "../../types";

export default function Article({ article }: ArticleProps) {
  const { article: articleData, is_read, read_at } = article;

  const formatPublishedDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const formatReadTime = (minutes: number) => {
    return `${minutes} minute${minutes === 1 ? "" : "s"}`;
  };

  const getCategoryColor = (category: string) => {
    const colors = {
      technology: "bg-blue-100 text-blue-800",
      business: "bg-green-100 text-green-800",
      science: "bg-purple-100 text-purple-800",
      sports: "bg-red-100 text-red-800",
      entertainment: "bg-yellow-100 text-yellow-800",
    };
    return colors[category as keyof typeof colors] || "bg-gray-100 text-gray-800";
  };

  return (
    <>
      <Head title={articleData.title} />

      <div className="container">
        {/* Navigation */}
        <nav className="nav-section">
          <Link href="/news" className="nav-link">
            ← Back to News Feed
          </Link>
          <Link href="/" className="nav-link">
            🏠 Home
          </Link>
        </nav>

        {/* Article Header */}
        <header className="article-header">
          <div className="article-meta-top">
            <span className={`category-badge ${getCategoryColor(articleData.category)}`}>
              {articleData.category}
            </span>
            <span className="read-time-full">
              {formatReadTime(articleData.read_time)} read
            </span>
          </div>

          <h1 className="article-title-full">{articleData.title}</h1>

          <div className="article-author-info">
            <span className="author-name">By {articleData.author}</span>
            <span className="publish-date">
              Published {formatPublishedDate(articleData.published_at)}
            </span>
            {is_read && read_at && (
              <span className="read-status">
                ✓ Read on {new Date(read_at).toLocaleDateString()}
              </span>
            )}
          </div>
        </header>

        {/* Article Image */}
        {articleData.image_url && (
          <div className="article-image-full">
            <img
              src={articleData.image_url}
              alt={articleData.title}
              className="article-image-display"
            />
          </div>
        )}

        {/* Article Content */}
        <article className="article-body">
          <div className="article-summary-full">
            <p className="summary-text">{articleData.summary}</p>
          </div>

          <div className="article-content-full">
            <p>
              This is where the full article content would be displayed.
              In a real application, this would contain the complete article text,
              formatted with proper paragraphs, headings, and other rich content.
            </p>

            <p>
              The article "{articleData.title}" by {articleData.author} would
              contain detailed information about the topic. This demo shows
              how the article page integrates with the news feed and handles
              read status tracking.
            </p>

            <p>
              <strong>Demo Note:</strong> This is a placeholder for article content.
              In a production system, this would be populated from a content
              management system or database field containing the full article body.
            </p>
          </div>
        </article>

        {/* Article Footer */}
        <footer className="article-footer-full">
          <div className="article-actions">
            <Link href="/news" className="action-button primary">
              ← Back to News Feed
            </Link>
            <button
              onClick={() => window.print()}
              className="action-button secondary"
            >
              🖨️ Print Article
            </button>
          </div>

          <div className="article-stats">
            <p>Category: <strong>{articleData.category}</strong></p>
            <p>Reading time: <strong>{formatReadTime(articleData.read_time)}</strong></p>
            <p>Article ID: <strong>{articleData.id}</strong></p>
          </div>
        </footer>

        {/* Read Status Demo Info */}
        <section className="section api-demo-section">
          <h2 className="section-title">Read Status Tracking</h2>
          <div className="api-demo-content">
            <p>
              This page demonstrates <strong>automatic read tracking</strong>:
            </p>
            <ul>
              <li>
                <strong>Read Status:</strong> Article is automatically marked as read when viewed
              </li>
              <li>
                <strong>Per-User Tracking:</strong> Each user has independent read/unread status
              </li>
              <li>
                <strong>Timestamp Recording:</strong> Read time is recorded for analytics
              </li>
            </ul>
            <p>
              <strong>Current Status:</strong>
              {is_read ? (
                <span className="status-read">
                  ✓ This article is marked as read
                  {read_at && ` (read on ${new Date(read_at).toLocaleDateString()})`}
                </span>
              ) : (
                <span className="status-unread">
                  • This article will be marked as read when you visit this page
                </span>
              )}
            </p>
            <p>
              Return to the news feed to see how this article now appears
              with a "read" visual indicator.
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
