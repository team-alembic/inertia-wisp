import Prism from "prismjs";

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

/**
 * Highlight code with Prism syntax highlighting and optionally highlight specific lines
 * @param code - The code to highlight
 * @param language - The language name (e.g., 'typescript', 'gleam', 'javascript')
 * @param highlightLines - Array of line numbers to highlight (1-based)
 * @returns HTML string with syntax highlighting
 */
export function highlightCode(
  code: string,
  language: string,
  highlightLines: number[] = [],
): string {
  const lang = Prism.languages[language] ? language : "text";

  if (lang === "text") {
    return code;
  }

  const highlighted = Prism.highlight(code, Prism.languages[lang], lang);

  // If no lines to highlight, return as-is
  if (highlightLines.length === 0) {
    return highlighted;
  }

  // Split into lines and wrap highlighted ones
  const lines = highlighted.split("\n");
  const result = lines
    .map((line, index) => {
      const lineNum = index + 1;
      if (highlightLines.includes(lineNum)) {
        return `<span class="highlighted-line">${line}</span>`;
      }
      return line;
    })
    .join("\n");

  return result;
}
