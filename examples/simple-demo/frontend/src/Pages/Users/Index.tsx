import React, { useState } from "react";
import { Head, Link, router } from "@inertiajs/react";
import { UsersIndexProps } from "../../types";

export default function Index({
  users,
  user_count,
  search_query,
  pagination,
}: UsersIndexProps) {
  const [search, setSearch] = useState(search_query || "");

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    router.get(
      "/users",
      { search },
      {
        preserveState: true,
        only: ["users", "search_query"],
      },
    );
  };

  const handleDelete = (userId: number, userName: string) => {
    if (confirm(`Are you sure you want to delete ${userName}?`)) {
      router.delete(`/users/${userId}`, {
        onSuccess: () => {
          alert(`${userName} has been deleted.`);
        },
        onError: () => {
          alert("Failed to delete user. Please try again.");
        },
      });
    }
  };

  return (
    <>
      <Head title="Users" />

      <div className="container">
        {/* Header */}
        <header className="header">
          <h1>User Management</h1>
          <p>Demonstrating LazyProp with expensive database operations</p>
        </header>

        {/* Navigation */}
        <nav className="nav-section">
          <Link href="/" className="nav-link">
            ← Back to Home
          </Link>
          <Link href="/users/search" className="nav-link">
            🔍 Advanced Search
          </Link>
          <Link href="/users/create" className="nav-link primary">
            Create New User
          </Link>
        </nav>

        {/* Search Section */}
        <section className="section">
          <h2 className="section-title">Search Users</h2>
          <form onSubmit={handleSearch} className="search-form">
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by name..."
              className="search-input"
            />
            <button type="submit" className="search-button">
              Search
            </button>
            {search_query && (
              <Link
                href="/users"
                className="search-clear"
                only={["users", "search_query"]}
              >
                Clear
              </Link>
            )}
          </form>
        </section>

        {/* Stats Section (LazyProp Demo) */}
        <section className="section stats-section">
          <h2 className="section-title">Statistics (LazyProp)</h2>
          <div className="stats-grid">
            <div className="stat-card">
              <h3>Total Users</h3>
              <p className="stat-number">{user_count}</p>
              <small>Expensive database COUNT() query</small>
            </div>
            <div className="stat-card">
              <h3>Search Results</h3>
              <p className="stat-number">{users.length}</p>
              <small>Filtered list from expensive query</small>
            </div>
          </div>
        </section>

        {/* Users List Section (LazyProp Demo) */}
        <section className="section">
          <h2 className="section-title">
            Users List (LazyProp - Expensive Query)
          </h2>

          {search_query && (
            <p className="search-info">
              Showing results for: <strong>"{search_query}"</strong>
            </p>
          )}

          {users.length === 0 ? (
            <div className="empty-state">
              <p>No users found.</p>
              {search_query ? (
                <p>Try a different search term or clear the search.</p>
              ) : (
                <Link href="/users/create" className="nav-link primary">
                  Create the first user
                </Link>
              )}
            </div>
          ) : (
            <div className="users-grid">
              {users.map((user) => (
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

        {/* API Demo Info */}
        <section className="section api-demo-section">
          <h2 className="section-title">LazyProp Demonstration</h2>
          <div className="api-demo-content">
            <p>
              This page demonstrates <strong>LazyProp</strong> usage:
            </p>
            <ul>
              <li>
                <strong>User List:</strong> Expensive database query with search
                filtering
              </li>
              <li>
                <strong>User Count:</strong> Expensive COUNT(*) query for
                statistics
              </li>
              <li>
                <strong>Search Query:</strong> Regular DefaultProp for form
                state
              </li>
            </ul>
            <p>
              <strong>Partial Reload Optimization:</strong> When searching, only
              the <code>users</code> and <code>search_query</code> props are
              reloaded. The expensive <code>user_count</code> query is skipped
              since the total count doesn't change with search filters.
            </p>
            <p>
              Try using the browser dev tools to see the optimized network
              requests when searching - notice how much faster subsequent
              searches are!
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
