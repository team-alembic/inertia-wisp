import React from "react";
import { Head, Link } from "@inertiajs/react";
import { HomePageProps } from "../types";

export default function Home({
  welcome_message,
  navigation,
  csrf_token,
  app_version,
  current_user,
}: HomePageProps) {
  return (
    <>
      <Head title="Home" />

      <div className="container">
        {/* Header */}
        <header className="header">
          <h1>Simple Demo</h1>
          <p>Showcasing the new inertia.eval API design</p>
        </header>

        {/* Navigation */}
        <nav className="nav-section">
          <h2 className="section-title">Navigation (AlwaysProp)</h2>
          <ul className="nav-list">
            {navigation.map((item) => (
              <li key={item.name} className="nav-item">
                <Link href={item.url} className={item.active ? "active" : ""}>
                  {item.name}
                </Link>
              </li>
            ))}
          </ul>
        </nav>

        {/* Welcome Message */}
        <section className="section welcome-section">
          <h2 className="section-title">Welcome Message (DefaultProp)</h2>
          <p className="welcome-message">{welcome_message}</p>
        </section>

        {/* Current User */}
        <section className="section user-section">
          <h2 className="section-title">Current User (DefaultProp)</h2>
          <div className="user-info">
            <p>
              <strong>Name:</strong> {current_user.name}
            </p>
            <p>
              <strong>Email:</strong> {current_user.email}
            </p>
          </div>
        </section>

        {/* App Info */}
        <section className="section">
          <h2 className="section-title">Application Info</h2>
          <div className="app-info-grid">
            <div className="info-card version-card">
              <h3>Version (DefaultProp)</h3>
              <p>{app_version}</p>
            </div>
            <div className="info-card csrf-card">
              <h3>CSRF Token (AlwaysProp)</h3>
              <p>{csrf_token.substring(0, 20)}...</p>
            </div>
          </div>
        </section>

        {/* User Management Demo */}
        <section className="section">
          <h2 className="section-title">Demo Features</h2>
          <div className="demo-features">
            <p>
              Explore the complete functionality built with the new{" "}
              <code>inertia.eval()</code> API:
            </p>
            <div className="feature-grid">
              <Link href="/news" className="feature-card">
                <h3>📰 News Feed</h3>
                <p>
                  Experience MergeProp with infinite scroll and read/unread
                  article tracking
                </p>
              </Link>
              <Link href="/dashboard?delay=2000" className="feature-card">
                <h3>📊 Dashboard</h3>
                <p>
                  Experience DeferredProp with progressive loading and the
                  Deferred component (2s demo delay)
                </p>
              </Link>
              <Link href="/users" className="feature-card">
                <h3>👥 View All Users</h3>
                <p>
                  Browse users with search functionality and LazyProp
                  demonstration
                </p>
              </Link>
              <Link href="/users/create" className="feature-card">
                <h3>➕ Create User</h3>
                <p>Add new users with form validation and error handling</p>
              </Link>
              <Link href="/users/1" className="feature-card">
                <h3>👤 User Details</h3>
                <p>View individual user information and account details</p>
              </Link>
              <Link href="/users/1/edit" className="feature-card">
                <h3>✏️ Edit User</h3>
                <p>
                  Update user information with validation and deletion options
                </p>
              </Link>
            </div>
          </div>
        </section>

        {/* API Demo Info */}
        <section className="section api-demo-section">
          <h2 className="section-title">New API Demonstration</h2>
          <div className="api-demo-content">
            <p>
              This page demonstrates the new <code>inertia.eval()</code> API
              design:
            </p>
            <ul>
              <li>
                <strong>AlwaysProp:</strong> Navigation and CSRF token (always
                included)
              </li>
              <li>
                <strong>DefaultProp:</strong> Welcome message, user info, and
                app version
              </li>
              <li>
                <strong>LazyProp:</strong> User listing and count (expensive
                operations)
              </li>
              <li>
                <strong>MergeProp:</strong> News feed articles (infinite scroll
                and content merging)
              </li>
              <li>
                <strong>DeferredProp:</strong> Dashboard analytics and activity
                feed (progressive loading)
              </li>
            </ul>
            <p>
              Backend constructed the Page object directly without
              InertiaContext, using regular Wisp functionality with modular
              handlers.
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
