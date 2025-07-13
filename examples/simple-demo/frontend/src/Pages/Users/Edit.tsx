import React from "react";
import { Head, Link, useForm, router } from "@inertiajs/react";
import { UsersEditProps } from "../../types";
import "../../styles.css";

export default function Edit({ user, form_data, errors }: UsersEditProps) {
  const {
    data,
    setData,
    put,
    processing,
    errors: formErrors,
  } = useForm({
    id: user?.id || 0,
    name: user?.name || "",
    email: user?.email || "",
  });
  console.log({ user, data });

  // Merge server-side errors with client-side errors
  const allErrors = { ...errors, ...formErrors };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Extract user ID from current URL if user prop not available
    const userId = data.id;
    put(`/users/${userId}`);
  };

  const handleDelete = () => {
    const userName = data.name;
    const userId = data.id;

    if (
      confirm(
        `Are you sure you want to delete ${userName}? This action cannot be undone.`,
      )
    ) {
      router.delete(`/users/${userId}`, {
        onError: () => {
          alert("Failed to delete user. Please try again.");
        },
      });
    }
  };

  return (
    <>
      <Head title={`Edit User: ${data.name}`} />

      <div className="container">
        {/* Header */}
        <header className="header">
          <h1>Edit User</h1>
          <p>Update information for {data.name}</p>
        </header>

        {/* Navigation */}
        <nav className="nav-section">
          <Link href="/users" className="nav-link">
            ← Back to Users
          </Link>
          <Link href={`/users/${data.id}`} className="nav-link">
            View User
          </Link>
        </nav>

        {/* User Info Summary */}
        {user && (
          <section className="section">
            <div className="user-summary">
              <h3>Editing User #{user.id}</h3>
              <p>Created: {new Date(user.created_at).toLocaleDateString()}</p>
            </div>
          </section>
        )}

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
                <Link href={`/users/${data.id}`} className="button secondary">
                  Cancel
                </Link>
                <button
                  type="submit"
                  className="button primary"
                  disabled={processing}
                >
                  {processing ? "Updating..." : "Update User"}
                </button>
              </div>
            </form>
          </div>
        </section>

        {/* Danger Zone */}
        {user && (
          <section className="section danger-section">
            <h2 className="section-title danger">Danger Zone</h2>
            <div className="danger-content">
              <p>
                Permanently delete this user and all associated data. This
                action cannot be undone.
              </p>
              <button
                onClick={handleDelete}
                className="button danger"
                disabled={processing}
              >
                Delete User
              </button>
            </div>
          </section>
        )}

        {/* Form Demo Info */}
        <section className="section api-demo-section">
          <h2 className="section-title">Update Form Demonstration</h2>
          <div className="api-demo-content">
            <p>This form demonstrates:</p>
            <ul>
              <li>
                <strong>Resource Updates:</strong> Using useForm().put() for
                proper HTTP PUT requests with JSON data
              </li>
              <li>
                <strong>Form Pre-population:</strong> Loading existing data into
                form fields for editing
              </li>
              <li>
                <strong>Validation Handling:</strong> Server-side validation
                with error display and form state preservation
              </li>
              <li>
                <strong>Delete Operations:</strong> Destructive actions with
                confirmation dialogs
              </li>
              <li>
                <strong>Error Recovery:</strong> Maintaining form state when
                validation fails
              </li>
            </ul>
            <p>
              Try updating with invalid data to see validation errors, or test
              the delete functionality with confirmation.
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
