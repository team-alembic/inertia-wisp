import React from "react";
import { router } from "@inertiajs/react";
import { ArticleCategory } from "../types";

interface CategoryFilterProps {
  currentCategory: string;
  availableCategories: ArticleCategory[];
  className?: string;
}

const CATEGORY_ICONS: Record<ArticleCategory | "all", string> = {
  all: "📰",
  technology: "💻",
  business: "💼",
  science: "🔬",
  sports: "⚽",
  entertainment: "🎬",
};

const getCategoryLabel = (category: ArticleCategory | "all"): string => {
  if (category === "all") return "All";
  return category.charAt(0).toUpperCase() + category.slice(1);
};

export default function CategoryFilter({
  currentCategory,
  availableCategories,
  className = "",
}: CategoryFilterProps) {
  const handleCategorySelect = (category: ArticleCategory | "all") => {
    const params: { page?: number; category?: string } = { page: 1 };

    if (category !== "all") {
      params.category = category;
    }

    // Navigate with new category filter, reset pagination, replace state (no merge)
    router.get("/news", params, {
      preserveState: false,
      replace: false,
    });
  };

  const isActive = (category: ArticleCategory | "all") => {
    if (category === "all") {
      return !currentCategory || currentCategory === "";
    }
    return currentCategory === category;
  };

  // Build categories array with 'all' option first
  const categories = [
    {
      key: "all" as const,
      label: getCategoryLabel("all"),
      icon: CATEGORY_ICONS.all,
    },
    ...availableCategories.map((cat) => ({
      key: cat,
      label: getCategoryLabel(cat),
      icon: CATEGORY_ICONS[cat],
    })),
  ];

  return (
    <section className={`section ${className}`}>
      <div className="category-filter">
        <h3 className="category-filter-title">Filter by Category</h3>

        <div className="category-buttons">
          {categories.map(({ key, label, icon }) => (
            <button
              key={key}
              type="button"
              onClick={() => handleCategorySelect(key)}
              className={`category-button ${isActive(key) ? "active" : ""}`}
              aria-pressed={isActive(key)}
              title={`Filter articles by ${label.toLowerCase()}`}
            >
              <span className="category-icon" aria-hidden="true">
                {icon}
              </span>
              <span className="category-label">{label}</span>
            </button>
          ))}
        </div>

        {/* Clear filter helper for active states */}
        {currentCategory && (
          <div className="category-clear">
            <button
              type="button"
              onClick={() => handleCategorySelect("all")}
              className="clear-filter-button"
              title="Show all articles"
            >
              ✕ Clear filter
            </button>
          </div>
        )}
      </div>
    </section>
  );
}
