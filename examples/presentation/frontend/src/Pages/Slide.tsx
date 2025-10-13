import React, { useEffect } from "react";
import { Head, Link, router } from "@inertiajs/react";
import Prism from "prismjs";
import {
  SlidePagePropsSchema,
  type ContentBlock,
  type ImageData,
  type SlidePageProps,
} from "../schemas";
import { validateProps } from "../lib/validateProps";

// Import core languages
import "prismjs/components/prism-typescript";
import "prismjs/components/prism-javascript";
import "prismjs/components/prism-jsx";
import "prismjs/components/prism-tsx";
import "prismjs/components/prism-bash";
import "prismjs/components/prism-json";
import "prismjs/components/prism-markup";

// Add Gleam language definition
Prism.languages.gleam = {
  comment: {
    pattern: /\/\/.*|\/\*[\s\S]*?\*\//,
    greedy: true,
  },
  string: {
    pattern: /"(?:[^"\\]|\\.)*"/,
    greedy: true,
  },
  keyword:
    /\b(?:pub|fn|let|use|case|if|else|import|type|const|assert|panic|todo|as|opaque|external|javascript|erlang)\b/,
  function: /\b[a-z_][a-zA-Z0-9_]*(?=\s*\()/,
  type: /\b[A-Z][a-zA-Z0-9_]*\b/,
  operator: /[|&<>=!+\-*/]+|->|<-|\.\./,
  punctuation: /[{}[\]();,.]/,
  number: /\b\d+(?:\.\d+)?\b/,
  boolean: /\b(?:True|False)\b/,
};

function Slide({ slide, navigation, presentation_title }: SlidePageProps) {
  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "ArrowRight" && navigation.has_next) {
        router.visit(navigation.next_url);
      } else if (e.key === "ArrowLeft" && navigation.has_previous) {
        router.visit(navigation.previous_url);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [navigation]);

  return (
    <>
      <Head title={slide.title} />

      <div className="min-h-screen flex flex-col bg-gradient-to-br from-purple-200 via-pink-200 to-purple-300">
        {/* Main slide content */}
        <main className="flex-1 flex items-center justify-center p-8">
          <div className="max-w-7xl w-full">
            {slide.content.map((block, index) => (
              <ContentBlockRenderer key={index} block={block} />
            ))}
          </div>
        </main>

        {/* Navigation footer */}
        <footer className="p-6 flex items-center justify-between">
          <div className="flex items-center gap-4">
            {navigation.has_previous ? (
              <Link
                href={navigation.previous_url}
                className="px-4 py-2 bg-white bg-opacity-80 rounded-lg hover:bg-opacity-100 transition-all shadow-md"
              >
                ← Previous
              </Link>
            ) : (
              <div className="px-4 py-2 text-gray-400">← Previous</div>
            )}

            {navigation.has_next ? (
              <Link
                href={navigation.next_url}
                className="px-4 py-2 bg-white bg-opacity-80 rounded-lg hover:bg-opacity-100 transition-all shadow-md"
              >
                Next →
              </Link>
            ) : (
              <div className="px-4 py-2 text-gray-400">Next →</div>
            )}
          </div>

          <div className="text-lg font-semibold">
            {navigation.current} / {navigation.total}
          </div>
        </footer>
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
      const lang = Prism.languages[block.language] ? block.language : "text";
      const highlightedCode =
        lang === "text"
          ? block.code
          : Prism.highlight(block.code, Prism.languages[lang], lang);

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

    default:
      return null;
  }
}

export default validateProps(Slide, SlidePagePropsSchema);
