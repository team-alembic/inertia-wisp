import React from "react";
import { ArticleWithReadStatus } from "../types";
import ArticleCard from "./ArticleCard";

interface ArticlesListProps {
  articles: ArticleWithReadStatus[];
  onArticleClick: (articleId: number) => void;
  currentCategory?: string;
}

export default function ArticlesList({
  articles,
  onArticleClick,
  currentCategory,
}: ArticlesListProps) {
  if (articles.length === 0) {
    return (
      <section className="section">
        <h2 className="section-title">
          Articles {currentCategory ? `(${currentCategory})` : ""}
        </h2>
        <div className="empty-state">
          <p>No articles found.</p>
          {currentCategory ? (
            <p>Try a different category or clear the filter.</p>
          ) : (
            <p>Check back later for new content.</p>
          )}
        </div>
      </section>
    );
  }

  return (
    <section className="section">
      <h2 className="section-title">
        Articles {currentCategory ? `(${currentCategory})` : ""}
      </h2>
      <div className="articles-list">
        {articles.map((article) => (
          <ArticleCard
            key={article.article.id}
            article={article}
            onClick={onArticleClick}
          />
        ))}
      </div>
    </section>
  );
}
