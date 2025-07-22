import React from "react";

interface NewsStatusProps {
  articlesShown: number;
  totalCount: number;
  hasMore: boolean;
}

export default function NewsStatus({
  articlesShown,
  totalCount,
  hasMore,
}: NewsStatusProps) {
  if (articlesShown === 0) {
    return null;
  }

  return (
    <section className="section pagination-section">
      <div className="pagination-info">
        <p>
          Showing {articlesShown} of {totalCount} articles
          {hasMore && " • Scroll down for more"}
        </p>
        {!hasMore && totalCount > articlesShown && (
          <p className="pagination-note">
            <strong>All articles loaded!</strong> You've reached the end of the
            feed.
          </p>
        )}
      </div>
    </section>
  );
}
