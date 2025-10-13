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
 * Highlight code with Prism syntax highlighting
 * @param code - The code to highlight
 * @param language - The language name (e.g., 'typescript', 'gleam', 'javascript')
 * @returns HTML string with syntax highlighting
 */
export function highlightCode(code: string, language: string): string {
  const lang = Prism.languages[language] ? language : "text";

  if (lang === "text") {
    return code;
  }

  return Prism.highlight(code, Prism.languages[lang], lang);
}
