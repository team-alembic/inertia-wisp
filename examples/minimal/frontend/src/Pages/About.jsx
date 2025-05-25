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
          href="/users"
          style={{
            marginRight: "10px",
            color: "blue",
            textDecoration: "underline",
            cursor: "pointer",
          }}
        >
          Users (Forms Demo)
        </Link>
      </nav>

      <div
        style={{
          marginTop: "20px",
          padding: "15px",
          backgroundColor: "#f0f0f0",
          borderRadius: "4px",
        }}
      >
        <h3>About Inertia Gleam</h3>
        <p style={{ marginBottom: "15px" }}>
          This demo showcases a full-stack application built with:
        </p>
        <ul style={{ marginLeft: "20px", marginBottom: "20px" }}>
          <li><strong>Backend:</strong> Gleam + Wisp web framework</li>
          <li><strong>Frontend:</strong> React + Inertia.js</li>
          <li><strong>Features:</strong> SPA navigation, forms, validation, redirects</li>
        </ul>
        
        <h4 style={{ marginBottom: "10px" }}>Test Navigation</h4>
        <button
          onClick={() => router.visit("/about")}
          style={{ marginRight: "10px", padding: "5px 10px" }}
        >
          Reload About (XHR)
        </button>
        <button 
          onClick={() => (window.location.href = "/about")}
          style={{ padding: "5px 10px" }}
        >
          Reload About (Full)
        </button>
      </div>
    </div>
  );
}
