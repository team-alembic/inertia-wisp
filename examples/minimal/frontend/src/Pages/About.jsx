import React from "react";
import { Link, router } from "@inertiajs/react";

export default function About() {
  return (
    <div
      style={{
        padding: "20px",
        fontFamily: "Arial, sans-serif",
      }}
    >
      <h1>About Page</h1>
      <p>This is the about page, rendered through Inertia!</p>

      <nav style={{ marginTop: "20px" }}>
        <Link
          href="/"
          style={{
            marginRight: "10px",
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          Back to Home
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
          onClick={() => router.visit("/about")}
          style={{ marginRight: "10px" }}
        >
          Reload About (XHR)
        </button>
        <button onClick={() => (window.location.href = "/about")}>
          Reload About (Full)
        </button>
      </div>
    </div>
  );
}
