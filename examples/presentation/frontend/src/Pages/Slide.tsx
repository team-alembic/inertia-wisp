import { Head, Link } from "@inertiajs/react";
import { SlidePagePropsSchema, type SlidePageProps } from "../schemas";
import { validateProps } from "../lib/validateProps";
import { highlightCode } from "../lib/prism";
import { SlideNavigation } from "../components/SlideNavigation";
import { ContentBlock } from "src/generated/schemas";

function Slide({ slide, navigation, presentation_title }: SlidePageProps) {
  return (
    <>
      <Head title={slide.title} />

      <div className="min-h-screen flex flex-col bg-gradient-to-br from-purple-200 via-pink-200 to-purple-300">
        <main className="flex-1 flex items-center justify-center p-8">
          <div className="max-w-7xl w-full">
            {slide.content.map((block, index) => (
              <ContentBlockRenderer key={index} block={block} />
            ))}
          </div>
        </main>

        <SlideNavigation navigation={navigation} />
      </div>
    </>
  );
}

function ContentBlockRenderer({ block }: { block: ContentBlock }) {
  switch (block.type) {
    case "heading":
      return (
        <h1 className="text-6xl font-bold text-gray-900 mb-6 text-center">
          {block.text}
        </h1>
      );

    case "subheading":
      return (
        <h2 className="text-4xl font-semibold text-gray-800 mb-8 text-center">
          {block.text}
        </h2>
      );

    case "paragraph":
      return (
        <p className="text-2xl text-gray-700 mb-4 text-center leading-relaxed">
          {block.text}
        </p>
      );

    case "code_block":
      const highlightedCode = highlightCode(
        block.code,
        block.language,
        block.highlight_lines,
      );

      return (
        <pre className="bg-white/90 rounded-lg p-6 mb-6 overflow-x-auto shadow-lg">
          <code
            className={`language-${block.language} text-lg`}
            dangerouslySetInnerHTML={{ __html: highlightedCode }}
          />
        </pre>
      );

    case "bullet_list":
      return (
        <ul className="text-2xl text-gray-700 space-y-3 mb-6 list-disc list-inside">
          {block.items.map((item, index) => (
            <li key={index} className="leading-relaxed">
              {item}
            </li>
          ))}
        </ul>
      );

    case "numbered_list":
      return (
        <ol className="text-2xl text-gray-700 space-y-3 mb-6 list-decimal list-inside">
          {block.items.map((item, index) => (
            <li key={index} className="leading-relaxed">
              {item}
            </li>
          ))}
        </ol>
      );

    case "quote":
      return (
        <blockquote className="border-l-4 border-purple-500 pl-6 py-4 mb-6 bg-white bg-opacity-50 rounded-r-lg">
          <p className="text-2xl italic text-gray-800 mb-2">{block.text}</p>
          <cite className="text-xl text-gray-600">— {block.author}</cite>
        </blockquote>
      );

    case "image":
      return (
        <div className="flex justify-center mb-6">
          <img
            src={block.url}
            alt={block.alt}
            style={{ width: `${block.width}px` }}
            className="rounded-lg shadow-lg"
          />
        </div>
      );

    case "image_row":
      return (
        <div className="flex justify-center items-center gap-8 mb-6">
          {block.images.map((image, index) => (
            <img
              key={index}
              src={image.url}
              alt={image.alt}
              style={{ width: `${image.width}px` }}
              className="rounded-lg shadow-lg"
            />
          ))}
        </div>
      );

    case "columns":
      return (
        <div className="grid grid-cols-[40%_60%] gap-8 mb-6 items-start">
          <div className="space-y-4">
            {block.left.map((leftBlock, index) => (
              <ContentBlockRenderer key={`left-${index}`} block={leftBlock} />
            ))}
          </div>
          <div className="space-y-4">
            {block.right.map((rightBlock, index) => (
              <ContentBlockRenderer key={`right-${index}`} block={rightBlock} />
            ))}
          </div>
        </div>
      );

    case "spacer":
      return <div className="h-8" />;

    case "link_button":
      return (
        <div className="flex justify-center mb-6">
          <Link
            href={block.href}
            className="inline-block bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold py-4 px-8 rounded-lg shadow-lg hover:from-purple-700 hover:to-pink-700 transition-all transform hover:scale-[1.02] active:scale-[0.98] text-xl"
          >
            {block.text}
          </Link>
        </div>
      );

    default:
      return null;
  }
}

export default validateProps(Slide, SlidePagePropsSchema);
