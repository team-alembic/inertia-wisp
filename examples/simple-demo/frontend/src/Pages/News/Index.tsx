import React from "react";
import { Head } from "@inertiajs/react";
import { NewsFeedProps } from "../../types";
import NewsHeader from "../../components/NewsHeader";
import NewsNavigation from "../../components/NewsNavigation";
import NewsStats from "../../components/NewsStats";
import CategoryFilterInfo from "../../components/CategoryFilterInfo";
import ArticlesList from "../../components/ArticlesList";
import InfiniteScrollLoader from "../../components/InfiniteScrollLoader";
import NewsStatus from "../../components/NewsStatus";
import NewsDemo from "../../components/NewsDemo";

export default function Index({ news_feed }: NewsFeedProps) {
  const { articles, meta, has_more, total_unread, current_category } =
    news_feed;

  const handleArticleClick = (articleId: number) => {
    // Optional: Add analytics tracking here
    console.log(`Article ${articleId} clicked`);
  };

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

        <CategoryFilterInfo currentCategory={current_category} />

        <ArticlesList
          articles={articles}
          onArticleClick={handleArticleClick}
          currentCategory={current_category}
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

        <NewsDemo />
      </div>
    </>
  );
}
