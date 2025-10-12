// TypeScript types for presentation slides
// These correspond to the Gleam types defined in the backend

import type { SlideNavigation$ } from "@presentation_shared/presentation_shared/presentation_shared/slides/content.mjs";

export interface ContentBlock {
  type: string;
}

export interface HeadingBlock extends ContentBlock {
  type: "heading";
  text: string;
}

export interface SubheadingBlock extends ContentBlock {
  type: "subheading";
  text: string;
}

export interface ParagraphBlock extends ContentBlock {
  type: "paragraph";
  text: string;
}

export interface CodeBlock extends ContentBlock {
  type: "code";
  code: string;
  language: string;
  highlight_lines: number[];
}

export interface BulletListBlock extends ContentBlock {
  type: "bullet_list";
  items: string[];
}

export interface NumberedListBlock extends ContentBlock {
  type: "numbered_list";
  items: string[];
}

export interface QuoteBlock extends ContentBlock {
  type: "quote";
  text: string;
  author: string;
}

export interface ImageBlock extends ContentBlock {
  type: "image";
  url: string;
  alt: string;
  width: number;
}

export interface ImageData {
  url: string;
  alt: string;
  width: number;
}

export interface ImageRowBlock extends ContentBlock {
  type: "image_row";
  images: ImageData[];
}

export interface ColumnsBlock extends ContentBlock {
  type: "columns";
  left: SlideContentBlock[];
  right: SlideContentBlock[];
}

export interface SpacerBlock extends ContentBlock {
  type: "spacer";
}

export type SlideContentBlock =
  | HeadingBlock
  | SubheadingBlock
  | ParagraphBlock
  | CodeBlock
  | BulletListBlock
  | NumberedListBlock
  | QuoteBlock
  | ImageBlock
  | ImageRowBlock
  | ColumnsBlock
  | SpacerBlock;

export interface Slide {
  number: number;
  title: string;
  content: SlideContentBlock[];
  notes: string;
}

// Using Gleam-generated type
// The backend sends plain JSON objects that match this structure.
// TypeScript's structural typing ensures compatibility even though
// the Gleam-generated type is technically a class.
export type SlideNavigation = SlideNavigation$;

export interface SlidePageProps {
  slide: Slide;
  navigation: SlideNavigation;
  presentation_title: string;
}
