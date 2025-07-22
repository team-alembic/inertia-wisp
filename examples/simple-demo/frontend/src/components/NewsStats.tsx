import React from "react";

interface NewsStatsProps {
  totalCount: number;
  totalUnread: number;
  currentPage: number;
  lastPage: number;
  articlesShown: number;
}

export default function NewsStats({
  totalCount,
  totalUnread,
  currentPage,
  lastPage,
  articlesShown,
}: NewsStatsProps) {
  return (
    <section className="section stats-section">
      <h2 className="section-title">Feed Statistics</h2>
      <div className="stats-grid">
        <div className="stat-card">
          <h3>Total Articles</h3>
          <p className="stat-number">{totalCount}</p>
          <small>Available in all categories</small>
        </div>
        <div className="stat-card">
          <h3>Unread Articles</h3>
          <p className="stat-number">{totalUnread}</p>
          <small>Articles you haven't read yet</small>
        </div>
        <div className="stat-card">
          <h3>Current Page</h3>
          <p className="stat-number">
            {currentPage} of {lastPage}
          </p>
          <small>Showing {articlesShown} articles</small>
        </div>
      </div>
    </section>
  );
}
