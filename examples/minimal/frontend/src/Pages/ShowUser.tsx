import { Link } from "@inertiajs/react";
import { ShowUserPageProps, ShowUserPagePropsSchema, withValidatedProps } from "../schemas";

function ShowUser({ user, auth, csrf_token }: ShowUserPageProps) {
  return (
    <div
      style={{
        padding: "20px",
        fontFamily: "Arial, sans-serif",
        maxWidth: "600px",
        margin: "0 auto",
      }}
    >
      <h1>User Details</h1>

      <nav style={{ marginBottom: "20px" }}>
        <Link
          href="/users"
          style={{
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          ← Back to Users
        </Link>
      </nav>

      {auth?.authenticated && (
        <div
          style={{
            backgroundColor: "#e8f5e8",
            padding: "10px",
            marginBottom: "20px",
            borderRadius: "4px",
            fontSize: "14px",
          }}
        >
          Logged in as: {auth.user}
        </div>
      )}

      <div
        style={{
          border: "1px solid #ddd",
          borderRadius: "4px",
          padding: "20px",
          marginBottom: "20px",
        }}
      >
        <div style={{ marginBottom: "15px" }}>
          <strong style={{ display: "inline-block", width: "80px" }}>
            ID:
          </strong>
          {user.id}
        </div>
        <div style={{ marginBottom: "15px" }}>
          <strong style={{ display: "inline-block", width: "80px" }}>
            Name:
          </strong>
          {user.name}
        </div>
        <div style={{ marginBottom: "15px" }}>
          <strong style={{ display: "inline-block", width: "80px" }}>
            Email:
          </strong>
          {user.email}
        </div>
      </div>

      <div>
        <Link
          href={`/users/${user.id}/edit`}
          style={{
            backgroundColor: "#28a745",
            color: "white",
            padding: "10px 20px",
            textDecoration: "none",
            borderRadius: "4px",
            fontSize: "14px",
            marginRight: "10px",
          }}
        >
          Edit User
        </Link>

        <Link
          href="/users"
          style={{
            backgroundColor: "#6c757d",
            color: "white",
            padding: "10px 20px",
            textDecoration: "none",
            borderRadius: "4px",
            fontSize: "14px",
          }}
        >
          Back to List
        </Link>
      </div>

      <div
        style={{
          marginTop: "30px",
          padding: "15px",
          backgroundColor: "#f8f9fa",
          borderRadius: "4px",
        }}
      >
        <h3>Demo Notes</h3>
        <ul style={{ marginLeft: "20px" }}>
          <li>This page demonstrates Inertia.js data passing from Gleam</li>
          <li>User data is serialized from Gleam and consumed by React</li>
          <li>Navigation between pages preserves application state</li>
          <li>All links use Inertia for seamless SPA experience</li>
        </ul>
      </div>
    </div>
  );
}

export default withValidatedProps(ShowUserPagePropsSchema, ShowUser);