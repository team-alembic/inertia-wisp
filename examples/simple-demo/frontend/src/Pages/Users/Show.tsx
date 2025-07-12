import React from "react";
import { Head, Link } from "@inertiajs/react";
import { UsersShowProps } from "../../types";
import "../../styles.css";

export default function Show({ user }: UsersShowProps) {
  return (
    <>
      <Head title={`User: ${user.name}`} />

      <div className="container">
        {/* Header */}
        <header className="header">
          <h1>User Details</h1>
          <p>Viewing information for {user.name}</p>
        </header>

        {/* Navigation */}
        <nav className="nav-section">
          <Link href="/users" className="nav-link">
            ← Back to Users
          </Link>
          <Link href={`/users/${user.id}/edit`} className="nav-link primary">
            Edit User
          </Link>
        </nav>

        {/* User Details Section */}
        <section className="section">
          <div className="user-details-container">
            <div className="user-card large">
              <div className="user-header">
                <h2 className="user-name">{user.name}</h2>
                <span className="user-id">ID: {user.id}</span>
              </div>

              <div className="user-info-grid">
                <div className="info-item">
                  <label className="info-label">Email Address</label>
                  <p className="info-value">{user.email}</p>
                </div>

                <div className="info-item">
                  <label className="info-label">User ID</label>
                  <p className="info-value">{user.id}</p>
                </div>

                <div className="info-item">
                  <label className="info-label">Created Date</label>
                  <p className="info-value">
                    {new Date(user.created_at).toLocaleDateString("en-US", {
                      year: "numeric",
                      month: "long",
                      day: "numeric",
                      hour: "2-digit",
                      minute: "2-digit",
                    })}
                  </p>
                </div>

                <div className="info-item">
                  <label className="info-label">Account Age</label>
                  <p className="info-value">
                    {Math.floor(
                      (Date.now() - new Date(user.created_at).getTime()) /
                        (1000 * 60 * 60 * 24)
                    )}{" "}
                    days
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Action Section */}
        <section className="section">
          <h2 className="section-title">Actions</h2>
          <div className="action-buttons">
            <Link
              href={`/users/${user.id}/edit`}
              className="button primary large"
            >
              Edit User Information
            </Link>

            <Link
              href="/users"
              className="button secondary large"
            >
              View All Users
            </Link>
          </div>
        </section>

        {/* API Demo Info */}
        <section className="section api-demo-section">
          <h2 className="section-title">Single Resource Demonstration</h2>
          <div className="api-demo-content">
            <p>This page demonstrates:</p>
            <ul>
              <li>
                <strong>Resource Loading:</strong> Fetching a single user by ID
                with proper error handling for invalid/missing IDs
              </li>
              <li>
                <strong>Data Display:</strong> Clean presentation of user
                information with formatted dates and computed values
              </li>
              <li>
                <strong>Navigation:</strong> Contextual links to related actions
                (edit, back to list)
              </li>
              <li>
                <strong>URL Parameters:</strong> Using route parameters to
                identify the specific resource
              </li>
            </ul>
            <p>
              Try visiting an invalid user ID (like /users/999) to see error
              handling in action.
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
