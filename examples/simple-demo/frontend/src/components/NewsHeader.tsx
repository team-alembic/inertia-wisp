import React from "react";

interface NewsHeaderProps {
  totalCount: number;
  currentCategory?: string;
}

export default function NewsHeader({ totalCount, currentCategory }: NewsHeaderProps) {
  return (
    <header className="header">
      <h1>News Feed</h1>
      <p>
        {currentCategory
          ? `Stay updated with ${currentCategory} articles`
          : "Stay updated with the latest articles across all categories"}
      </p>
      <div className="header-stats">
        <span className="article-count">
          {totalCount} articles available
        </span>
      </div>
    </header>
  );
}
