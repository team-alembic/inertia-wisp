import React from "react";
import { Head, Link } from "@inertiajs/react";
import { HomePageProps } from "../types";
import "../styles.css";

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
            </ul>
            <p>
              Backend constructed the Page object directly without
              InertiaContext, using regular Wisp functionality.
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
