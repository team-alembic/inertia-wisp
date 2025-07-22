import React from "react";
import { Link } from "@inertiajs/react";

interface CategoryFilterInfoProps {
  currentCategory: string;
}

export default function CategoryFilterInfo({ currentCategory }: CategoryFilterInfoProps) {
  if (!currentCategory) {
    return null;
  }

  return (
    <section className="section">
      <div className="filter-info">
        <p>
          Showing articles in category:{" "}
          <strong>{currentCategory}</strong>
          <Link href="/news" className="clear-filter">
            Clear filter
          </Link>
        </p>
      </div>
    </section>
  );
}
