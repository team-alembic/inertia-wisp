import React, { useState, useEffect } from "react";

interface BackToTopProps {
  threshold?: number; // Show after scrolling X pixels
  smooth?: boolean; // Smooth scroll behavior
  className?: string;
}

export default function BackToTop({
  threshold = 500,
  smooth = true,
  className = "",
}: BackToTopProps) {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    // Browser API integration: Listen for scroll events to show/hide button
    // This is acceptable useEffect usage per REACT.md - integrates with native browser scroll API
    const handleScroll = () => {
      const scrollTop =
        window.pageYOffset || document.documentElement.scrollTop;
      setIsVisible(scrollTop > threshold);
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, [threshold]);

  const scrollToTop = () => {
    if (smooth) {
      window.scrollTo({
        top: 0,
        behavior: "smooth",
      });
    } else {
      window.scrollTo(0, 0);
    }
  };

  const handleKeyDown = (event: React.KeyboardEvent) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      scrollToTop();
    }
  };

  if (!isVisible) {
    return null;
  }

  return (
    <button
      type="button"
      className={`
        fixed bottom-8 right-8 z-50
        w-12 h-12
        bg-gray-800 hover:bg-gray-700
        text-white text-xl font-bold
        border-none rounded-full
        flex items-center justify-center
        shadow-lg
        transition-all duration-300 ease-in-out
        hover:scale-110
        cursor-pointer
        ${isVisible ? "opacity-100 scale-100" : "opacity-0 scale-75"}
        ${className}
      `}
      onClick={scrollToTop}
      onKeyDown={handleKeyDown}
      aria-label="Scroll to top of page"
      title="Back to top"
    >
      ↑
    </button>
  );
}
