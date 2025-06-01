import type { BlogPostPageProps } from "@shared_types/shared_types/blog.mjs";
import type { ProjectType } from "../../types/gleam-projections";
import PageContainer from "../../components/layout/PageContainer";
import ContentCard from "../../components/cards/ContentCard";
import TagList from "../../components/data/TagList";

export default function BlogPost(props: ProjectType<BlogPostPageProps>) {
  return (
    <PageContainer>
      <ContentCard variant="elevated" padding="none" className="overflow-hidden">
        <div className="px-8 py-12">
          <header className="mb-8">
            <h1 className="text-4xl font-bold text-gray-900 mb-4">
              {props.title}
            </h1>
            <div className="flex items-center justify-between text-sm text-gray-600 mb-6">
              <div className="flex items-center space-x-4">
                <span>
                  By{" "}
                  <span className="font-medium text-gray-800">
                    {props.author}
                  </span>
                </span>
                <span>•</span>
                <time>{props.published_at}</time>
                <span>•</span>
                <span>
                  {props.view_count && props.view_count > 0
                    ? `${props.view_count.toLocaleString()} views`
                    : "Views not loaded"}
                </span>
              </div>
            </div>

            <div className="tag-cloud">
              <TagList
                tags={props.tags}
                variant="blue"
                prefix="#"
              />
            </div>
          </header>

          <div className="blog-content prose prose-lg max-w-none">
            <div className="text-gray-700 leading-relaxed whitespace-pre-line">
              {props.content}
            </div>
          </div>
        </div>

        <footer className="bg-gray-50 px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="text-sm text-gray-600">
              Published on {props.published_at}
            </div>
            <div className="flex items-center space-x-4 text-sm text-gray-600">
              <span>
                {props.view_count && props.view_count > 0
                  ? `${props.view_count.toLocaleString()} views`
                  : "Views not loaded"}
              </span>
              <button className="text-blue-600 hover:text-blue-800 font-medium">
                Share
              </button>
            </div>
          </div>
        </footer>
      </ContentCard>
    </PageContainer>
  );
}
