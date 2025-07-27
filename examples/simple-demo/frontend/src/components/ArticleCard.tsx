import React from "react";
import { Link } from "@inertiajs/react";
import { ArticleWithReadStatus } from "../types";

interface ArticleCardProps {
  article: ArticleWithReadStatus;
  onClick?: (articleId: number) => void;
}

export default function ArticleCard({ article, onClick }: ArticleCardProps) {
  const { article: articleData, is_read, read_at } = article;

  const handleClick = () => {
    if (onClick) {
      onClick(articleData.id);
    }
  };

  const formatReadTime = (minutes: number) => {
    return `${minutes} min read`;
  };

  const formatPublishedDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  };

  const getCategoryColor = (category: string) => {
    const colors = {
      technology: "bg-blue-100 text-blue-800",
      business: "bg-green-100 text-green-800",
      science: "bg-purple-100 text-purple-800",
      sports: "bg-red-100 text-red-800",
      entertainment: "bg-yellow-100 text-yellow-800",
    };
    return (
      colors[category as keyof typeof colors] || "bg-gray-100 text-gray-800"
    );
  };

  return (
    <article
      className={`article-card ${is_read ? "read" : "unread"}`}
      onClick={handleClick}
    >
      {/* Article Image */}
      {articleData.image_url && (
        <div className="article-image-container">
          <img
            src={articleData.image_url}
            alt={articleData.title}
            className="article-image"
            loading="lazy"
          />
        </div>
      )}

      {/* Article Content */}
      <div className="article-content">
        {/* Category Badge */}
        <div className="article-meta">
          <span
            className={`category-badge ${getCategoryColor(articleData.category)}`}
          >
            {articleData.category}
          </span>
          <span className="read-time">
            {formatReadTime(articleData.read_time)}
          </span>
        </div>

        {/* Title */}
        <h3 className="article-title">
          <Link
            href={`/news/article/${articleData.id}`}
            onClick={() => {
              // Store current page context for back navigation
              const currentPage =
                new URLSearchParams(window.location.search).get("page") || "1";
              const currentCategory =
                new URLSearchParams(window.location.search).get("category") ||
                "";
              sessionStorage.setItem(
                "newsContext",
                JSON.stringify({
                  page: currentPage,
                  category: currentCategory,
                  articleId: articleData.id,
                }),
              );
            }}
          >
            {articleData.title}
          </Link>
        </h3>

        {/* Summary */}
        <p className="article-summary">{articleData.summary}</p>

        {/* Author and Date */}
        <div className="article-footer">
          <span className="article-author">By {articleData.author}</span>
          <span className="article-date">
            {formatPublishedDate(articleData.published_at)}
          </span>
          {is_read && read_at && <span className="read-indicator">✓ Read</span>}
        </div>
      </div>
    </article>
  );
}
