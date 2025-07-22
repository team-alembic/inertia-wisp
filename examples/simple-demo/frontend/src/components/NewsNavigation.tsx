import React from "react";
import { Link } from "@inertiajs/react";

export default function NewsNavigation() {
  return (
    <nav className="nav-section">
      <Link href="/" className="nav-link">
        ← Back to Home
      </Link>
      <Link href="/dashboard" className="nav-link">
        📊 Dashboard
      </Link>
    </nav>
  );
}
