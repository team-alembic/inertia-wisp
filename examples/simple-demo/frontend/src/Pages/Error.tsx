import React from "react";
import { Head, Link } from "@inertiajs/react";
import "../styles.css";

interface ErrorProps {
  errors?: {
    message?: string;
  };
}

export default function Error({ errors }: ErrorProps) {
  const errorMessage = errors?.message || "An error occurred";

  return (
    <>
      <Head title="Error" />

      <div className="container">
        {/* Header */}
        <header className="header">
          <h1>⚠️ Error</h1>
          <p>Something went wrong while processing your request</p>
        </header>

        {/* Error Message Section */}
        <section className="section error-section">
          <h2 className="section-title">What happened?</h2>
          <p className="error-message">{errorMessage}</p>
        </section>

        {/* Navigation Options */}
        <section className="section">
          <h2 className="section-title">What would you like to do?</h2>
          <div className="action-buttons">
            <button
              onClick={() => window.history.back()}
              className="button secondary button-with-icon"
            >
              <span className="button-icon">←</span>
              Go Back
            </button>

            <Link href="/" className="button primary button-with-icon">
              <span className="button-icon">🏠</span>
              Return Home
            </Link>

            <Link href="/users" className="button secondary button-with-icon">
              <span className="button-icon">👥</span>
              View Users
            </Link>
          </div>
        </section>

        {/* Help Section */}
        <section className="section help-section">
          <h2 className="section-title">Need help?</h2>
          <div className="help-content">
            <p>If this error persists, here are some things you can try:</p>
            <ul>
              <li>Check that the URL is correct</li>
              <li>Refresh the page and try again</li>
              <li>Go back and try a different action</li>
            </ul>
          </div>
        </section>
      </div>
    </>
  );
}
