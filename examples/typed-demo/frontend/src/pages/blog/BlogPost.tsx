import type { BlogPostPageData } from "../../types/gleam-projections";

export default function BlogPost(props: BlogPostPageData) {
  return (
    <div className="max-w-4xl mx-auto p-6">
      <article className="bg-white shadow-lg rounded-lg overflow-hidden">
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
              <div className="flex flex-wrap gap-2">
                {props.tags.map((tag: string, index: number) => (
                  <span
                    key={index}
                    className="tag px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full font-medium"
                  >
                    #{tag}
                  </span>
                ))}
              </div>
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
      </article>
    </div>
  );
}
