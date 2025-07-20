import React from "react";
import { Head, Link, useForm } from "@inertiajs/react";
import { UsersCreateProps } from "../../types";

export default function Create({ form_data, errors }: UsersCreateProps) {
  const {
    data,
    setData,
    post,
    processing,
    errors: formErrors,
  } = useForm({
    name: form_data?.name || "",
    email: form_data?.email || "",
  });

  // Merge server-side errors with client-side errors
  const allErrors = { ...errors, ...formErrors };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    post("/users");
  };

  return (
    <>
      <Head title="Create User" />

      <div className="container">
        {/* Header */}
        <header className="header">
          <h1>Create New User</h1>
          <p>Add a new user to the system</p>
        </header>

        {/* Navigation */}
        <nav className="nav-section">
          <Link href="/users" className="nav-link">
            ← Back to Users
          </Link>
        </nav>

        {/* Form Section */}
        <section className="section">
          <div className="form-container">
            <form onSubmit={handleSubmit} className="user-form">
              {/* Name Field */}
              <div className="form-group">
                <label htmlFor="name" className="form-label">
                  Name *
                </label>
                <input
                  type="text"
                  id="name"
                  value={data.name}
                  onChange={(e) => setData("name", e.target.value)}
                  className={`form-input ${allErrors.name ? "error" : ""}`}
                  placeholder="Enter user's full name"
                  disabled={processing}
                />
                {allErrors.name && (
                  <span className="error-message">{allErrors.name}</span>
                )}
              </div>

              {/* Email Field */}
              <div className="form-group">
                <label htmlFor="email" className="form-label">
                  Email *
                </label>
                <input
                  type="email"
                  id="email"
                  value={data.email}
                  onChange={(e) => setData("email", e.target.value)}
                  className={`form-input ${allErrors.email ? "error" : ""}`}
                  placeholder="Enter user's email address"
                  disabled={processing}
                />
                {allErrors.email && (
                  <span className="error-message">{allErrors.email}</span>
                )}
              </div>

              {/* Form Actions */}
              <div className="form-actions">
                <Link href="/users" className="button secondary">
                  Cancel
                </Link>
                <button
                  type="submit"
                  className="button primary"
                  disabled={processing}
                >
                  {processing ? "Creating..." : "Create User"}
                </button>
              </div>
            </form>
          </div>
        </section>

        {/* Form Demo Info */}
        <section className="section api-demo-section">
          <h2 className="section-title">Form Handling Demonstration</h2>
          <div className="api-demo-content">
            <p>This form demonstrates:</p>
            <ul>
              <li>
                <strong>JSON Form Submission:</strong> Using useForm().post()
                for proper Inertia.js JSON requests
              </li>
              <li>
                <strong>Server-Side Validation:</strong> Validation errors
                returned from the backend and displayed in the form
              </li>
              <li>
                <strong>Form State Preservation:</strong> Form data preserved on
                validation errors
              </li>
              <li>
                <strong>Loading States:</strong> Proper handling of form
                submission and loading indicators
              </li>
            </ul>
            <p>
              Try submitting with empty fields or invalid data to see validation
              in action.
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
