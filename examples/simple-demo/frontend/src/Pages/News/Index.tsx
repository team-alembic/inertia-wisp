import React, { useEffect } from "react";
import { Head, router, usePage } from "@inertiajs/react";
import { NewsFeedProps } from "../../types";
import NewsHeader from "../../components/NewsHeader";
import NewsNavigation from "../../components/NewsNavigation";
import NewsStats from "../../components/NewsStats";
import CategoryFilterInfo from "../../components/CategoryFilterInfo";
import CategoryFilter from "../../components/CategoryFilter";
import ArticlesList from "../../components/ArticlesList";
import InfiniteScrollLoader from "../../components/InfiniteScrollLoader";
import NewsStatus from "../../components/NewsStatus";
import NewsDemo from "../../components/NewsDemo";
import BackToTop from "../../components/BackToTop";
import ErrorTestingSection from "../../components/error/ErrorTestingSection";

export default function Index({
  news_feed,
  available_categories,
}: NewsFeedProps) {
  const { articles, meta, has_more, total_unread, current_category } =
    news_feed;

  const page = usePage();
  const urlParams = new URLSearchParams(window.location.search);
  const scrollToArticleId = urlParams.get("scrollToArticle");

  const handleArticleClick = (articleId: number) => {
    // Optional: Add analytics tracking here
    console.log(`Article ${articleId} clicked`);
  };

  // Force refresh read status when news feed loads to handle stale cached data
  // This is acceptable useEffect usage per REACT.md - synchronizes with backend state changes
  useEffect(() => {
    // Small delay to avoid race conditions with initial render
    const timer = setTimeout(() => {
      router.reload({
        only: ["news_feed"],
        preserveState: false, // Force React re-render to update UI
        preserveScroll: true,
      });
    }, 100);

    return () => clearTimeout(timer);
  }, []);

  // Load multiple pages and scroll to specific article when returning from article page
  // This is acceptable useEffect usage per REACT.md - DOM manipulation for scroll positioning
  useEffect(() => {
    if (scrollToArticleId && articles.length > 0) {
      const timer = setTimeout(() => {
        const articleElement = document.querySelector(
          `[data-article-id="${scrollToArticleId}"]`,
        );

        if (articleElement) {
          // Article is already loaded, scroll to it
          articleElement.scrollIntoView({
            behavior: "smooth",
            block: "center",
          });
          // Clean up URL parameter
          const newUrl = new URL(window.location.href);
          newUrl.searchParams.delete("scrollToArticle");
          window.history.replaceState({}, "", newUrl.toString());
        } else {
          // Article not loaded yet, need to load more pages
          const currentPage = meta.current_page;
          if (currentPage < meta.last_page && has_more) {
            // Load next page to find the article
            const params = new URLSearchParams(window.location.search);
            const category = params.get("category");

            router.visit(
              `/news?page=${currentPage + 1}${category ? `&category=${category}` : ""}&scrollToArticle=${scrollToArticleId}`,
              {
                preserveState: true,
                preserveScroll: false,
              },
            );
          } else {
            // Article not found, clean up URL and show notification
            console.warn(`Article ${scrollToArticleId} not found in feed`);
            const newUrl = new URL(window.location.href);
            newUrl.searchParams.delete("scrollToArticle");
            window.history.replaceState({}, "", newUrl.toString());
          }
        }
      }, 200);

      return () => clearTimeout(timer);
    }
  }, [
    scrollToArticleId,
    articles,
    meta.current_page,
    meta.last_page,
    has_more,
  ]);

  return (
    <>
      <Head title="News Feed" />

      <div className="container">
        <NewsHeader
          totalCount={meta.total_count}
          currentCategory={current_category}
        />

        <NewsNavigation />

        <NewsStats
          totalCount={meta.total_count}
          totalUnread={total_unread}
          currentPage={meta.current_page}
          lastPage={meta.last_page}
          articlesShown={articles.length}
        />

        <CategoryFilter
          currentCategory={current_category}
          availableCategories={available_categories}
        />

        <CategoryFilterInfo currentCategory={current_category} />

        <ArticlesList
          articles={articles}
          onArticleClick={handleArticleClick}
          currentCategory={current_category}
          scrollToArticleId={scrollToArticleId}
        />

        <InfiniteScrollLoader
          hasMore={has_more}
          currentPage={meta.current_page}
          currentCategory={current_category}
        />

        <NewsStatus
          articlesShown={articles.length}
          totalCount={meta.total_count}
          hasMore={has_more}
        />

        {/* Demo Information */}
        <NewsDemo />

        <ErrorTestingSection />

        <BackToTop />
      </div>
    </>
  );
}
