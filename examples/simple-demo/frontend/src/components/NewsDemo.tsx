import React from "react";

export default function NewsDemo() {
  return (
    <section className="section api-demo-section">
      <h2 className="section-title">Infinite Scroll Container</h2>
      <div className="api-demo-content">
        <p>
          This page demonstrates <strong>infinite scroll container</strong>{" "}
          functionality:
        </p>
        <ul>
          <li>
            <strong>MergeProp Integration:</strong> New articles automatically
            merge with existing feed using deep merging
          </li>
          <li>
            <strong>WhenVisible Component:</strong> Inertia.js automatically
            loads more content when approaching bottom of page
          </li>
          <li>
            <strong>Scroll Preservation:</strong> Maintains scroll position
            during content loading
          </li>
          <li>
            <strong>Category Filtering:</strong> Preserves category filters
            during infinite scroll operations
          </li>
        </ul>
        <p>
          <strong>How it works:</strong> Scroll down through the articles and
          watch as new content loads automatically. The container manages
          scroll position, loading states, and error handling through
          Inertia.js built-in components.
        </p>
        <p>
          Try scrolling to see infinite scroll in action, or click article
          titles to mark them as read and see the visual read/unread status
          updates.
        </p>
      </div>
    </section>
  );
}
