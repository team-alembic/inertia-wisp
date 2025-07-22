import React from "react";
import { WhenVisible } from "@inertiajs/react";

interface InfiniteScrollLoaderProps {
  hasMore: boolean;
  currentPage: number;
  currentCategory?: string;
}

export default function InfiniteScrollLoader({
  hasMore,
  currentPage,
  currentCategory,
}: InfiniteScrollLoaderProps) {
  return (
    <WhenVisible
      always={hasMore}
      params={{
        data: {
          page: currentPage + 1,
          ...(currentCategory && { category: currentCategory }),
        },
        only: ["news_feed"],
      }}
    >
      {hasMore ? (
        <div className="scroll-sentinel">
          <div className="infinite-scroll-loader">
            <div className="loading-spinner"></div>
            <p>Loading more articles...</p>
          </div>
        </div>
      ) : (
        <div className="scroll-sentinel">
          <div className="text-center py-6 text-gray-600">
            You've reached the end!
          </div>
        </div>
      )}
    </WhenVisible>
  );
}
