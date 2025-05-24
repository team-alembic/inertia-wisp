import React from "react";
import { Link, router } from "@inertiajs/react";

export default function Home({ message, timestamp }) {
  return (
    <div
      style={{
        padding: "20px",
        fontFamily: "Arial, sans-serif",
      }}
    >
      <h1>Welcome to Inertia Gleam!</h1>
      <p>
        Message from server: <strong>{message}</strong>
      </p>
      <p>Timestamp: {timestamp}</p>

      <nav style={{ marginTop: "20px" }}>
        <Link
          href="/about"
          style={{
            marginRight: "10px",
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          Go to About
        </Link>
      </nav>

      <div
        style={{
          marginTop: "20px",
          padding: "10px",
          backgroundColor: "#f0f0f0",
        }}
      >
        <h3>Test Navigation</h3>
        <button
          onClick={() => router.visit("/")}
          style={{ marginRight: "10px" }}
        >
          Reload Home (XHR)
        </button>
        <button onClick={() => (window.location.href = "/")}>
          Reload Home (Full)
        </button>
      </div>
    </div>
  );
}
