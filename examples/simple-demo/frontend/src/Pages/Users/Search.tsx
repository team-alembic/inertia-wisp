import React, { useState } from "react";
import { Head, Link, router } from "@inertiajs/react";
import { UsersSearchProps } from "../../types";

export default function Search({
  search_filters,
  search_results,
  analytics,
}: UsersSearchProps) {
  const [search, setSearch] = useState(search_filters.query || "");
  const [category, setCategory] = useState(search_filters.category || "");
  const [showAnalytics, setShowAnalytics] = useState(false);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    router.get(
      "/users/search",
      { query: search, category: category || undefined, sort_by: "name" },
      {
        preserveState: true,
        only: ["search_filters", "search_results"],
      },
    );
  };

  const handleLoadAnalytics = () => {
    router.get(
      "/users/search",
      { query: search, category: category || undefined, sort_by: "name" },
      {
        preserveState: true,
        only: ["analytics"],
        onSuccess: () => setShowAnalytics(true),
      },
    );
  };

  const handleDelete = (userId: number, userName: string) => {
    if (confirm(`Are you sure you want to delete ${userName}?`)) {
      router.delete(`/users/${userId}`, {
        onSuccess: () => {
          alert(`${userName} has been deleted.`);
          // Refresh search results
          router.reload({ only: ["search_results"] });
        },
        onError: () => {
          alert("Failed to delete user. Please try again.");
        },
      });
    }
  };

  return (
    <>
      <Head title="Search Users" />

      <div className="container">
        {/* Header */}
        <header className="header">
          <h1>Advanced User Search</h1>
          <p>Demonstrating OptionalProp with expensive analytics operations</p>
        </header>

        {/* Navigation */}
        <nav className="nav-section">
          <Link href="/users" className="nav-link">
            ← Back to Users
          </Link>
          <Link href="/users/create" className="nav-link primary">
            Create New User
          </Link>
        </nav>

        {/* Search Form */}
        <section className="section">
          <h2 className="section-title">Search & Filter</h2>
          <form onSubmit={handleSearch} className="search-form">
            <div style={{ display: "flex", gap: "1rem", marginBottom: "1rem" }}>
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search by name..."
                className="search-input"
                style={{ flex: 1 }}
              />
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="search-input"
                style={{ minWidth: "150px" }}
              >
                <option value="">All Categories</option>
                <option value="admin">Admin</option>
                <option value="user">User</option>
                <option value="demo">Demo</option>
              </select>
            </div>
            <div style={{ display: "flex", gap: "1rem" }}>
              <button type="submit" className="search-button">
                Search
              </button>
              {search_filters.query && (
                <Link
                  href="/users/search"
                  className="search-clear"
                  only={["search_filters", "search_results"]}
                >
                  Clear
                </Link>
              )}
            </div>
          </form>
        </section>

        {/* OptionalProp Analytics Demo */}
        <section className="section stats-section">
          <h2 className="section-title">
            Search Analytics (OptionalProp Demo)
          </h2>

          {!analytics && !showAnalytics && (
            <div className="demo-explanation">
              <p>
                <strong>OptionalProp Demonstration:</strong>
              </p>
              <p>
                Analytics are excluded by default for performance. Click below
                to load them via partial reload.
              </p>
              <button
                onClick={handleLoadAnalytics}
                className="search-button"
                style={{ marginTop: "1rem" }}
              >
                🔄 Load Analytics (OptionalProp)
              </button>
            </div>
          )}

          {analytics && (
            <div className="stats-grid">
              <div className="stat-card">
                <h3>Filtered Results</h3>
                <p className="stat-number">{analytics.total_filtered}</p>
                <small>Matching search criteria</small>
              </div>
              <div className="stat-card">
                <h3>Match Percentage</h3>
                <p className="stat-number">
                  {analytics.matching_percentage.toFixed(1)}%
                </p>
                <small>Of total users</small>
              </div>
              <div className="stat-card">
                <h3>Query Performance</h3>
                <p className="stat-number">
                  {analytics.filter_performance_ms}ms
                </p>
                <small>Filter execution time</small>
              </div>
            </div>
          )}
        </section>

        {/* Search Results */}
        <section className="section">
          <h2 className="section-title">
            Search Results
            {search_filters.query && (
              <span style={{ fontWeight: "normal", fontSize: "0.9em" }}>
                {" "}
                for "{search_filters.query}"
              </span>
            )}
          </h2>

          {search_results.length === 0 ? (
            <div className="empty-state">
              <p>No users found matching your search criteria.</p>
              <p>Try adjusting your search terms or clearing the filters.</p>
            </div>
          ) : (
            <div className="users-grid">
              {search_results.map((user) => (
                <div key={user.id} className="user-card">
                  <div className="user-header">
                    <h3 className="user-name">{user.name}</h3>
                    <span className="user-id">ID: {user.id}</span>
                  </div>

                  <div className="user-details">
                    <p className="user-email">{user.email}</p>
                    <p className="user-date">
                      Created: {new Date(user.created_at).toLocaleDateString()}
                    </p>
                  </div>

                  <div className="user-actions">
                    <Link
                      href={`/users/${user.id}`}
                      className="action-button view"
                    >
                      View
                    </Link>
                    <Link
                      href={`/users/${user.id}/edit`}
                      className="action-button edit"
                    >
                      Edit
                    </Link>
                    <button
                      onClick={() => handleDelete(user.id, user.name)}
                      className="action-button delete"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* Technical Demo Info */}
        <section className="section api-demo-section">
          <h2 className="section-title">OptionalProp Technical Demo</h2>
          <div className="api-demo-content">
            <p>
              This page demonstrates <strong>OptionalProp</strong> usage with
              Inertia.js:
            </p>

            <h3>What's Happening:</h3>
            <ul>
              <li>
                <strong>Search Filters & Results:</strong> Always included
                (DefaultProp)
              </li>
              <li>
                <strong>Analytics:</strong> OptionalProp - excluded by default
                for performance
              </li>
              <li>
                <strong>Partial Reload:</strong> Analytics loaded separately
                when requested
              </li>
            </ul>

            <h3>Performance Benefits:</h3>
            <ul>
              <li>
                Initial page load is fast (no expensive analytics computation)
              </li>
              <li>
                Analytics only computed when user specifically requests them
              </li>
              <li>Partial reload updates only the analytics section</li>
            </ul>

            <h3>Technical Implementation:</h3>
            <ul>
              <li>
                Backend:{" "}
                <code>types.OptionalProp("analytics", fn() {"{ ... }"})</code>
              </li>
              <li>
                Frontend: <code>only: ["analytics"]</code> in partial reload
              </li>
              <li>Result: Lazy evaluation of expensive operations</li>
            </ul>

            <p>
              <strong>Open your browser's dev tools</strong> to see the network
              requests and notice how analytics are loaded separately!
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
