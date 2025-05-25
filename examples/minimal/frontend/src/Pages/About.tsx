import { Link, router } from "@inertiajs/react";
import { AboutPageProps } from "../types";

export default function About({ page_title, auth, csrf_token }: AboutPageProps) {
  return (
    <div
      style={{
        padding: "20px",
        fontFamily: "Arial, sans-serif",
      }}
    >
      <h1>{page_title}</h1>
      <p>This is the about page, rendered through Inertia!</p>

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