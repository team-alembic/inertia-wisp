import React from "react";
import { Link, router } from "@inertiajs/react";

export default function Users({ users, auth, csrf_token }) {
  const handleDelete = (userId) => {
    if (confirm("Are you sure you want to delete this user?")) {
      router.post(`/users/${userId}/delete`, {
        _token: csrf_token,
      });
    }
  };

  return (
    <div
      style={{
        padding: "20px",
        fontFamily: "Arial, sans-serif",
        maxWidth: "800px",
        margin: "0 auto",
      }}
    >
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "20px",
        }}
      >
        <h1>Users</h1>
        <Link
          href="/users/create"
          style={{
            backgroundColor: "#007bff",
            color: "white",
            padding: "10px 20px",
            textDecoration: "none",
            borderRadius: "4px",
            fontSize: "14px",
          }}
        >
          Create New User
        </Link>
      </div>

      <nav style={{ marginBottom: "20px" }}>
        <Link
          href="/"
          style={{
            marginRight: "10px",
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          Home
        </Link>
        <Link
          href="/about"
          style={{
            marginRight: "10px",
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          About
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
          overflow: "hidden",
        }}
      >
        <table style={{ width: "100%", borderCollapse: "collapse" }}>
          <thead>
            <tr style={{ backgroundColor: "#f8f9fa" }}>
              <th
                style={{
                  padding: "12px",
                  textAlign: "left",
                  borderBottom: "1px solid #ddd",
                }}
              >
                ID
              </th>
              <th
                style={{
                  padding: "12px",
                  textAlign: "left",
                  borderBottom: "1px solid #ddd",
                }}
              >
                Name
              </th>
              <th
                style={{
                  padding: "12px",
                  textAlign: "left",
                  borderBottom: "1px solid #ddd",
                }}
              >
                Email
              </th>
              <th
                style={{
                  padding: "12px",
                  textAlign: "left",
                  borderBottom: "1px solid #ddd",
                }}
              >
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {users.map((user) => (
              <tr key={user.id}>
                <td
                  style={{
                    padding: "12px",
                    borderBottom: "1px solid #eee",
                  }}
                >
                  {user.id}
                </td>
                <td
                  style={{
                    padding: "12px",
                    borderBottom: "1px solid #eee",
                  }}
                >
                  {user.name}
                </td>
                <td
                  style={{
                    padding: "12px",
                    borderBottom: "1px solid #eee",
                  }}
                >
                  {user.email}
                </td>
                <td
                  style={{
                    padding: "12px",
                    borderBottom: "1px solid #eee",
                  }}
                >
                  <Link
                    href={`/users/${user.id}`}
                    style={{
                      color: "blue",
                      textDecoration: "underline",
                      marginRight: "10px",
                    }}
                  >
                    View
                  </Link>
                  <Link
                    href={`/users/${user.id}/edit`}
                    style={{
                      color: "green",
                      textDecoration: "underline",
                      marginRight: "10px",
                    }}
                  >
                    Edit
                  </Link>
                  <button
                    onClick={() => handleDelete(user.id)}
                    style={{
                      color: "red",
                      background: "none",
                      border: "none",
                      textDecoration: "underline",
                      cursor: "pointer",
                      fontSize: "14px",
                    }}
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {users.length === 0 && (
        <div
          style={{
            textAlign: "center",
            padding: "40px",
            color: "#666",
          }}
        >
          No users found. <Link href="/users/create">Create the first user</Link>
        </div>
      )}

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
          <li>This demonstrates Inertia.js form handling with Gleam backend</li>
          <li>All navigation uses Inertia XHR requests (no full page reloads)</li>
          <li>Forms include validation and error handling</li>
          <li>Data persists only during the demo session (in-memory storage)</li>
        </ul>
      </div>
    </div>
  );
}